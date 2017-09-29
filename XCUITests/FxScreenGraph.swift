/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import XCTest

let FirstRun = "OptionalFirstRun"
let TabTray = "TabTray"
let PrivateTabTray = "PrivateTabTray"
let URLBarOpen = "URLBarOpen"
let BrowserTab = "BrowserTab"
let PrivateBrowserTab = "PrivateBrowserTab"
let BrowserTabMenu = "BrowserTabMenu"
let PageOptionsMenu = "PageOptionsMenu"
let SettingsScreen = "SettingsScreen"
let HomePageSettings = "HomePageSettings"
let PasscodeSettings = "PasscodeSettings"
let PasscodeIntervalSettings = "PasscodeIntervalSettings"
let SearchSettings = "SearchSettings"
let NewTabSettings = "NewTabSettings"
let ClearPrivateDataSettings = "ClearPrivateDataSettings"
let LoginsSettings = "LoginsSettings"
let OpenWithSettings = "OpenWithSettings"
let ShowTourInSettings = "ShowTourInSettings"

let allSettingsScreens = [
    SettingsScreen,
    HomePageSettings,
    PasscodeSettings,
    SearchSettings,
    NewTabSettings,
    ClearPrivateDataSettings,
    LoginsSettings,
    OpenWithSettings,
]

let Intro_Welcome = "Intro.Welcome"
let Intro_Search = "Intro.Search"
let Intro_Private = "Intro.Private"
let Intro_Mail = "Intro.Mail"
let Intro_Sync = "Intro.Sync"

let allIntroPages = [
    Intro_Welcome,
    Intro_Search,
    Intro_Private,
    Intro_Mail,
    Intro_Sync,
]

let HomePanelsScreen = "HomePanels"
let PrivateHomePanelsScreen = "PrivateHomePanels"
let HomePanel_TopSites = "HomePanel.TopSites.0"
let HomePanel_Bookmarks = "HomePanel.Bookmarks.1"
let HomePanel_History = "HomePanel.History.2"
let HomePanel_ReadingList = "HomePanel.ReadingList.3"
let P_HomePanel_TopSites = "P_HomePanel.TopSites.0"
let P_HomePanel_Bookmarks = "P_HomePanel.Bookmarks.1"
let P_HomePanel_History = "P_HomePanel.History.2"
let P_HomePanel_ReadingList = "P_HomePanel.ReadingList.3"

let allHomePanels = [
    HomePanel_Bookmarks,
    HomePanel_TopSites,
    HomePanel_History,
    HomePanel_ReadingList,
]
let allPrivateHomePanels = [
    P_HomePanel_Bookmarks,
    P_HomePanel_TopSites,
    P_HomePanel_History,
    P_HomePanel_ReadingList,
]

let ContextMenu_ReloadButton = "ContextMenu_ReloadButton"

