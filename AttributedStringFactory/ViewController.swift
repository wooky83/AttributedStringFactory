//
//  ViewController.swift
//  AttributedStringFactory
//
//  Created by wooky83 on 2021/03/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var attributedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attributedLabel.setHtmlLabel(bodyString: """
            <font face="AppleSDGothicNeo-Regular"><b>가나다라마바사</b><br><span style="font-size:19;Color:red;background-color:blue">아자차카타파하</span></font>
            """)
        // Do any additional setup after loading the view.
        print(attributedLabel.text)
    }


}

