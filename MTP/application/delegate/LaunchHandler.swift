// @copyright Trollwerks Inc.

import FBSDKCoreKit
import Firebase
import SwiftyBeaver

/// Stub for startup construction
struct LaunchHandler: AppHandler, ServiceProvider { }

// MARK: - AppLaunchHandler

extension LaunchHandler: AppLaunchHandler {

    /// willFinishLaunchingWithOptions
    /// - Parameters:
    ///   - application: Application
    ///   - launchOptions: Launch options
    /// - Returns: Success
    func application(_ application: UIApplication,
                     // swiftlint:disable:next discouraged_optional_collection
                     willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ProcessInfo.startup()

        return true
    }

    /// didFinishLaunchingWithOptions
    /// - Parameters:
    ///   - application: Application
    ///   - launchOptions: Launch options
    /// - Returns: Success
    func application(_ application: UIApplication,
                     // swiftlint:disable:next discouraged_optional_collection
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let options = launchOptions ?? [:]

        configureLogging()

        configureFirebase()

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
        StringKey.configureSettingsDisplay()
    }

    func configureAppearance() {
        style.styler.standard.styleAppearance()
    }
}

// MARK: - SwiftyBeaver

// https://docs.swiftybeaver.com

private let swiftyBeaver = SwiftyBeaver.self

/// Wraps SwiftyBeaver API
struct SwiftyBeaverLoggingService: LoggingService {

    /// Wrap point for log API integration
    /// - Parameters:
    ///   - level: LoggingLevel
    ///   - message: Describable autoclosure
    ///   - file: File marker
    ///   - function: Function marker
    ///   - line: Line marker
    ///   - context: If service requires such
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

private extension LaunchHandler {

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

// MARK: - Facebook

// https://developers.facebook.com/docs/swift/login
// https://developers.facebook.com/docs/facebook-login/testing-your-login-flow/

private extension LaunchHandler {

    func configureFacebook(app: UIApplication,
                           options: [UIApplication.LaunchOptionsKey: Any]) {
        ApplicationDelegate.shared.application(
            app,
            didFinishLaunchingWithOptions: options
        )
    }
}

// MARK: - Firebase

private extension LaunchHandler {

    // https://www.lordcodes.com/posts/a-modular-analytics-layer-in-swift
    // https://firebase.google.com/docs/analytics/ios/start

    func configureFirebase() {
        guard UIApplication.isProduction else { return }

        FirebaseApp.configure()

        //Crashlytics.sharedInstance().crash()
    }
}
