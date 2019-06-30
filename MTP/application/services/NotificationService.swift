// @copyright Trollwerks Inc.

import KRProgressHUD
import SwiftEntryKit
import UserNotifications

// swiftlint:disable file_length

struct Note {

    enum Category: String {

        case congratulate
        case error
        case information
        case success
        case visit

        var identifier: String { return rawValue }

        var attributes: EKAttributes {
            return EKAttributes(note: self)
        }

        var priority: EKAttributes.Precedence.Priority {
            switch self {
            case .congratulate: return .high
            case .error: return .max
            case .information: return .normal
            case .success: return .high
            case .visit: return .min
            }
        }
    }

    enum Info: String {

        case id
        case list

        var key: String { return rawValue }
    }

    let title: String
    let message: String
    let category: Category
}

protocol NotificationService {

    typealias Info = [String: Any]

    func authorizeNotifications(then: @escaping (Bool) -> Void)

    func checkTriggered()
    func notify(list: Checklist,
                id: Int)
    func notify(list: Checklist,
                info: PlaceInfo)
    func congratulate(list: Checklist,
                      id: Int)

    func infoBackground(title: String?,
                        body: String?)
    func visitBackground(title: String,
                         body: String,
                         info: Info)
    func background(then: @escaping () -> Void)
    func post(title: String,
              subtitle: String,
              body: String,
              category: String,
              info: Info)

    func modal(error: String)
    func modal(info: String)
    func modal(success: String)
    func dismissModal()

    func message(error: String)
    func unimplemented()
}

extension NotificationService {

    func notify(list: Checklist, id: Int) {
        if let info = list.place(id: id) {
            notify(list: list, info: info)
        }
    }

    func infoBackground(title: String?,
                        body: String?) {
        post(title: title ?? "",
             subtitle: "",
             body: body ?? "",
             category: Note.Category.information.identifier,
             info: [:])
    }

    func visitBackground(title: String,
                         body: String,
                         info: Info) {
        post(title: title,
             subtitle: "",
             body: body,
             category: Note.Category.visit.identifier,
             info: info)
    }

    func unimplemented() {
        message(error: L.unimplemented())
    }
}

final class NotificationServiceImpl: NotificationService, ServiceProvider {

    private var notifying: PlaceInfo?
    private var congratulating: PlaceAnnotation?
    private var showingModal = false
    private var alerting = false

    private var center: UNUserNotificationCenter {
        return UNUserNotificationCenter.current()
    }

    init() {
        KRProgressHUD.styleAppearance()
    }

    func authorizeNotifications(then: @escaping (Bool) -> Void) {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        center.requestAuthorization(options: options) { granted, _ in
            then(granted)
        }
    }

    func background(then: @escaping () -> Void) {
        guard UIApplication.shared.isBackground else { return }

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

    func notify(list: Checklist, info: PlaceInfo) {
        notifyForeground(list: list, info: info)
        notifyBackground(list: list, info: info)
    }

    func congratulate(list: Checklist, id: Int) {
        guard let annotation = loc.annotations(list: list)
                                  .first(where: { $0.id == id }),
              let note = congratulations(for: annotation) else { return }

        congratulate(annotation: annotation, note: note)
    }

    func congratulate(annotation: PlaceAnnotation, note: Note) {
        congratulateForeground(annotation: annotation, note: note)
        congratulateBackground(note: note)
    }

    func checkTriggered() {
        let triggered = data.triggered
        for list in Checklist.allCases {
            let listed = triggered?[list] ?? []
            for next in listed {
                if list.isVisited(id: next) ||
                   list.isDismissed(id: next) {
                    list.set(triggered: false, id: next)
                } else {
                    notify(list: list, id: next)
                    return
                }
            }
        }
    }

    func message(error: String) {
        let note = Note(title: error,
                        message: "",
                        category: .error)
        alert(foreground: note) { }
    }
}

// MARK: - UserNotifications: background

private extension NotificationServiceImpl {

    func notifyBackground(list: Checklist,
                          info: PlaceInfo) {
        background {
            self.postVisit(list: list,
                           info: info)
        }
    }

    func postVisit(list: Checklist,
                   info: PlaceInfo) {
        guard !list.isNotified(id: info.placeId) else { return }

        list.set(notified: true, id: info.placeId)

        let title = L.checkinTitle(list.category(full: true))
        let body: String
        switch list {
        case .locations:
            body = L.checkinInside(info.placeTitle)
        default:
            body = L.checkinNear(info.placeTitle)
        }
        let info: NotificationService.Info = [
            Note.Info.list.key: list.rawValue,
            Note.Info.id.key: info.placeId
        ]

        visitBackground(title: title, body: body, info: info)
    }

