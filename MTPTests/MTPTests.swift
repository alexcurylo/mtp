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

    func testUserDefaults() {
        let defaults = UserDefaults.standard
        StringKey.infoDictionarySettingsKeys.forEach { key in
            XCTAssertNotNil(defaults[key], "missing Settings display key: \(key)")
        }
    }

    func testInfoPlist() {
        let infoPlist = Bundle.main.infoDictionary

        // AppCenter
        let urlType = (infoPlist?["CFBundleURLTypes"] as? [AnyObject])?.first as? [String: AnyObject]
        let urlScheme = (urlType?["CFBundleURLSchemes"] as? [String])?.first
        let expected = "appcenter-20cb945f-58b9-4544-a059-424aa3b86820"
        XCTAssertEqual(urlScheme, expected, "could not find AppCenter Distribution URL scheme")
    }

    func testResources() throws {
        try R.validate()

        XCTAssertNotNil(R.file.default568h2xPng)
        XCTAssertNotNil(R.file.podsMTPMetadataPlist)
        XCTAssertNotNil(R.file.podsMTPSettingsMetadataPlist)
        XCTAssertNotNil(R.file.settingsBundle)

        XCTAssertNotNil(R.image.first)
        XCTAssertNotNil(R.image.second)
        XCTAssertNotNil(R.image.default568h)

        XCTAssertNotNil(R.storyboard.launchScreen)
        XCTAssertNotNil(R.storyboard.main)
    }

    func testAppDelegateConfiguration() {
        let app = UIApplication.shared
        let delegate = app.delegate as? AppDelegate
        XCTAssertNotNil(delegate, "sharedApplication().delegate does not exist - set host application")
        XCTAssertNotNil(delegate?.window, "missing main window")

        let root = delegate?.window?.rootViewController as? UITabBarController
        XCTAssertNotNil(root, "missing root tab controller")
        XCTAssertEqual(root?.viewControllers?.count, 2, "wrong number of tabs")
        XCTAssertNotNil(root?.viewControllers?[0] as? FirstViewController, "wrong first view controller")
        XCTAssertNotNil(root?.viewControllers?[1] as? SecondViewController, "wrong second view controller")

        XCTAssertTrue(UIApplication.isUnitTesting)
        XCTAssertFalse(UIApplication.isUITesting)
        XCTAssertTrue(UIApplication.isTesting)
        #if targetEnvironment(simulator)
        XCTAssertTrue(UIApplication.isSimulator)
        #else
        XCTAssertFalse(UIApplication.isSimulator)
        #endif
    }

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

    func testLowMemoryHandling() {
        let app = UIApplication.shared

        // Note we rely on MemoryWarner.h via the bridging header to expose private selector
        UIControl().sendAction(#selector(UIApplication._performMemoryWarning), to: app, for: nil)

        // Currently implemented without effect aside from console notes:
        // INFO: AppDelegate applicationDidReceiveMemoryWarning
        // INFO: FirstViewController didReceiveMemoryWarning
        // INFO: SecondViewController didReceiveMemoryWarning
    }
}
