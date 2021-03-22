//
//  UILabelEx.swift
//  iOSUtil
//
//  Created by wooky83 on 06/12/2019.
//  Copyright © 2019 wooky. All rights reserved.
//

import UIKit

extension UILabel {
    
    //<font face="AppleSDGothicNeo-Regular"><b>가나다라마바사</b><br><span style="font-size:19;color:red;background-color:blue">아자차카타파하</span></font>
    func setHtmlLabel(bodyString: String?, alignment: NSTextAlignment? = nil, lineSpacing: CGFloat? = nil) {
        AttributedStringFactory.create(bodyString ?? "", fontSize: self.font.pointSize) {
            switch $0 {
            case .success(let value):
                self.attributedText = value
            case .failure(let error):
                switch error {
                case .parseError(let str):
                    self.text = str
                }
            }
            guard let cAttributedText = self.attributedText, lineSpacing != nil else { return }
            let mutableAttributedText = NSMutableAttributedString(attributedString: cAttributedText)
            if let spacing = lineSpacing {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = spacing
                mutableAttributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: mutableAttributedText.length))
            }
            self.attributedText = mutableAttributedText
        }
        if let alignment = alignment {
            self.textAlignment = alignment
        }
    }
}

