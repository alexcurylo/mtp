// @copyright Trollwerks Inc.

import FBSDKCoreKit
import Firebase
import Siren
import SwiftyBeaver

/// Stub for startup construction
struct LaunchHandler: AppHandler { }

// MARK: - AppLaunchHandler

extension LaunchHandler: AppLaunchHandler, ServiceProvider {

    /// willFinishLaunchingWithOptions
    /// - Parameters:
    ///   - application: Application
    ///   - launchOptions: Launch options
    /// - Returns: Success
    func application(
        _ application: UIApplication,
        // swiftlint:disable:next discouraged_optional_collection
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        ProcessInfo.startup()

        return true
    }

    /// didFinishLaunchingWithOptions
    /// - Parameters:
    ///   - application: Application
    ///   - launchOptions: Launch options
    /// - Returns: Success
    func application(
        _ application: UIApplication,
        // swiftlint:disable:next discouraged_optional_collection
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let options = launchOptions ?? [:]

        configure(logging: UIApplication.isProduction)

        configureFirebase()

        configureNetworking()

        configureSettingsDisplay()

        configureFacebook(app: application, options: options)

        configureAppearance()

        configureUpgrades()

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

    func configureUpgrades() {
        var force: Bool { false } // Placeholder for possible API check

        let siren = Siren.shared
        if force {
            siren.rulesManager = RulesManager(
                globalRules: .critical,
                showAlertAfterCurrentVersionHasBeenReleasedForDays: 0)
        } else {
            siren.rulesManager = RulesManager(globalRules: .annoying)
        }
        siren.wail()
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
        let sbLevel = SwiftyBeaver.Level(from: level)
        swiftyBeaver.custom(level: sbLevel,
                            message: message(),
                            file: file,
                            function: function,
                            line: line,
                            context: context)
    }
}

private extension SwiftyBeaver.Level {

    init(from: LoggingLevel) {
        switch from {
        case .verbose: self = .verbose
        case .debug: self = .debug
        case .info: self = .info
        case .warning: self = .warning
        case .error: self = .error
        }
    }
}

extension LaunchHandler {

    /// Configure logging
    /// - Parameter production: Is this production environment?
    func configure(logging production: Bool) {
        let console = ConsoleDestination()
        swiftyBeaver.addDestination(console)

        let file = FileDestination()
        if UIApplication.isSimulator {
            // tail -f /tmp/swiftybeaver.log
            file.logFileURL = URL(fileURLWithPath: "/tmp/swiftybeaver.log")
        }
        swiftyBeaver.addDestination(file)

        if production {
            let platform = SBPlatformDestination(
                appID: Secrets.sbAppID.secret,
                appSecret: Secrets.sbAppSecret.secret,
                encryptionKey: Secrets.sbEncryptionKey.secret)
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

        // Crashlytics.sharedInstance().crash()
    }
}
