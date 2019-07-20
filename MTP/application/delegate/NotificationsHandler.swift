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
