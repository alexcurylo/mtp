// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class MTPTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    /// check that setup, target plist and main storyboard are good
    func testAppDelegateConfiguration() {
        let app = UIApplication.shared
        let delegate = app.delegate as? AppDelegate
        XCTAssertNotNil(delegate, "sharedApplication().delegate does not exist - set host application")
        XCTAssertNotNil(delegate?.window, "missing main window")
        let root = delegate?.window?.rootViewController as? UITabBarController
        XCTAssertNotNil(root, "missing root tab controller")
        XCTAssert(root?.viewControllers?.count == 2, "wrong number of tabs")
        XCTAssertNotNil(root?.viewControllers?[0] as? FirstViewController, "wrong first view controller")
        XCTAssertNotNil(root?.viewControllers?[1] as? SecondViewController, "wrong second view controller")
    }

    /// check for any fatal UIApplicationDelegate side effects
    func testAppDelegateDelegation() {
        let app = UIApplication.shared
        guard let delegate = app.delegate as? AppDelegate else {
            return XCTFail("unexpected app delegate class")
        }

        delegate.applicationWillResignActive(app)
        delegate.applicationDidEnterBackground(app)
        delegate.applicationWillEnterForeground(app)
        delegate.applicationDidBecomeActive(app)
        delegate.applicationWillTerminate(app)
    }

    // Check low memory handlers are called
    func testLowMemoryHandling() {
        let app = UIApplication.shared

        // Note we rely on MemoryWarner.h via the bridging header to expose private selector
        UIControl().sendAction(#selector(UIApplication._performMemoryWarning), to: app, for: nil)

        // Currently implemented without effect aside from console notes:
        // INFO: AppDelegate applicationDidReceiveMemoryWarning
        // INFO: FirstViewController didReceiveMemoryWarning
        // INFO: SecondViewController didReceiveMemoryWarning
    }

    func testAppResources() {
        // items copied to NSUserDefaults from plist for settings
        let defaults = UserDefaults.standard
        ["CFBundleShortVersionString",
         "CFBundleVersion",
         "CFBuildDate"].forEach { key in
            XCTAssertNotNil(defaults.object(forKey: key), "missing Settings display key: \(key)")
        }
    }
}
