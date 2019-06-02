// @copyright Trollwerks Inc.

import UIKit
import UserNotifications

struct NotificationsHandler: AppHandler, ServiceProvider {

    static let visitCategory = "visit"
    static let visitList = "list"
    static let visitId = "id"
}

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

extension LaunchHandler {

    func configureNotifications(options: [UIApplication.LaunchOptionsKey: Any]) {
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

        let category = UNNotificationCategory(
            identifier: NotificationsHandler.visitCategory,
            actions: [checkin, dismiss],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}