func createScreenGraph(_ app: XCUIApplication, url: String = "https://www.mozilla.org/en-US/book/") -> ScreenGraph {
    let map = ScreenGraph()

    let startBrowsingButton = app.buttons["IntroViewController.startBrowsingButton"]
    let introScrollView = app.scrollViews["IntroViewController.scrollView"]
    map.createScene(FirstRun) { scene in
        // We don't yet have conditional edges, so we declare an edge from this node
        // to BrowserTab, and then just make it work.
        if introScrollView.exists {
            
            scene.gesture(to: BrowserTab) {
                // go find the startBrowsing button on the second page of the intro.
                introScrollView.swipeLeft()
                startBrowsingButton.tap()
           }
            
            scene.noop(to: allIntroPages[0])
        } else {
            scene.noop(to: HomePanelsScreen)
        }
    }

    // Add the intro screens.
    var i = 0
    let introLast = allIntroPages.count - 1
    let introPager = app.scrollViews["IntroViewController.scrollView"]
    for intro in allIntroPages {
        let prev = i == 0 ? nil : allIntroPages[i - 1]
        let next = i == introLast ? nil : allIntroPages[i + 1]

        map.createScene(intro) { scene in
            if let prev = prev {
                scene.swipeRight(introPager, to: prev)
            }

            if let next = next {
                scene.swipeLeft(introPager, to: next)
            }

            if i > 0 {
                scene.tap(startBrowsingButton, to: BrowserTab)
            }
        }

        i += 1
    }

    map.createScene(URLBarOpen) { scene in
        // This is used for opening BrowserTab with default mozilla URL
        // For custom URL, should use Navigator.openNewURL or Navigator.openURL.
        scene.typeText(url + "\r", into: app.textFields["address"], to: BrowserTab)
        scene.tap( app.textFields["address"], to: HomePanelsScreen)
    }

    let noopAction = {}
    map.createScene(HomePanelsScreen) { scene in
        scene.tap(app.buttons["HomePanels.TopSites"], to: HomePanel_TopSites)
        scene.tap(app.buttons["HomePanels.Bookmarks"], to: HomePanel_Bookmarks)
        scene.tap(app.buttons["HomePanels.History"], to: HomePanel_History)
        scene.tap(app.buttons["HomePanels.ReadingList"], to: HomePanel_ReadingList)
        
        scene.tap(app.textFields["url"], to: URLBarOpen)
        scene.tap(app.buttons["TabToolbar.menuButton"], to: BrowserTabMenu)
        if map.isiPad() {
            scene.tap(app.buttons["TopTabsViewController.tabsButton"], to: TabTray)
        } else {
            scene.tap(app.buttons["TabToolbar.tabsButton"], to: TabTray)
        }
    }
    
    map.createScene(PrivateHomePanelsScreen) { scene in
        scene.tap(app.buttons["HomePanels.TopSites"], to: P_HomePanel_TopSites)
        scene.tap(app.buttons["HomePanels.Bookmarks"], to: P_HomePanel_Bookmarks)
        scene.tap(app.buttons["HomePanels.History"], to: P_HomePanel_History)
        scene.tap(app.buttons["HomePanels.ReadingList"], to: P_HomePanel_ReadingList)
        
        scene.tap(app.textFields["url"], to: URLBarOpen)
        scene.tap(app.buttons["TabToolbar.menuButton"], to: BrowserTabMenu)
        if map.isiPad() {
            scene.tap(app.buttons["TopTabsViewController.tabsButton"], to: PrivateTabTray)
        } else {
            scene.tap(app.buttons["TabToolbar.tabsButton"], to: PrivateTabTray)
        }
    }

    allHomePanels.forEach { name in
        // Tab panel means that all the home panels are available all the time, so we can 
        // fake this out by a noop back to the HomePanelsScreen which can get to every other panel.
        map.createScene(name) { scene in
            scene.backAction = noopAction
        }
    }
    
    allPrivateHomePanels.forEach { name in
        // Tab panel means that all the home panels are available all the time, so we can
        // fake this out by a noop back to the HomePanelsScreen which can get to every other panel.
        map.createScene(name) { scene in
            scene.backAction = noopAction
        }
    }

    let closeMenuAction = {
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.25)).tap()
    }

    let navigationControllerBackAction = {
        app.navigationBars.element(boundBy: 0).buttons.element(boundBy: 0).tap()
    }
    
    let cancelBackAction = {
        app.buttons["Cancel"].tap()
    }
    
    let backBtnBackAction = {
        app.buttons["TabToolbar.backButton"].tap()
    }

    map.createScene(SettingsScreen) { scene in
        let table = app.tables["AppSettingsTableViewController.tableView"]

        scene.tap(table.cells["Search"], to: SearchSettings)
        scene.tap(table.cells["NewTab"], to: NewTabSettings)
        scene.tap(table.cells["Homepage"], to: HomePageSettings)
        scene.tap(table.cells["TouchIDPasscode"], to: PasscodeSettings)
        scene.tap(table.cells["Logins"], to: LoginsSettings)
        scene.tap(table.cells["ClearPrivateData"], to: ClearPrivateDataSettings)
        scene.tap(table.cells["OpenWith.Setting"], to: OpenWithSettings)
        scene.tap(table.cells["ShowTour"], to: ShowTourInSettings)

        scene.backAction = navigationControllerBackAction
    }

    map.createScene(SearchSettings) { scene in
        scene.backAction = navigationControllerBackAction
    }

    map.createScene(NewTabSettings) { scene in
        scene.backAction = navigationControllerBackAction
    }

    map.createScene(HomePageSettings) { scene in
        scene.backAction = navigationControllerBackAction
    }

    map.createScene(PasscodeSettings) { scene in
        scene.backAction = navigationControllerBackAction
        
        scene.tap(app.tables["AuthenticationManager.settingsTableView"].staticTexts["Require Passcode"], to: PasscodeIntervalSettings)
    }

    map.createScene(PasscodeIntervalSettings) { scene in
        // The test is likely to know what it needs to do here.
        // This screen is protected by a passcode and is essentially modal.
        scene.gesture(to: PasscodeSettings) {
            if app.navigationBars["Require Passcode"].exists {
                // Go back, accepting modifications
                app.navigationBars["Require Passcode"].buttons["Passcode"].tap()
            } else {
                // Cancel
                app.navigationBars["Enter Passcode"].buttons["Cancel"].tap()
            }
        }
    }

    map.createScene(LoginsSettings) { scene in
        scene.gesture(to: SettingsScreen) {
            let loginList = app.tables["Login List"]
            if loginList.exists {
                app.navigationBars["Logins"].buttons["Settings"].tap()
            } else {
                app.navigationBars["Enter Passcode"].buttons["Cancel"].tap()
            }
        }
    }

    map.createScene(ClearPrivateDataSettings) { scene in
        scene.backAction = navigationControllerBackAction
    }

    map.createScene(OpenWithSettings) { scene in
        scene.backAction = navigationControllerBackAction
    }
    
    map.createScene(ShowTourInSettings) { scene in
        scene.backAction = {
            introScrollView.swipeLeft()
            startBrowsingButton.tap()
        }
    }

    map.createScene(PrivateTabTray) { scene in
        scene.tap(app.buttons["TabTrayController.addTabButton"], to: PrivateHomePanelsScreen)
        scene.tap(app.buttons["TabTrayController.maskButton"], to: TabTray)
    }

    map.createScene(TabTray) { scene in
        scene.tap(app.buttons["TabTrayController.addTabButton"], to: HomePanelsScreen)
        scene.tap(app.buttons["TabTrayController.maskButton"], to: PrivateTabTray)
    }

    map.createScene(BrowserTab) { scene in
        scene.tap(app.textFields["url"], to: URLBarOpen)
        scene.tap(app.buttons["TabToolbar.menuButton"], to: BrowserTabMenu)
        if map.isiPad() {
            scene.tap(app.buttons["TopTabsViewController.tabsButton"], to: TabTray)
        } else {
            scene.tap(app.buttons["TabToolbar.tabsButton"], to: TabTray)
        }
        scene.tap(app.buttons["TabLocationView.pageOptionsButton"], to: PageOptionsMenu)
        
        scene.backAction = backBtnBackAction
    }
    
    // make sure after the menu action, navigator.nowAt() is used to set the current state
    map.createScene(PageOptionsMenu) {scene in
        
        scene.backAction = cancelBackAction
        scene.dismissOnUse = true
    }
    
    map.createScene(PrivateBrowserTab) { scene in
        scene.tap(app.textFields["url"], to: URLBarOpen)
        scene.tap(app.buttons["TabToolbar.menuButton"], to: BrowserTabMenu)
        if map.isiPad() {
            scene.tap(app.buttons["TopTabsViewController.tabsButton"], to: PrivateTabTray)
        } else {
            scene.tap(app.buttons["TabToolbar.tabsButton"], to: PrivateTabTray)
        }
        scene.tap(app.buttons["TabLocationView.pageOptionsButton"], to: PageOptionsMenu)
        
        scene.backAction = backBtnBackAction
    }

    map.createScene(BrowserTabMenu) { scene in
        scene.backAction = closeMenuAction
        // XXX Testing for the element causes an error, so we use the more
        // generic `gesture` method which does not test for the existence
        // before swiping.
        scene.tap(app.tables.cells["Settings"], to: SettingsScreen)
        
        scene.dismissOnUse = true
    }

    let cancelContextMenuAction = {
        let buttons = app.sheets.element(boundBy: 0).buttons
        buttons.element(boundBy: buttons.count-1).tap()
    }

    map.initialSceneName = FirstRun

    return map
}
extension ScreenGraph {
    
