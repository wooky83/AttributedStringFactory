//
//  File.swift
//  iOSUtil
//
//  Created by wooky83 on 05/03/2019.
//  Copyright © 2019 wooky. All rights reserved.
//

import UIKit

private enum CSAttributeType {
    case br
    case font(face: String?, size: CGFloat?, color: String?)
    case alignment(NSTextAlignment?)
    case bold
    case italic
    case regular
    case underLine
    case bgColor(color: String)

    func valueOf(_ index: Int) -> Any? {
        switch self {
        case .font(let face, let size, let color) :
            if index == 0 {
                return face
            } else if index == 1 {
                return size
            }
            return color
        case .alignment(let alignment) :
            return alignment

        default:
            return nil
        }
    }

    func isFont() -> Bool {
        switch self {
        case .font :
            return true

        default :
            return false
        }
    }

    func isEqualToType(_ type: CSAttributeType) -> Bool {
        switch (self, type) {
        case (.br, .br) : return true
        case (.font, .font) : return true
        case (.alignment, .alignment) : return true
        case (.bold, .bold) : return true
        case (.italic, .italic) : return true
        case (.regular, .regular) : return true
        case (.underLine, .underLine) : return true
        default: return false
        }
    }
}

// MARK: - Error
enum XMLFontError: Error {
    case parseError(String)
}

class AttributedStringFactory: NSObject {

    // MARK: properties
    private var originString: String
    private var htmlString: String
    private let fontSize: CGFloat
    private var attributes: [CSAttributeType] = []
    private let attributedString = NSMutableAttributedString()
    private var completion: ((_ result: Result<NSMutableAttributedString, XMLFontError>) -> Void)?

    private lazy var parser: XMLParser = {
        let parser = XMLParser(data: self.htmlString.data(using: .utf8)!)
        parser.delegate = self
        return parser
    }()

    // MARK: LifeCycle
    init(_ origin: String, html: String, fontSize: CGFloat, completion: @escaping (_ result: Result<NSMutableAttributedString, XMLFontError>) -> Void) {
        let tempHtml = "<html>\(html)</html>"

        self.originString = origin
        self.htmlString = ""
        self.completion = completion
        self.fontSize = fontSize
        super.init()

        self.htmlString = self.replaceBrTag(tempHtml)

        self.parser.parse()
    }

    class func create(_ str: String, fontFamily: String? = nil, fontSize: CGFloat, fontColor: String? = nil, completion: @escaping (_ result: Result<NSMutableAttributedString, XMLFontError>) -> Void) {
        let family = fontFamily.map {" face=\"\($0)\""} ?? ""
        let color = fontColor.map {" color=\"\($0)\""} ?? ""

        let html = "<font\(family)\(color)>\(str)</font>"
        _ = AttributedStringFactory(str, html: html, fontSize: fontSize, completion: completion)
    }

    private func lastFont() -> CSAttributeType? {

        let attributes = self.attributes.filter { $0.isFont() }
        guard attributes.count > 0 else { return nil }

        let attribute = attributes.reduce(into: (font: String?, size: CGFloat?, color: String?)(nil, nil, nil), {
            if let font = $1.valueOf(0) as? String {
                $0.font = font
            }
            if let size = $1.valueOf(1) as? CGFloat {
                $0.size = size
            }
            if let color = $1.valueOf(2) as? String {
                $0.color = color
            }
        })
        return CSAttributeType.font(face: attribute.font, size: attribute.size, color: attribute.color)
    }

