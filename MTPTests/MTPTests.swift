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
        guard let infoPlist = Bundle.main.infoDictionary else {
            return XCTFail("missing infoDictionary")
        }

        // AppCenter
        let urlType = (infoPlist["CFBundleURLTypes"] as? [AnyObject])?.first as? [String: AnyObject]
        let urlScheme = (urlType?["CFBundleURLSchemes"] as? [String])?.first
        let appcenter = "appcenter-20cb945f-58b9-4544-a059-424aa3b86820"
        appcenter.assert(equal: urlScheme)

        // Facebook
        XCTAssertNotNil(infoPlist["FacebookAppID"])
        XCTAssertNotNil(infoPlist["FacebookDisplayName"])
        XCTAssertNotNil(infoPlist["LSApplicationQueriesSchemes"])

        // Location Services, iOS 11+
        XCTAssertNotNil(infoPlist["NSLocationAlwaysAndWhenInUseUsageDescription"])
        XCTAssertNotNil(infoPlist["NSLocationWhenInUseUsageDescription"])
        // Location Services, iOS <= 10
        XCTAssertNotNil(infoPlist["NSLocationAlwaysUsageDescription"])
    }

    func testResources() throws {
        try R.validate()

        XCTAssertNotNil(R.file.podsMTPMetadataPlist())
        XCTAssertNotNil(R.file.podsMTPSettingsMetadataPlist())
        XCTAssertNotNil(R.file.settingsBundle())

        XCTAssertNotNil(R.image.launchBackground())
        XCTAssertNotNil(R.image.logo())
        XCTAssertNotNil(R.image.tabLocations())
        XCTAssertNotNil(R.image.tabMyProfile())
        XCTAssertNotNil(R.image.tabRankings())

        XCTAssertNotNil(R.storyboard.launchScreen())
        XCTAssertNotNil(R.storyboard.login())
        XCTAssertNotNil(R.storyboard.main())
        XCTAssertNotNil(R.storyboard.root())
        XCTAssertNotNil(R.storyboard.signup())
    }

    func testAppDelegateConfiguration() {
        let app = UIApplication.shared
        let delegate = app.delegate as? AppDelegate
        XCTAssertNotNil(delegate, "sharedApplication().delegate does not exist - set host application")
        XCTAssertNotNil(delegate?.window, "missing main window")

        let root = delegate?.window?.rootViewController as? UINavigationController
        XCTAssertNotNil(root, "missing root navigation controller")
        XCTAssertEqual(root?.viewControllers.count, 1)
        let splash = root?.viewControllers.first as? RootVC
        XCTAssertNotNil(splash, "missing splash screen controller")

        //let main = root?.topViewController as? UITabBarController
        //XCTAssertNotNil(main, "missing main tab controller")
        //XCTAssertEqual(main?.viewControllers?.count, 2, "wrong number of tabs")
        //XCTAssertNotNil(main?.viewControllers?[0] as? FirstViewController, "wrong first view controller")
        //XCTAssertNotNil(main?.viewControllers?[1] as? SecondViewController, "wrong second view controller")

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
