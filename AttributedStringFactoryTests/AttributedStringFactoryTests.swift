//
//  AttributedStringFactoryTests.swift
//  AttributedStringFactoryTests
//
//  Created by wooky83 on 2021/03/22.
//

import XCTest
@testable import AttributedStringFactory

class AttributedStringFactoryTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceAttributedStringFactory() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            let label = UILabel()
            label.setHtmlLabel(bodyString: """
                <font face="AppleSDGothicNeo-Regular"><b>가나다라마바사</b><br><span style="font-size:19;Color:red;background-color:blue">아자차카타파하</span></font>
                """)
        }
    }

    
    func testPerformanceAttributedStringFromHtml() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            let htmlString = """
                <font face="AppleSDGothicNeo-Regular"><b>가나다라마바사</b><br><span style="font-size:19;Color:red;background-color:blue">아자차카타파하</span></font>
                """
            let _ = htmlString.attributedStringFromHtml
        }
    }

}
