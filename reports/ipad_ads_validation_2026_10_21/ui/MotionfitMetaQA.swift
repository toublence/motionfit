import XCTest

final class MotionfitMetaQA: XCTestCase {
    let app = XCUIApplication(bundleIdentifier: "fit.motionfit.app")
    func capture(_ name: String) {
        print("IPAD_ADS_STATE \(name)\n\(app.debugDescription)")
        let image = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        image.name = name
        image.lifetime = .keepAlways
        add(image)
    }
    func testSnapshot() {
        app.activate()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 30))
        capture("initial")
    }
    func testBannerLifecycle() {
        continueAfterFailure = false
        app.activate()
        let banner = app.staticTexts["Test mode"]
        XCTAssertTrue(banner.waitForExistence(timeout: 30), "Google test banner missing")
        let viewsBefore = app.otherElements.matching(NSPredicate(format: "identifier BEGINSWITH %@", "platform_view[")).allElementsBoundByIndex.map { $0.identifier }
        print("BANNER_VIEWS_BEFORE \(viewsBefore)")
        capture("banner-before-inactive")
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.99, dy: 0.005))
        start.press(forDuration: 0.1, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.75, dy: 0.5)))
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        print("CONTROL_CENTER_STATE\n\(springboard.debugDescription)")
        capture("banner-under-control-center")
        print("BANNER_EXISTS_DURING_INACTIVE \(banner.exists)")
        let viewsDuring = app.otherElements.matching(NSPredicate(format: "identifier BEGINSWITH %@", "platform_view[")).allElementsBoundByIndex.map { $0.identifier }
        print("BANNER_VIEWS_DURING \(viewsDuring)")
        // Dismiss the system overlay without changing any system settings.
        springboard.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.5)).tap()
        app.activate()
        XCTAssertTrue(banner.waitForExistence(timeout: 15), "Banner missing after inactive")
        let viewsAfter = app.otherElements.matching(NSPredicate(format: "identifier BEGINSWITH %@", "platform_view[")).allElementsBoundByIndex.map { $0.identifier }
        print("BANNER_VIEWS_AFTER \(viewsAfter)")
        XCTAssertEqual(viewsBefore, viewsDuring, "Inactive recreated or detached the native ad view")
        XCTAssertEqual(viewsBefore, viewsAfter, "Returning from inactive recreated the native ad view")
        capture("banner-after-inactive")
        XCUIDevice.shared.press(.home)
        XCTAssertTrue(app.wait(for: .runningBackground, timeout: 10))
        app.activate()
        XCTAssertTrue(banner.waitForExistence(timeout: 20), "Banner missing after background return")
        capture("banner-after-background")
    }
    func testProductionInterstitial() {
        continueAfterFailure = false
        app.terminate()
        app.launch()
        let select = app.buttons["Test production ad service"]
        XCTAssertTrue(select.waitForExistence(timeout: 20))
        select.tap()
        let show = app.buttons["Show interstitial"]
        XCTAssertTrue(show.waitForExistence(timeout: 20))
        expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: show)
        waitForExpectations(timeout: 60)
        sleep(12)
        capture("production-before-interstitial")
        show.tap()
        sleep(5)
        capture("production-interstitial-showing")
    }
    func testProductionAppOpen() {
        continueAfterFailure = false
        app.terminate()
        app.launch()
        let select = app.buttons["Test production ad service"]
        XCTAssertTrue(select.waitForExistence(timeout: 20))
        select.tap()
        let prime = app.buttons["Prime app-open"]
        XCTAssertTrue(prime.waitForExistence(timeout: 20))
        expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: prime)
        waitForExpectations(timeout: 60)
        prime.tap()
        sleep(12)
        capture("production-app-open-primed")
        app.buttons["Show app-open"].tap()
        sleep(5)
        capture("production-app-open-showing")
    }
    func testCloseGoogleAd() {
        app.activate()
        let close = app.buttons["Close"]
        XCTAssertTrue(close.waitForExistence(timeout: 30))
        close.tap()
        capture("google-ad-dismissed")
    }
    func testMetaSource() { mediation(meta: true) }
    func testUnitySource() { mediation(meta: false) }
    func mediation(meta: Bool) {
        continueAfterFailure = false
        app.terminate()
        app.launch()
        let select = app.buttons[meta ? "Test Meta" : "Test Unity"]
        XCTAssertTrue(select.waitForExistence(timeout: 20))
        select.tap()
        let open = app.buttons["Open Ad Inspector"]
        XCTAssertTrue(open.waitForExistence(timeout: 20))
        expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: open)
        waitForExpectations(timeout: 90)
        open.tap()
        let toggle = app.switches.firstMatch
        XCTAssertTrue(toggle.waitForExistence(timeout: 20))
        if toggle.value as? String == "1" {
            toggle.tap()
            if app.buttons["Stop test"].exists { app.buttons["Stop test"].tap() }
        }
        toggle.tap()
        let source = app.staticTexts[meta ? "Meta Audience Network (Bidding)" : "Unity Ads (Bidding)"]
        XCTAssertTrue(source.waitForExistence(timeout: 15))
        source.tap()
        app.buttons["Start test"].tap()
        app.buttons["Close"].tap()
        app.buttons[meta ? "Load Meta interstitial" : "Load Unity interstitial"].tap()
        sleep(20)
        capture(meta ? "meta-source-result" : "unity-source-result")
    }
    func testFinishMediation() {
        continueAfterFailure = false
        app.activate()
        let close = app.buttons["Close"].exists ? app.buttons["Close"] : app.buttons.matching(NSPredicate(format: "label == ''")).firstMatch
        XCTAssertTrue(close.waitForExistence(timeout: 20))
        close.tap()
        let passed = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "PASS")).firstMatch
        XCTAssertTrue(passed.waitForExistence(timeout: 15), "No impression/dismissal PASS callback")
        capture("mediation-dismissed-pass")
        app.buttons["Open Ad Inspector"].tap()
        let toggle = app.switches.firstMatch
        XCTAssertTrue(toggle.waitForExistence(timeout: 20))
        if toggle.value as? String == "1" { toggle.tap() }
        if app.buttons["Stop test"].exists { app.buttons["Stop test"].tap() }
        XCTAssertEqual(toggle.value as? String, "0")
        app.buttons["Close"].tap()
        capture("single-source-disabled")
    }
    func testCloseUnityStoreCard() {
        app.activate()
        let close = app.buttons["닫기"]
        XCTAssertTrue(close.waitForExistence(timeout: 15))
        close.tap()
        capture("unity-store-card-closed")
    }
}
