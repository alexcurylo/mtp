// @copyright Trollwerks Inc.

import UIKit
import UserNotifications

protocol NotificationService {

    typealias Info = [String: Any]

    func debug(title: String?,
               body: String?)

    func visit(title: String,
               body: String,
               info: Info)

    func authorizeNotifications(then: @escaping (Bool) -> Void)

    func background(then: @escaping () -> Void)

    func post(title: String,
              subtitle: String,
              body: String,
              category: String,
              info: Info)
}

extension NotificationService {

    func debug(title: String?,
               body: String?) {
        #if DEBUG
        post(title: title ?? "",
             subtitle: "",
             body: body ?? "",
             category: NotificationsHandler.debugCategory,
             info: [:])
        #endif
    }

    func visit(title: String,
               body: String,
               info: Info) {
        post(title: title,
             subtitle: "",
             body: body,
             category: NotificationsHandler.visitCategory,
             info: info)
    }
}

final class NotificationServiceImpl: NotificationService {

    private var center: UNUserNotificationCenter {
        return UNUserNotificationCenter.current()
    }

    func authorizeNotifications(then: @escaping (Bool) -> Void) {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        center.requestAuthorization(options: options) { granted, _ in
            then(granted)
        }
    }

    func background(then: @escaping () -> Void) {
        let state = UIApplication.shared.applicationState
        guard state == .background else { return }

        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                DispatchQueue.main.async {
                    then()
                }
            default:
                break
            }
        }
    }

    func post(title: String,
              subtitle: String,
              body: String,
              category: String,
              info: Info) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.userInfo = info
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = category
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: nil)
        center.add(request)
    }
}
