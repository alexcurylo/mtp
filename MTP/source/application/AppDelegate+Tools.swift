// @copyright Trollwerks Inc.

import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import AppCenterDistribute
import FacebookLogin
import SwiftyBeaver

let log = SwiftyBeaver.self

extension AppDelegate {

    func configureAppCenter() {
        // https://docs.microsoft.com/en-us/appcenter/

        guard !UIApplication.isTesting else { return }

        MSAppCenter.start("20cb945f-58b9-4544-a059-424aa3b86820",
                          withServices: [MSAnalytics.self,
                                         MSCrashes.self,
                                         MSDistribute.self])
        log.info("MSAppCenter started")
    }

    func configureLogging() {
        //https://docs.swiftybeaver.com

        let console = ConsoleDestination()
        log.addDestination(console)

        let file = FileDestination()
        if UIApplication.isSimulator {
            // tail -f /tmp/swiftybeaver.log
            file.logFileURL = URL(fileURLWithPath: "/tmp/swiftybeaver.log")
        }
        log.addDestination(file)

        if !UIApplication.isTesting {
            let platform = SBPlatformDestination(
                appID: "YbnQz9 ",
                appSecret: "qyictm2bUy3Kvqi0dUpgysuUayuuJ1Py ",
                encryptionKey: "wdybYid5fohynFuy7pzjgcdmmXedin0m")
            log.addDestination(platform)
        }
    }

    func configureFacebook(app: UIApplication,
                           options: [UIApplicationLaunchOptionsKey: Any]) {
        SDKApplicationDelegate.shared.application(app, didFinishLaunchingWithOptions: options)
    }
}
