// @copyright Trollwerks Inc.

import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import AppCenterDistribute
import FacebookCore
import SwiftyBeaver

// MARK: - AppCenter

// https://docs.microsoft.com/en-us/appcenter/

extension AppDelegate {

    func configureAppCenter() {
        guard !UIApplication.isTesting else { return }

        MSAppCenter.start("20cb945f-58b9-4544-a059-424aa3b86820",
                          withServices: [MSAnalytics.self,
                                         MSCrashes.self,
                                         MSDistribute.self])
        log.verbose("MSAppCenter started")
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

// MARK: - SwiftyBeaver

//https://docs.swiftybeaver.com

let swiftyBeaver = SwiftyBeaver.self

extension AppDelegate {

    func configureLogging() {

        let console = ConsoleDestination()
        swiftyBeaver.addDestination(console)

        let file = FileDestination()
        if UIApplication.isSimulator {
            // tail -f /tmp/swiftybeaver.log
            file.logFileURL = URL(fileURLWithPath: "/tmp/swiftybeaver.log")
        }
        swiftyBeaver.addDestination(file)

        if !UIApplication.isTesting {
            let platform = SBPlatformDestination(
                appID: "YbnQz9 ",
                appSecret: "qyictm2bUy3Kvqi0dUpgysuUayuuJ1Py ",
                encryptionKey: "wdybYid5fohynFuy7pzjgcdmmXedin0m")
            swiftyBeaver.addDestination(platform)
        }
    }
}

// MARK: - Facebook

// https://developers.facebook.com/docs/swift/login
// https://developers.facebook.com/docs/facebook-login/testing-your-login-flow/

extension AppDelegate {

    func configureFacebook(app: UIApplication,
                           options: [UIApplication.LaunchOptionsKey: Any]) {
        SDKApplicationDelegate.shared.application(
            app,
            didFinishLaunchingWithOptions: options)
    }

    func handleFacebookURL(app: UIApplication,
                           open url: URL,
                           options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return SDKApplicationDelegate.shared.application(
            app,
            open: url,
            options: options)
    }

    func logFacebookActivate() {
        AppEventsLogger.activate()
    }
}