    // Checks whether the current device is iPad or non-iPad
    func isiPad() -> Bool {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return true
        }
        return false
    }
}

extension Navigator {

    // Open a URL. Will use/re-use the first BrowserTab or NewTabScreen it comes to.
    func openURL(urlString: String) {
        self.goto(URLBarOpen)
        let app = XCUIApplication()
        app.textFields["address"].typeText(urlString + "\r")
        
        self.nowAt(BrowserTab)
    }

    // Opens a URL in a new tab.
    func openNewURL(urlString: String) {
        self.goto(TabTray)
        createNewTab()
        self.openURL(urlString: urlString)
    }

    // Closes all Tabs from the option in TabTrayMenu
    func closeAllTabs() {
        let app = XCUIApplication()
        app.buttons["TabTrayController.remoteTabsButton"].tap()
        app.buttons["Close All Tabs"].tap()
    }

    // Add a new Tab from the New Tab option in Browser Tab Menu
    func createNewTab() {
        let app = XCUIApplication()
        self.goto(TabTray)
        app.buttons["TabTrayController.addTabButton"].tap()
        self.nowAt(HomePanelsScreen)
    }

    // Add Tab(s) from the Tab Tray
    func createSeveralTabsFromTabTray(numberTabs: Int) {
        for _ in 1...numberTabs {
            self.goto(HomePanel_TopSites)
            self.goto(TabTray)
        }
    }

