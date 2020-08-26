/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

let url_1 = "test-example.html"
let url_2 = ["url": "test-mozilla-org.html", "bookmarkLabel": "Internet for people, not profit — Mozilla"]
let urlLabelExample_3 = "Example Domain"
let url_3 = "localhost:\(serverPort)/test-fixture/test-example.html"
let urlLabelExample_4 = "Example Login Page 2"
let url_4 = "test-password-2.html"

class BookmarkingTests: BaseTestCase {
    private func bookmark() {
        navigator.goto(PageOptionsMenu)
        waitForExistence(app.tables.cells["Bookmark This Page"], timeout: 15)
        app.tables.cells["Bookmark This Page"].tap()
        navigator.nowAt(BrowserTab)
    }

    private func unbookmark() {
        navigator.goto(PageOptionsMenu)
        waitForExistence(app.tables.cells["Remove Bookmark"])
        app.cells["Remove Bookmark"].tap()
        navigator.nowAt(BrowserTab)
    }

    private func checkBookmarked() {
        navigator.goto(PageOptionsMenu)
        waitForExistence(app.tables.cells["Remove Bookmark"])
        if iPad() {
            app.otherElements["PopoverDismissRegion"].tap()
            navigator.nowAt(BrowserTab)
        } else {
            navigator.goto(BrowserTab)
        }
    }

    private func checkUnbookmarked() {
        navigator.goto(PageOptionsMenu)
        waitForExistence(app.tables.cells["Bookmark This Page"])
        if iPad() {
            app.otherElements["PopoverDismissRegion"].tap()
            navigator.nowAt(BrowserTab)
        } else {
            navigator.goto(BrowserTab)
        }
    }

    func testBookmarkingUI() {
        // Go to a webpage, and add to bookmarks, check it's added
        navigator.openURL(path(forTestPage: url_1))
        navigator.nowAt(BrowserTab)
        waitForTabsButton()
        bookmark()
        waitForTabsButton()
        checkBookmarked()

        // Load a different page on a new tab, check it's not bookmarked
        navigator.openNewURL(urlString: path(forTestPage: url_2["url"]!))
        navigator.nowAt(BrowserTab)
        waitForTabsButton()
        checkUnbookmarked()

        // Go back, check it's still bookmarked, check it's on bookmarks home panel
        waitForTabsButton()
        navigator.goto(TabTray)
        app.collectionViews.cells["Example Domain"].tap()
        navigator.nowAt(BrowserTab)
        waitForTabsButton()
        checkBookmarked()

        // Open it, then unbookmark it, and check it's no longer on bookmarks home panel
        unbookmark()
        waitForTabsButton()
        checkUnbookmarked()
    }

    private func checkEmptyBookmarkList() {
        let list = app.tables["Bookmarks List"].cells.count
        XCTAssertEqual(list, 0, "There should not be any entry in the bookmarks list")
    }

    private func checkItemInBookmarkList() {
        waitForExistence(app.tables["Bookmarks List"])
        let list = app.tables["Bookmarks List"].cells.count
        XCTAssertEqual(list, 1, "There should be an entry in the bookmarks list")
        XCTAssertTrue(app.tables["Bookmarks List"].staticTexts[url_2["bookmarkLabel"]!].exists)
    }

    func testAccessBookmarksFromContextMenu() {
        //Add a bookmark
        navigator.openURL(path(forTestPage: url_2["url"]!))
        waitUntilPageLoad()
        navigator.nowAt(BrowserTab)
        waitForExistence(app.buttons["TabLocationView.pageOptionsButton"], timeout: 10)
        bookmark()

        //There should be a bookmark
        navigator.goto(MobileBookmarks)
        checkItemInBookmarkList()
    }
    
