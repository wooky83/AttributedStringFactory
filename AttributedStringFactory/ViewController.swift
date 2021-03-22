//
//  ViewController.swift
//  AttributedStringFactory
//
//  Created by wooky83 on 2021/03/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var attributedLabel: UILabel!
    @IBOutlet weak var attributedHtmlLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let htmlTag = """
            <font face="AppleSDGothicNeo-Regular"><b>가나\n다<a href="http://www.google.com">라마바사아자차카</a>타파하</b><br><span style="font-size:25;Color:red;background-color:blue">아자차카타파하</span></font>
            """
        
        attributedLabel.setHtmlLabel(bodyString: htmlTag)
        attributedHtmlLabel.attributedText = htmlTag.attributedStringFromHtml
        print(String(describing: attributedLabel.text))
    }


}