    func congratulateBackground(note: Note) {
        background {
            self.post(note: note)
        }
    }

    func post(note: Note) {
        post(title: note.title,
             subtitle: "",
             body: note.message,
             category: note.category.identifier,
             info: [:])
    }
}

// MARK: - SwiftEntryKit: foreground

private extension NotificationServiceImpl {

    var canNotifyForeground: Bool {
        return UIApplication.shared.isForeground &&
               showingModal == false &&
               alerting == false &&
               notifying == nil &&
               congratulating == nil
    }

    // swiftlint:disable:next function_body_length
    func notifyForeground(list: Checklist,
                          info: PlaceInfo) {
        guard canNotifyForeground else { return }

        notifying = info

        let visitId = info.placeId
        let contentTitle = L.checkinTitle(list.category(full: true))
        let contentMessage: String
        switch list {
        case .locations:
            contentMessage = L.checkinInside(info.placeTitle)
        default:
            contentMessage = L.checkinNear(info.placeTitle)
        }
        let simpleMessage = notifyMessage(contentTitle: contentTitle,
                                          contentMessage: contentMessage)

        // Dismiss
        let buttonFont = Avenir.heavy.of(size: 16)
        let dismissColor = UIColor(rgb: 0xD0021B)
        let closeButtonLabelStyle = EKProperty.LabelStyle(font: buttonFont, color: dismissColor)
        let closeButtonLabel = EKProperty.LabelContent(
            text: L.dismissAction(),
            style: closeButtonLabelStyle)
        let closeButton = EKProperty.ButtonContent(
            label: closeButtonLabel,
            backgroundColor: .clear,
            highlightedBackgroundColor: dismissColor.withAlphaComponent(0.05)) { [list, visitId] in
                list.set(dismissed: true, id: visitId)
                SwiftEntryKit.dismiss {
                    self.notifying = nil
                    self.checkTriggered()
                }
        }

        // Checkin
        let checkinColor = UIColor(rgb: 0x028DFF)
        let okButtonLabelStyle = EKProperty.LabelStyle(font: buttonFont, color: checkinColor)
        let okButtonLabel = EKProperty.LabelContent(
            text: L.checkinAction(),
            style: okButtonLabelStyle)
        let okButton = EKProperty.ButtonContent(
            label: okButtonLabel,
            backgroundColor: .clear,
            highlightedBackgroundColor: checkinColor.withAlphaComponent(0.05)) { [list, visitId] in
                list.set(visited: true, id: visitId)
                SwiftEntryKit.dismiss {
                    self.notifying = nil
                    self.congratulate(list: list, id: visitId)
                }
        }
        let grayLight = UIColor(white: 230.0 / 255.0, alpha: 1)
        let buttonsBarContent = EKProperty.ButtonBarContent(
            // swiftlint:disable:next multiline_arguments
            with: closeButton, okButton,
            separatorColor: grayLight,
            buttonHeight: 60,
            expandAnimatedly: true)

        // Generate
        let alertMessage = EKAlertMessage(
            simpleMessage: simpleMessage,
            imagePosition: .left,
            buttonBarContent: buttonsBarContent)
        let contentView = EKAlertMessageView(with: alertMessage)
        SwiftEntryKit.display(entry: contentView,
                              using: EKAttributes(note: .visit))
    }

    func congratulateForeground(annotation: PlaceAnnotation, note: Note) {
        guard canNotifyForeground else { return }

        congratulating = annotation
        app.route(to: annotation)

        alert(foreground: note) {
            self.congratulating = nil
            self.checkTriggered()
        }
    }

    func alert(foreground note: Note,
               then: @escaping () -> Void) {
        alerting = true
        let simpleMessage = notifyMessage(contentTitle: note.title,
                                          contentMessage: note.message)

        // OK
        let buttonFont = Avenir.heavy.of(size: 16)
        let checkinColor = UIColor(rgb: 0x028DFF)
        let okButtonLabelStyle = EKProperty.LabelStyle(font: buttonFont, color: checkinColor)
        let okButtonLabel = EKProperty.LabelContent(
            text: L.ok(),
            style: okButtonLabelStyle)
        let okButton = EKProperty.ButtonContent(
            label: okButtonLabel,
            backgroundColor: .clear,
            highlightedBackgroundColor: checkinColor.withAlphaComponent(0.05)) {
                SwiftEntryKit.dismiss {
                    self.alerting = false
                    then()
                }
        }
        let grayLight = UIColor(white: 230.0 / 255.0, alpha: 1)
        let buttonsBarContent = EKProperty.ButtonBarContent(
            with: okButton,
            separatorColor: grayLight,
            buttonHeight: 60,
            expandAnimatedly: true)

        // Generate
        let alertMessage = EKAlertMessage(
            simpleMessage: simpleMessage,
            imagePosition: .left,
            buttonBarContent: buttonsBarContent)
        let contentView = EKAlertMessageView(with: alertMessage)
        SwiftEntryKit.display(entry: contentView,
                              using: EKAttributes(note: note.category))
    }

