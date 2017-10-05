/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

class NoImageTests: BaseTestCase {
    
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
    
    private func showImages() {
        navigator.goto(BrowserTabMenu)
        app.tables.cells["Show Images"].tap()
        navigator.nowAt(BrowserTab)
    }
    
    private func hideImages() {
        navigator.goto(BrowserTabMenu)
        app.tables.cells["Hide Images"].tap()
        navigator.nowAt(BrowserTab)
    }
    
    private func checkShowImages() {
        navigator.goto(BrowserTabMenu)
        waitforExistence(app.tables.cells["Show Images"])
        navigator.goto(BrowserTab)
    }
    
    private func checkHideImages() {
        navigator.goto(BrowserTabMenu)
        waitforExistence(app.tables.cells["Hide Images"])
        navigator.goto(BrowserTab)
    }
    
    private func refreshPage() {
        app.buttons["TabToolbar.stopReloadButton"].tap()
        waitUntilPageLoad()
    }
    
    // Now UITest/NoImageModeTest checks the functionality. This test only checks forUI change
    func testImageOnOff() {
        let url1 = "www.google.com"
        
        // Go to a webpage, and select no images or hide images, check it's hidden or not
        navigator.openNewURL(urlString: url1)
        waitUntilPageLoad()
        hideImages()
        checkShowImages()
        navigator.goto(BrowserTab)
        
        // Load a same page on a new tab, check images are hidden
        navigator.openURL(urlString: url1)
        waitUntilPageLoad()

        // Open it, then select show images it, and check it's showing the images
        showImages()
        checkHideImages()
        navigator.goto(BrowserTab)
    }
}
