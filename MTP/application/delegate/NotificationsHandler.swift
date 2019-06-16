// @copyright Trollwerks Inc.

import UIKit
import UserNotifications

final class NotificationsHandler: NSObject, AppHandler, ServiceProvider {
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
        guard let visitList = userInfo[Note.Info.list.key] as? String,
            let list = Checklist(rawValue: visitList),
            let visitId = userInfo[Note.Info.id.key] as? Int else { return }

        switch response.actionIdentifier {
        case Localized.dismissAction():
            list.set(dismissed: true, id: visitId)
        case Localized.checkinAction():
            list.set(visited: true, id: visitId)
            note.congratulate(list: list, id: visitId)
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