    //br 태그가 parsing 시에 숫자로 시작되는 문자는 두개의 node에 newline을 붙이는 이슈가 있어 처음 html 텍스트에서 br 태그를 newline으로 단순 변경 후 parsing 하도록 수정
    private func replaceBrTag(_ htmlText: String) -> String {
        var returnText = htmlText

        returnText = returnText.replacingOccurrences(of: "<br>", with: "\n")
        returnText = returnText.replacingOccurrences(of: "<BR>", with: "\n")
        returnText = returnText.replacingOccurrences(of: "<Br>", with: "\n")
        returnText = returnText.replacingOccurrences(of: "<bR>", with: "\n")
        returnText = returnText.replacingOccurrences(of: "<br/>", with: "\n")
        returnText = returnText.replacingOccurrences(of: "<BR/>", with: "\n")
        returnText = returnText.replacingOccurrences(of: "<Br/>", with: "\n")
        returnText = returnText.replacingOccurrences(of: "<bR/>", with: "\n")
        returnText = returnText.replacingOccurrences(of: "</br>", with: "\n")
        returnText = returnText.replacingOccurrences(of: "</BR>", with: "\n")

        return returnText
    }

    private func font(_ familyName: String?, type: CSAttributeType, size: CGFloat?) -> UIFont {
        let size = size ?? fontSize
        guard let familyName = familyName, let font = UIFont(name: familyName, size: size) else {
            switch type {
            case .bold:
                return UIFont.boldSystemFont(ofSize: size)
            case .italic:
                return UIFont.italicSystemFont(ofSize: size)
            default:
                return UIFont.systemFont(ofSize: size)
            }
        }
        switch type {
        case .bold:
            if let descriptor = font.fontDescriptor.withSymbolicTraits(.traitBold) {
                return UIFont(descriptor: descriptor, size: size)
            } else {
                return font
            }
        case .italic:
            if let descriptor = font.fontDescriptor.withSymbolicTraits(.traitItalic) {
                return UIFont(descriptor: descriptor, size: size)
            } else {
                return font
            }
        default:
            return font
        }
    }

    private func cgFlotFromString(str: String?) -> CGFloat? {
        guard let sizeString = str else { return nil }
        let sizeStringTrim = sizeString.lowercased()
            .trimmingCharacters(in: CharacterSet.decimalDigits.inverted)
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        if let number = NumberFormatter().number(from: sizeStringTrim)?.doubleValue {
            return CGFloat(number)
        } else {
            return nil
        }
    }
    
    private func completionClosure(result: Result<NSMutableAttributedString, XMLFontError>) {
        self.completion?(result)
        self.completion = nil
    }
    
    deinit {
        print("AttributedStringFactory deinit")
    }
}

extension AttributedStringFactory: XMLParserDelegate {
    
    public func parserDidStartDocument(_ parser: XMLParser) {
        attributes.removeAll()
        attributedString.deleteCharacters(in: NSRange(location: 0, length: attributedString.length))
    }

