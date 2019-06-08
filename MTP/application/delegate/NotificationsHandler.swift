// @copyright Trollwerks Inc.

import UIKit
import UserNotifications

final class NotificationsHandler: NSObject, AppHandler, ServiceProvider {

    static let debugCategory = "debug"
    static let visitCategory = "visit"
    static let visitList = "list"
    static let visitId = "id"
}

// MARK: - AppLaunchHandler

extension NotificationsHandler: AppLaunchHandler {

    func application(_ application: UIApplication,
                     // swiftlint:disable:next discouraged_optional_collection
                     willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func application(_ application: UIApplication,
                     // swiftlint:disable:next discouraged_optional_collection
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let debug = UNNotificationCategory(
            identifier: NotificationsHandler.debugCategory,
            actions: [],
            intentIdentifiers: [],
            options: []
        )

        let checkin = UNNotificationAction(
            identifier: Localized.checkinAction(),
            title: Localized.checkinAction(),
            options: []
        )
        let dismiss = UNNotificationAction(
            identifier: Localized.dismissAction(),
            title: Localized.dismissAction(),
            options: []
        )
        let visit = UNNotificationCategory(
            identifier: NotificationsHandler.visitCategory,
            actions: [checkin, dismiss],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([
            debug,
            visit
        ])
        UNUserNotificationCenter.current().delegate = self

        return true
    }
}

// MARK: - AppNotificationsHandler

extension NotificationsHandler: AppNotificationsHandler {

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        log.error(#function)
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        log.error(#function)
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        log.error(#function)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationsHandler: UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        guard let visitList = userInfo[NotificationsHandler.visitList] as? String,
            let list = Checklist(rawValue: visitList),
            let visitId = userInfo[NotificationsHandler.visitId] as? Int else { return }

        switch response.actionIdentifier {
        case Localized.dismissAction():
            list.set(triggered: true, id: visitId)
        case Localized.checkinAction():
            list.set(visited: true, id: visitId)
        case UNNotificationDefaultActionIdentifier,
            UNNotificationDismissActionIdentifier:
            break
        default:
            log.error("unexpected notification: \(response.actionIdentifier)")
        }

        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler( [.alert, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                openSettingsFor notification: UNNotification?) {
        log.error(#function)
    }
}
