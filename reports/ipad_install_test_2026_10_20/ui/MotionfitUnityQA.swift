import XCTest
final class MotionfitUnityQA: XCTestCase {
    let app = XCUIApplication(bundleIdentifier: "fit.motionfit.app")
    func capture(_ name: String) {
        let image = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        image.name = name
        image.lifetime = .keepAlways
        add(image)
        print("MOTIONFIT_IPAD_UI \(name)\n\(app.debugDescription)\nMOTIONFIT_IPAD_UI_END")

    }
    func testOnboarding() {
        app.activate()
        sleep(2)
        for step in 1...3 {
            app.coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: 410, dy: 1112)).tap()
            sleep(2)
            capture("onboarding-step-\(step)")
        }
    }
    func testContinue() {
        app.activate()
        XCTAssertTrue(app.buttons["계속"].waitForExistence(timeout: 10))
        app.buttons["계속"].tap()
        sleep(3)
        capture("after-explainer")
        print("PERMISSION_UI\n\(XCUIApplication(bundleIdentifier: "com.apple.springboard").debugDescription)")
    }
    func testNavigation() {
        continueAfterFailure = false
        app.activate()
        if app.buttons["마치기"].exists { app.buttons["마치기"].tap() }
        sleep(5)
        capture("workout-finished")
        for label in ["성장", "설정", "운동"] {
            let button = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", label)).firstMatch
            XCTAssertTrue(button.waitForExistence(timeout: 20), "Missing navigation: \(label)")
            button.tap()
            sleep(2)
            capture("navigation-\(label)")
        }
        XCUIDevice.shared.press(.home)
        sleep(2)
        app.activate()
        sleep(4)
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "설정")).firstMatch.waitForExistence(timeout: 15))
        capture("foreground-restored")
    }
    func testSystem() {
        let sb = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        print("SPRINGBOARD_ONLY\n\(sb.debugDescription)")
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    func testSnapshot() {
        app.activate()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 30))
        sleep(4)
        capture("installed-app")
    }
}