    public func parserDidEndDocument(_ parser: XMLParser) {
        completionClosure(result: .success(self.attributedString))
    }

    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
        switch elementName.uppercased() {
        case "B":
            self.attributes.append(.bold)

        case "I":
            self.attributes.append(.italic)

        case "SPAN":
            let spanAttributed = attributeDict.reduce(into: [:], { $0[$1.key.lowercased()] = $1.value })
            guard let styleString = spanAttributed["style"] else { break }

            var attrs: [String: String] = [:]

            for attr in styleString.components(separatedBy: ";") {
                let key = attr.components(separatedBy: ":")[0].lowercased()
                let value = attr.components(separatedBy: ":")[1]
                attrs[key.trimmingCharacters(in: .whitespaces)] = value.trimmingCharacters(in: .whitespaces)
            }
            if let size = cgFlotFromString(str: attrs["font-size"]) {
                self.attributes.append(.font(face: nil, size: size, color: nil))
            }

            if let bgColor = attrs["background-color"] {
                self.attributes.append(.bgColor(color: bgColor))
            }
            
            if let color = attrs["color"] {
                self.attributes.append(.font(face: nil, size: nil, color: color))
            }

        case "FONT":
            let fontAttributed = attributeDict.reduce(into: [:], { $0[$1.key.lowercased()] = $1.value })
            self.attributes.append(.font(face: fontAttributed["face"], size: cgFlotFromString(str: fontAttributed["size"]), color: fontAttributed["color"]))
        case "CENTER":
            self.attributes.append(.alignment(.center))

        case "LEFT":
            self.attributes.append(.alignment(.left))

        case "RIGHT":
            self.attributes.append(.alignment(.right))

        case "U":
            self.attributes.append(.underLine)

        default:
            break
        }
    }

    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        var attribute: CSAttributeType

        switch elementName.uppercased() {
        case "BR":
            attribute = .br

        case "B":
            attribute = .bold

        case "I":
            attribute = .italic

        case "SPAN": fallthrough
        case "FONT":
            attribute = .font(face: nil, size: nil, color: nil)

        case "CENTER": fallthrough
        case "LEFT": fallthrough
        case "RIGHT":
            attribute = .alignment(nil)

        case "U":
            attribute = .underLine

        default:
            return
        }

        var deleteIndex: Int = -1

        for (index, attr) in self.attributes.enumerated() {
            if attr.isEqualToType(attribute) {
                deleteIndex = index
            }
        }

        if deleteIndex > -1 {
            self.attributes.remove(at: deleteIndex)
        }
    }

    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        let attributedString = NSMutableAttributedString(string: string)

        for attribute in self.attributes {
            switch attribute {
            case .alignment(let alignment) :
                guard let alignment = alignment else { break }
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = alignment

                attributedString.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle,
                                                NSAttributedString.Key.baselineOffset: NSNumber(value: 0 as Float)],
                                               range: NSRange(location: 0, length: attributedString.length))

            case .font(let face, let size, let colorString) :
                var lastFont = self.lastFont()

                if lastFont != nil {
                    lastFont = .font(face : face ?? lastFont?.valueOf(0) as? String,
                                     size : size ?? lastFont?.valueOf(1) as? CGFloat,
                                     color: colorString ?? lastFont?.valueOf(2) as? String)
                } else {
                    lastFont = .font(face : face, size: size, color: colorString)
                }

                if face != nil || size != nil {
                    attributedString.addAttribute(.font,
                                                  value: self.font(lastFont?.valueOf(0) as? String, type: .regular, size: lastFont?.valueOf(1) as? CGFloat),
                                                  range: NSRange(location: 0, length: attributedString.length))
                }

                guard let colorString = colorString else { break }

                // "color=#FFFFFF" 형식 인지 "color=Red" 형식인지 체크
                let color: UIColor

                if colorString.hasPrefix("#") {
                    color = UIColor.color(hexString: colorString)
                } else {
                    color = UIColor.color(colorName: colorString)
                }

                attributedString.addAttribute(.foregroundColor,
                                              value: color,
                                              range: NSRange(location: 0, length: attributedString.length))

            case .bold :
                let lastFont = self.lastFont()
                attributedString.addAttribute(.font,
                                              value: self.font(lastFont?.valueOf(0) as? String, type: .bold, size: lastFont?.valueOf(1) as? CGFloat),
                                              range: NSRange(location: 0, length: attributedString.length))

            case .italic :
                let lastFont = self.lastFont()
                attributedString.addAttribute(.font,
                                              value: self.font(lastFont?.valueOf(0) as? String, type: .italic, size: lastFont?.valueOf(1) as? CGFloat),
                                              range: NSRange(location: 0, length: attributedString.length))

            case .underLine :
                attributedString.addAttribute(.underlineStyle,
                                              value: NSUnderlineStyle.single.rawValue,
                                              range: NSRange(location: 0, length: attributedString.length))

            case .bgColor(let color):
                attributedString.addAttribute(.backgroundColor,
                                              value: UIColor.color(colorName: color),
                                              range: NSRange(location: 0, length: attributedString.length))

            default:
                break
            }
        }
        self.attributedString.append(attributedString)
    }

    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("html parser occured an error : " + parseError.localizedDescription)
        completionClosure(result: .failure(.parseError(originString)))
    }
}