    func testRecentBookmarks() {
        // Verify that there are only 4 cells without recent bookmarks
        navigator.goto(LibraryPanel_Bookmarks)
        waitForNoExistence(app.otherElements["RECENT BOOKMARKS"])
        XCTAssertEqual(app.tables["Bookmarks List"].cells.count, 4)
        
        //Add a bookmark
        navigator.openURL(url_3)
        waitForTabsButton()
        bookmark()
        
        // Check if it shows in recent bookmarks
        navigator.goto(LibraryPanel_Bookmarks)
        waitForExistence(app.otherElements["Recent Bookmarks"])
        waitForExistence(app.staticTexts[urlLabelExample_3])
        XCTAssertEqual(app.tables["Bookmarks List"].cells.count, 5)
        
        // Add another
        navigator.openURL(path(forTestPage: url_4))
        waitForTabsButton()
        bookmark()
        
        // Check if it shows in recent bookmarks
        navigator.goto(LibraryPanel_Bookmarks)
        waitForExistence(app.otherElements["Recent Bookmarks"])
        waitForExistence(app.staticTexts[urlLabelExample_4])
        XCTAssertEqual(app.tables["Bookmarks List"].cells.count, 6)
        
        // Click a recent bookmark and make sure it navigates. Disabled because of issue 5038 not opening recent bookmarks when tapped
        app.tables["Bookmarks List"].cells.element(boundBy: 5).tap()
        waitForExistence(app.textFields["url"], timeout: 6)
        waitForValueContains(app.textFields["url"], value: url_3)
    }

    func testBookmarksAwesomeBar() {
        navigator.nowAt(BrowserTab)
        navigator.goto(URLBarOpen)
        typeOnSearchBar(text: "www.ebay")
        waitForExistence(app.tables["SiteTable"])
        waitForExistence(app.buttons["www.ebay.com"])
        XCTAssertTrue(app.buttons["www.ebay.com"].exists)
        typeOnSearchBar(text: ".com")
        typeOnSearchBar(text: "\r")
        navigator.nowAt(BrowserTab)

         //Clear text and enter new url
        waitForTabsButton()
        navigator.performAction(Action.OpenNewTabFromTabTray)
        navigator.goto(URLBarOpen)
        typeOnSearchBar(text: "http://www.olx.ro")

        // Site table existes but is empty
        waitForExistence(app.tables["SiteTable"])
        XCTAssertEqual(app.tables["SiteTable"].cells.count, 0)
        typeOnSearchBar(text: "\r")
        navigator.nowAt(BrowserTab)

        // Add page to bookmarks
        waitForTabsButton()
        bookmark()

        // Now the site should be suggested
        waitForExistence(app.buttons["TabToolbar.menuButton"], timeout: 10)
        navigator.performAction(Action.AcceptClearPrivateData)
        navigator.goto(BrowserTab)
        navigator.goto(URLBarOpen)
        typeOnSearchBar(text: "olx.ro")
        waitForExistence(app.tables["SiteTable"])
        waitForExistence(app.buttons["olx.ro"])
        XCTAssertNotEqual(app.tables["SiteTable"].cells.count, 0)
    }

    func testAddBookmark() {
        addNewBookmark()
        // Verify that clicking on bookmark opens the website
        app.tables["Bookmarks List"].cells.element(boundBy: 0).tap()
        waitForExistence(app.textFields["url"], timeout: 5)
    }

    func testAddNewFolder() {
        navigator.goto(MobileBookmarks)
        navigator.goto(MobileBookmarksAdd)
        navigator.performAction(Action.AddNewFolder)
        waitForExistence(app.navigationBars["New Folder"])
        // XCTAssertFalse(app.buttons["Save"].isEnabled), is this a bug allowing empty folder name?
        app.tables["SiteTable"].cells.textFields.element(boundBy: 0).tap()
        app.tables["SiteTable"].cells.textFields.element(boundBy: 0).typeText("Test Folder")
        app.buttons["Save"].tap()
        app.buttons["Done"].tap()
        checkItemsInBookmarksList(items: 1)
        navigator.nowAt(MobileBookmarks)
        // Now remove the folder
        navigator.performAction(Action.RemoveItemMobileBookmarks)
        waitForExistence(app.buttons["Delete"])
        navigator.performAction(Action.ConfirmRemoveItemMobileBookmarks)
        checkItemsInBookmarksList(items: 0)
    }

