// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class MTPDelegateTests: MTPTestCase {

    func testUnitTestingHandlerList() throws {
        // given
        let expected: [String] = []

        // when
        let delegate = try XCTUnwrap(UIApplication.shared.delegate as? MTPDelegate)
        let actual = delegate.handlers.map { String(describing: type(of: $0)) }

        // then
        XCTAssertEqual(expected, actual)
    }

    func testProductionHandlerList() {
        // given
        let expected = [
            String(describing: ServiceHandler.self),
            String(describing: LaunchHandler.self),
            String(describing: StateHandler.self),
            String(describing: ActionHandler.self),
            String(describing: NotificationsHandler.self),
            String(describing: LocationHandler.self)
        ]

        // when
        let actual = MTPDelegate.runtimeHandlers(for: .production)
                                .map { String(describing: type(of: $0)) }

        // then
        XCTAssertEqual(expected, actual)
    }

    func testUITestingHandlerList() {
        // given
        let expected = [
            String(describing: ServiceHandlerStub.self),
            String(describing: LaunchHandler.self),
            String(describing: StateHandler.self),
            String(describing: ActionHandler.self),
            String(describing: NotificationsHandler.self),
            String(describing: LocationHandler.self)
        ]

        // when
        let actual = MTPDelegate.runtimeHandlers(for: .uiTesting)
                                .map { String(describing: type(of: $0)) }

        // then
       XCTAssertEqual(expected, actual)
    }

    func testAppDelegateConfiguration() {
        let app = UIApplication.shared
        let delegate = app.delegate as? MTPDelegate
        XCTAssertNotNil(delegate, "sharedApplication().delegate does not exist - set host application")
        XCTAssertNotNil(delegate?.window, "missing main window")

        let root = delegate?.window?.rootViewController as? UINavigationController
        XCTAssertNotNil(root, "missing root navigation controller")
        XCTAssertEqual(root?.viewControllers.count, 1)
        let splash = root?.viewControllers.first as? RootVC
        XCTAssertNotNil(splash, "missing splash screen controller")

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
        guard let delegate = app.delegate as? MTPDelegate else {
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

        // No current handling
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

        // Facebook
        let urlType = (infoPlist["CFBundleURLTypes"] as? [AnyObject])?.first as? [String: AnyObject]
        let urlScheme = (urlType?["CFBundleURLSchemes"] as? [String])?.first
        let facebook = "fb970945913071007"
        facebook.assert(equal: urlScheme)
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

        XCTAssertNotNil(R.file.defaultRealm())
        XCTAssertNotNil(R.file.podsMTPMetadataPlist())
        XCTAssertNotNil(R.file.podsMTPSettingsMetadataPlist())
        XCTAssertNotNil(R.file.settingsBundle())
        XCTAssertNotNil(R.file.worldMapGeojson())
    }
}