    func congratulations(for annotation: PlaceAnnotation) -> Note? {
        guard let user = data.user else { return nil }
        let title = L.congratulations(annotation.name)

        let (single, plural) = annotation.list.names(full: true)
        let (visited, remaining) = annotation.list.status(of: user)
        let contentVisited = L.status(visited, plural, remaining)

        let contentMilestone = annotation.list.milestone(visited: visited)

        let contentNearest: String
        if remaining > 0,
            let place = annotation.nearest?.name {
            contentNearest = L.nearest(single, place)
        } else {
            contentNearest = ""
        }

        let message = contentMilestone + contentVisited + contentNearest
        return Note(title: title,
                    message: message,
                    category: .congratulate)
    }

    func notifyMessage(contentTitle: String,
                       contentMessage: String) -> EKSimpleMessage {
        let title = EKProperty.LabelContent(
            text: contentTitle,
            style: .init(font: Avenir.medium.of(size: 15),
                         color: .black))
        let description = EKProperty.LabelContent(
            text: contentMessage,
            style: .init(font: Avenir.light.of(size: 13),
                         color: .black))
        let simpleMessage = EKSimpleMessage(image: nil,
                                            title: title,
                                            description: description)
        return simpleMessage
    }
}

// MARK: - KRProgressHUD: modal

extension NotificationServiceImpl {

    func modal(error: String) {
        showingModal = true
        KRProgressHUD.showError(withMessage: error)
    }

    func modal(info: String) {
        showingModal = true
        KRProgressHUD.show(withMessage: info)
    }

    func modal(success: String) {
        showingModal = true
        KRProgressHUD.showSuccess(withMessage: success)
    }

    func dismissModal() {
        showingModal = false
        KRProgressHUD.dismiss()
    }
}

// MARK: - Support

private extension KRProgressHUD {

    static func styleAppearance() {
        KRProgressHUD.set(maskType: .custom(color: UIColor(white: 0, alpha: 0.8)))
        KRProgressHUD.set(style: .black)
        KRProgressHUD.set(activityIndicatorViewColors: [.white, UIColor(white: 0.7, alpha: 1)])
        KRProgressHUD.set(duration: 10)
    }
}

private extension EKAttributes {

    init(note category: Note.Category) {
        self = EKAttributes.notifyAttributes(note: category)
    }

    static func notifyAttributes(note category: Note.Category) -> EKAttributes {
        var attributes = EKAttributes.bottomFloat

        let dimmedLightBackground = UIColor(white: 100.0 / 255.0, alpha: 0.3)
        attributes.screenBackground = .color(color: dimmedLightBackground)
        attributes.hapticFeedbackType = .success
        attributes.displayDuration = .infinity
        attributes.entryBackground = .color(color: .white)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 8))
        attributes.roundCorners = .all(radius: 4)
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.2)))
        attributes.positionConstraints.verticalOffset = 10
        attributes.positionConstraints.size = .init(width: .offset(value: 20), height: .intrinsic)
        attributes.positionConstraints.maxSize = .init(
            width: .constant(value: UIScreen.main.bounds.minEdge),
            height: .intrinsic)
        attributes.statusBar = .dark
        attributes.border = .value(color: .black, width: 0.5)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 5))
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.exitAnimation = .init(translate: .init(duration: 0.2))
        attributes.entranceAnimation = .init(
            translate: .init(duration: 0.7,
                             spring: .init(damping: 1, initialVelocity: 0)),
            scale: .init(from: 0.6, to: 1, duration: 0.7),
            fade: .init(from: 0.8, to: 1, duration: 0.3))
        attributes.exitAnimation = .init(translate: .init(duration: 0.2))
        attributes.screenInteraction = .absorbTouches
        attributes.entryInteraction = .absorbTouches
        attributes.precedence = .enqueue(priority: category.priority)

        return attributes
    }
}
