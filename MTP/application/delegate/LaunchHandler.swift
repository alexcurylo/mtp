// @copyright Trollwerks Inc.

import AlamofireNetworkActivityIndicator
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import FBSDKCoreKit
import SwiftyBeaver

struct LaunchHandler: AppHandler, ServiceProvider { }

// MARK: - AppLaunchHandler

extension LaunchHandler: AppLaunchHandler {

    func application(_ application: UIApplication,
                     // swiftlint:disable:next discouraged_optional_collection
                     willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func application(_ application: UIApplication,
                     // swiftlint:disable:next discouraged_optional_collection
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let options = launchOptions ?? [:]

        configureLogging()

        configureAppCenter()

        configureNetworking()

        configureSettingsDisplay()

        configureFacebook(app: application, options: options)

        configureAppearance()

        return true
    }
}

// MARK: - Private

private extension LaunchHandler {

    func configureNetworking() {
        NetworkActivityIndicatorManager.shared.isEnabled = true
        NetworkActivityIndicatorManager.shared.startDelay = 0.8
        NetworkActivityIndicatorManager.shared.completionDelay = 0.3
    }

    func configureSettingsDisplay() {
        StringKey.infoDictionarySettingsKeys.copyToUserDefaults()
    }

    func configureAppearance() {
        style.standard.styleAppearance()
    }
}

// MARK: - SwiftyBeaver

// https://docs.swiftybeaver.com

private let swiftyBeaver = SwiftyBeaver.self

struct SwiftyBeaverLoggingService: LoggingService {

    func custom(level: LoggingLevel,
                message: @autoclosure () -> Any,
                file: String,
                function: String,
                line: Int,
                context: Any?) {
        let sbLevel = SwiftyBeaver.Level(rawValue: level.rawValue) ?? .verbose
        swiftyBeaver.custom(level: sbLevel,
                            message: message(),
                            file: file,
                            function: function,
                            line: line,
                            context: context)
    }
}

extension LaunchHandler {

    func configureLogging() {

        let console = ConsoleDestination()
        swiftyBeaver.addDestination(console)

        let file = FileDestination()
        if UIApplication.isSimulator {
            // tail -f /tmp/swiftybeaver.log
            file.logFileURL = URL(fileURLWithPath: "/tmp/swiftybeaver.log")
        }
        swiftyBeaver.addDestination(file)

        if UIApplication.isProduction {
            let platform = SBPlatformDestination(
                appID: "YbnQz9",
                appSecret: "qyictm2bUy3Kvqi0dUpgysuUayuuJ1Py",
                encryptionKey: "wdybYid5fohynFuy7pzjgcdmmXedin0m")
            swiftyBeaver.addDestination(platform)
        }
    }
}

// MARK: - AppCenter

// https://docs.microsoft.com/en-us/appcenter/
// https://docs.microsoft.com/en-us/appcenter/sdk/crashes/ios
// https://docs.microsoft.com/en-us/appcenter/sdk/analytics/ios

extension LaunchHandler {

    func configureAppCenter() {
        guard UIApplication.isProduction else { return }

        MSAppCenter.start("20cb945f-58b9-4544-a059-424aa3b86820",
                          withServices: [MSAnalytics.self,
                                         MSCrashes.self])
    }

    #if PUSH_NOTIFICATIONS
    func onboardPush() {
        MSAppCenter.startService(MSPush.self)
        MSPush.setEnabled(true)
        center.requestAuthorization(options: [.alert, .badge, .carPlay, .sound]) { granted, err in
            if granted {
                log.verbose("push authorization granted")
            } else {
                log.verbose("push authorization failed: \(err)")
            }
        }
    }
    #endif
}

// MARK: - Facebook

// https://developers.facebook.com/docs/swift/login
// https://developers.facebook.com/docs/facebook-login/testing-your-login-flow/

extension LaunchHandler {

    func configureFacebook(app: UIApplication,
                           options: [UIApplication.LaunchOptionsKey: Any]) {
        ApplicationDelegate.shared.application(
            app,
            didFinishLaunchingWithOptions: options
        )
    }
}
