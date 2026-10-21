import XCTest

// Run after installing tool/meta_ads_device_test.dart with META_ADS_QA.
final class MotionfitMetaQA: XCTestCase {
    func testMetaInterstitial() {
        continueAfterFailure = false
        let app = XCUIApplication(bundleIdentifier: "fit.motionfit.app")
        app.activate()
        let open = app.buttons["Open Ad Inspector"]
        XCTAssertTrue(open.waitForExistence(timeout: 90))
        expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: open)
        waitForExpectations(timeout: 90)
        open.tap()
        let toggle = app.switches.firstMatch
        XCTAssertTrue(toggle.waitForExistence(timeout: 15))
        if toggle.value as? String == "0" {
            toggle.tap()
            let meta = app.staticTexts["Meta Audience Network (Bidding)"]
            XCTAssertTrue(meta.waitForExistence(timeout: 10))
            meta.tap()
            app.buttons["Start test"].tap()
        }
        XCTAssertTrue(app.staticTexts["Meta Audience Network (Bidding)"].exists)
        app.buttons["Close"].tap()
        defer {
            if open.exists && open.isHittable {
                open.tap()
                if toggle.waitForExistence(timeout: 10), toggle.value as? String == "1" {
                    toggle.tap()
                }
                if app.buttons["Stop test"].exists { app.buttons["Stop test"].tap() }
                if app.buttons["Close"].exists { app.buttons["Close"].tap() }
            }
        }
        app.buttons["Load Meta interstitial"].tap()
        sleep(20)
        print("META_AD_RESULT\n\(app.debugDescription)")
        let capture = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        capture.lifetime = .keepAlways
        add(capture)
        XCTAssertFalse(app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "FAIL load:")
        ).firstMatch.exists, "Meta did not provide an ad; inspect meta-ads-qa.log")
        // Check native meta-ads-qa.log for loadedAdapter, showed, impression,
        // dismissed and PASS. UI driver success alone is not an ad success.
    }
    func testFinishAndDisableSingleSource() {
        let app = XCUIApplication(bundleIdentifier: "fit.motionfit.app")
        app.activate()
        let close = app.buttons.matching(NSPredicate(format: "label == ''")).firstMatch
        XCTAssertTrue(close.waitForExistence(timeout: 10))
        close.tap()
        let passed = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "PASS")).firstMatch
        XCTAssertTrue(passed.waitForExistence(timeout: 10), "No successful impression/dismissal result")
        print("META_DISMISSED\n\(app.debugDescription)")
        app.buttons["Open Ad Inspector"].tap()
        let toggle = app.switches.firstMatch
        XCTAssertTrue(toggle.waitForExistence(timeout: 15))
        if toggle.value as? String == "1" { toggle.tap() }
        if app.buttons["Stop test"].exists { app.buttons["Stop test"].tap() }
        XCTAssertEqual(toggle.value as? String, "0")
        print("META_DISABLED\n\(app.debugDescription)")
        app.buttons["Close"].tap()
    }

}
