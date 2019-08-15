// @copyright Trollwerks Inc.

import UIKit
import UserNotifications

/// Stub for startup construction
final class NotificationsHandler: NSObject, AppHandler, ServiceProvider { }

// MARK: - AppLaunchHandler

extension NotificationsHandler: AppLaunchHandler {

    /// willFinishLaunchingWithOptions
    ///
    /// - Parameters:
    ///   - application: Application
    ///   - launchOptions: Launch options
    /// - Returns: Success
    func application(_ application: UIApplication,
                     // swiftlint:disable:next discouraged_optional_collection
                     willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    /// didFinishLaunchingWithOptions
    ///
    /// - Parameters:
    ///   - application: Application
    ///   - launchOptions: Launch options
    /// - Returns: Success
    func application(_ application: UIApplication,
                     // swiftlint:disable:next discouraged_optional_collection
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
         let congratulate = UNNotificationCategory(
            identifier: Note.Category.congratulate.identifier,
            actions: [],
            intentIdentifiers: [],
            options: []
        )

        let information = UNNotificationCategory(
            identifier: Note.Category.information.identifier,
            actions: [],
            intentIdentifiers: [],
            options: []
        )

        let checkin = UNNotificationAction(
            identifier: L.checkinAction(),
            title: L.checkinAction(),
            options: []
        )
        let dismiss = UNNotificationAction(
            identifier: L.dismissAction(),
            title: L.dismissAction(),
            options: []
        )
        let visit = UNNotificationCategory(
            identifier: Note.Category.visit.identifier,
            actions: [checkin, dismiss],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([
            congratulate,
            information,
            visit
        ])
        UNUserNotificationCenter.current().delegate = self

        return true
    }
}

// MARK: - AppNotificationsHandler

extension NotificationsHandler: AppNotificationsHandler {

    /// didRegisterForRemoteNotificationsWithDeviceToken
    ///
    /// - Parameters:
    ///   - application: Application
    ///   - deviceToken: Token
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.reduce(into: "") { $0 += String(format: "%.2x", $1) }
        // dev: 4159c48ab8466e4450b1de594c6df3a0879dc6e754b7faa4ae43467336178a4f
        net.userUpdate(token: token) { _ in }
    }

    /// didFailToRegisterForRemoteNotificationsWithError
    ///
    /// - Parameters:
    ///   - application: Application
    ///   - error: Error
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        log.error("register for remote notifications: \(error)")
    }

    /// didReceiveRemoteNotification
    ///
    /// - Parameters:
    ///   - application: Application
    ///   - userInfo: Info
    ///   - completionHandler: Callback
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        // called if payload includes content-available
        // otherwise just willPresent:notification: called in foreground
        //{
        //    "aps":{
        //        "alert":"Test",
        //        "sound":"default",
        //        "badge":1,
        //        "content-available":1
        //    },
        //    "test":"value"
        //}
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationsHandler: UNUserNotificationCenterDelegate {

    /// Handle user response
    ///
    /// - Parameters:
    ///   - center: UNUserNotificationCenter
    ///   - response: user response
    ///   - completionHandler: Callback
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        guard let listValue = userInfo[Note.ChecklistItemInfo.list.key] as? Int,
              let list = Checklist(rawValue: listValue),
              let id = userInfo[Note.ChecklistItemInfo.id.key] as? Int else { return }

        switch response.actionIdentifier {
        case L.dismissAction():
            list.set(dismissed: true, id: id)
        case L.checkinAction():
            handle(checkin: (list, id))
        case UNNotificationDefaultActionIdentifier,
             UNNotificationDismissActionIdentifier:
            break
        default:
            log.error("unexpected notification: \(response.actionIdentifier)")
        }

        completionHandler()
    }

    /// Present notification
    ///
    /// - Parameters:
    ///   - center: UNUserNotificationCenter
    ///   - notification: Notification to present
    ///   - completionHandler: Callback
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        completionHandler( [.alert, .badge, .sound])
    }

    // also need requestAuthorization(options: [.alert, .badge, .sound, .providesAppNotificationSettings]) { ... }
    //func userNotificationCenter(_ center: UNUserNotificationCenter,
                                //openSettingsFor notification: UNNotification?) {
        //let navController = self.window?.rootViewController as! UINavigationController
        //let notificationSettingsVC = NotificationSettingsViewController()
       // navController.pushViewController(notificationSettingsVC, animated: true)
    // }
}

// MARK: - Private

private extension NotificationsHandler {

    func handle(checkin item: Checklist.Item) {
        note.set(item: item,
                 visited: true,
                 congratulate: true) { result in
            if case let .failure(message) = result {
                self.note.post(error: message)
            }
        }
    }
}