    func browserPerformAction(_ view: BrowserPerformAction) {
        let PageMenuOptions = [.toggleBookmarkOption, .addReadingListOption, .copyURLOption, .findInPageOption, .toggleDesktopOption, .requestSetHomePageOption, BrowserPerformAction.shareOption]
        let BrowserMenuOptions = [.openTopSitesOption, .openBookMarksOption, .openHistoryOption, .openReadingListOption, .toggleHideImages, .toggleNightMode, BrowserPerformAction.openSettingsOption]
        
        let app = XCUIApplication()
        
        if PageMenuOptions.contains(view) {
            self.goto(PageOptionsMenu)
            app.collectionViews.cells[view.rawValue].tap()
        } else if BrowserMenuOptions.contains(view) {
            self.goto(BrowserTabMenu)
            app.collectionViews.cells[view.rawValue].tap()
        }
    }
}
enum BrowserPerformAction: String {
    // Page Menu
    case toggleBookmarkOption  = "menu-Bookmark"
    case addReadingListOption = "addToReadingList"
    case copyURLOption = "menu-Copy-Link"
    case findInPageOption = "menu-FindInPage"
    case toggleDesktopOption = "menu-RequestDesktopSite"
    case requestSetHomePageOption = "menu-Home"
    case shareOption = "action_share"
    
    // Tab Menu
    case openTopSitesOption = "menu-panel-TopSites"
    case openBookMarksOption = "menu-panel-Bookmarks"
    case openHistoryOption = "menu-panel-History"
    case openReadingListOption = "menu-panel-ReadingList"
    case toggleHideImages = "menu-NoImageMode"
    case toggleNightMode = "menu-NightMode"
    case openSettingsOption = "menu-Settings"
}
