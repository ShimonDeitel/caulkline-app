import XCTest

final class CaulklineUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAddEntryFlow() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["addEntryButton"].tap()
        let titleField = app.textFields["titleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 3))
        titleField.tap()
        titleField.typeText("UI Test Entry")
        app.buttons["formSaveButton"].tap()
        XCTAssertTrue(app.staticTexts["UI Test Entry"].waitForExistence(timeout: 3))
    }

    func testFreeLimitTriggersPaywall() throws {
        let app = XCUIApplication()
        app.launch()
        for i in 0..<20 {
            app.buttons["addEntryButton"].tap()
            let titleField = app.textFields["titleField"]
            if titleField.waitForExistence(timeout: 2) {
                titleField.tap()
                titleField.typeText("Item \(i)")
                app.buttons["formSaveButton"].tap()
            } else {
                break
            }
        }
        XCTAssertTrue(app.buttons["paywallSubscribeButton"].waitForExistence(timeout: 3))
    }

    func testKeyboardDismissOnTapOutside() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["addEntryButton"].tap()
        let titleField = app.textFields["titleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 3))
        titleField.tap()
        titleField.typeText("Dismiss Me")
        XCTAssertTrue(app.keyboards.element.exists)
        app.staticTexts["Details"].tap()
        XCTAssertFalse(app.keyboards.element.exists)
    }

    func testSettingsSheetOpens() throws {
        let app = XCUIApplication()
        app.launch()
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.buttons["settingsDoneButton"].waitForExistence(timeout: 3))
        app.buttons["settingsDoneButton"].tap()
    }
}
