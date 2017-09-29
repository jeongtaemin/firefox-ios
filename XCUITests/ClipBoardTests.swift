/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

class ClipBoardTests: BaseTestCase {
    let url = "www.example.com"
    var navigator: Navigator!
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        navigator = createScreenGraph(app).navigator(self)
    }
    
    override func tearDown() {
        navigator = nil
        app = nil
        super.tearDown()
    }
    
    //Check for test url in the browser
    func checkUrl() {
        let urlTextField = app.textFields["url"]
        waitForValueContains(urlTextField, value: "www.example")
    }
    
    //Copy url from the browser
    func copyUrl() {
        app.textFields["url"].tap()
        app.textFields["address"].press(forDuration: 3)
        waitforExistence(app.menuItems["Select All"])
        app.menuItems["Select All"].tap()
        waitforExistence(app.menuItems["Copy"])
        app.menuItems["Copy"].tap()
    }
    
    //Check copied url is same as in browser
    func checkCopiedUrl() {
        if let myString = UIPasteboard.general.string {
            let value = app.textFields["address"].value as! String
            XCTAssertNotNil(myString)
            XCTAssertEqual(myString, value, "Url matches with the UIPasteboard")
        }
    }
    
    // This test is disabled in release, but can still run on master
    func testClipboard() {
        navigator.openURL(urlString: url)
        checkUrl()
        copyUrl()
        checkCopiedUrl()
    }
}