    func testAddNewMarker() {
        navigator.goto(MobileBookmarks)
        navigator.goto(MobileBookmarksAdd)
        navigator.performAction(Action.AddNewSeparator)
        app.buttons["Done"].tap()
        checkItemsInBookmarksList(items: 1)

        // Remove it
        navigator.nowAt(MobileBookmarks)
        navigator.performAction(Action.RemoveItemMobileBookmarks)
        waitForExistence(app.buttons["Delete"])
        navigator.performAction(Action.ConfirmRemoveItemMobileBookmarks)
        checkItemsInBookmarksList(items: 0)
    }

    func testDeleteBookmarkSwiping() {
        addNewBookmark()
        // Remove by swiping
        app.tables["Bookmarks List"].staticTexts["BBC"].swipeLeft()
        app.buttons["Delete"].tap()
        checkItemsInBookmarksList(items: 0)
    }

    func testDeleteBookmarkContextMenu() {
        addNewBookmark()
        // Remove by long press and select option from context menu
        app.tables.staticTexts.element(boundBy: 0).press(forDuration: 1)
        waitForExistence(app.tables["Context Menu"])
        app.tables["Context Menu"].cells["action_bookmark_remove"].tap()
        checkItemsInBookmarksList(items: 0)
    }

    private func addNewBookmark() {
        navigator.goto(MobileBookmarksAdd)
        navigator.performAction(Action.AddNewBookmark)
        waitForExistence(app.navigationBars["New Bookmark"], timeout: 3)
        // Enter the bookmarks details
        app.tables["SiteTable"].cells.textFields.element(boundBy: 0).tap()
        app.tables["SiteTable"].cells.textFields.element(boundBy: 0).typeText("BBC")

        app.tables["SiteTable"].cells.textFields["https://"].tap()
        app.tables["SiteTable"].cells.textFields["https://"].typeText("bbc.com")
        navigator.performAction(Action.SaveCreatedBookmark)
        app.buttons["Done"].tap()
        checkItemsInBookmarksList(items: 1)
    }

    private func checkItemsInBookmarksList(items: Int) {
        waitForExistence(app.tables["Bookmarks List"], timeout: 3)
        XCTAssertEqual(app.tables["Bookmarks List"].cells.count, items)
    }

    private func typeOnSearchBar(text: String) {
        waitForExistence(app.textFields["url"], timeout: 5)
        sleep(1)
        app.textFields["address"].tap()
        app.textFields["address"].typeText(text)
    }

    // Smoketest
    func testBookmarkLibraryAddDeleteBookmark() {
        // Verify that there are only 4 cells without recent bookmarks
        navigator.goto(LibraryPanel_Bookmarks)
        waitForNoExistence(app.otherElements["Recent Bookmarks"])
        // There are 4 rows for the default folders
        XCTAssertEqual(app.tables["Bookmarks List"].cells.count, 4)

        //Add a bookmark
        navigator.openURL(url_3)
        waitForTabsButton()
        bookmark()

        // Check that it appers in Bookmarks panel
        navigator.goto(LibraryPanel_Bookmarks)
        //waitForExistence(app.staticTexts["Example Domain"], timeout: 10)
        app.tables["Bookmarks List"].cells.staticTexts["Example Domain"].swipeLeft()
        // Delete the Bookmark added, check it is removed
        app.buttons["Delete"].tap()
        waitForNoExistence(app.tables["Bookmarks List"].cells.staticTexts["Example Domain"], timeoutValue: 10)
        XCTAssertFalse(app.tables["Bookmarks List"].cells.staticTexts["Example Domain"].exists, "Bookmark not removed successfully")
    }
}
