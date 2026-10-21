import XCTest

final class MotionfitMetaQA: XCTestCase {
    let app = XCUIApplication(bundleIdentifier: "fit.motionfit.app")
    func capture(_ name: String) {
        print("LOADS_ALLOWED_UI \(name)\n\(app.debugDescription)")
        let image = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        image.name = name
        image.lifetime = .keepAlways
        add(image)
    }
    func prepare() {
        continueAfterFailure = false
        app.terminate()
        app.launch()
        let select = app.buttons["Test production ad service"]
        XCTAssertTrue(select.waitForExistence(timeout: 20))
        select.tap()
        let show = app.buttons["Show interstitial + reload banner"]
        XCTAssertTrue(show.waitForExistence(timeout: 20))
        expectation(for: NSPredicate(format: "enabled == true"), evaluatedWith: show)
        waitForExpectations(timeout: 60)
        sleep(12)
    }
    func testFixedInterstitial() {
        prepare()
        capture("before-show")
        app.buttons["Show interstitial + reload banner"].tap()
        let close = app.buttons["Close"]
        XCTAssertTrue(close.waitForExistence(timeout: 30), "No interstitial close control")
        sleep(5)
        capture("interstitial-visible-next-loads")
        close.tap()
        // Reading the Flutter AX hierarchy here triggered a pre-existing
        // native semantics/CODESIGNING crash. Validate saved SDK telemetry.
        sleep(3)
        let dismissed = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        dismissed.name = "interstitial-dismissed-screen-only"
        dismissed.lifetime = .keepAlways
        add(dismissed)
        XCUIDevice.shared.press(.home)
        XCTAssertTrue(app.wait(for: .runningBackground, timeout: 10))
        sleep(2)
        app.activate()
        sleep(3)
        let returned = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        returned.name = "real-background-return-screen-only"
        returned.lifetime = .keepAlways
        add(returned)
    }
    func testFixedAppOpen() {
        prepare()
        app.buttons["Prime app-open"].tap()
        sleep(12)
        app.buttons["Show app-open"].tap()
        sleep(5)
        capture("app-open-visible-next-loads")
        let close = app.buttons["Close"]
        if close.waitForExistence(timeout: 10) {
            close.tap()
            sleep(3)
            let image = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
            image.name = "app-open-dismissed-screen-only"
            image.lifetime = .keepAlways
            add(image)
        }
    }
    func testSnapshot() {
        app.activate()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 20))
        let image = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        image.name = "normal-app-restored"
        image.lifetime = .keepAlways
        add(image)
    }
}
