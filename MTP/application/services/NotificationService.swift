// @copyright Trollwerks Inc.

import KRProgressHUD
import SwiftEntryKit
import UserNotifications

// swiftlint:disable file_length

/// Notification model
struct Note {

    /// Intention of notification
    enum Category: String {

        /// Congratulate on visit
        case congratulate
        /// Display error
        case error
        /// Show information
        case information
        /// Ask question
        case question
        /// Display success
        case success
        /// Provide checkin
        case visit

        /// identifier for UNNotification
        var identifier: String { return rawValue }

        fileprivate var attributes: EKAttributes {
            return EKAttributes(note: self)
        }

        fileprivate var priority: EKAttributes.Precedence.Priority {
            switch self {
            case .congratulate: return .high
            case .error: return .max
            case .information: return .normal
            case .question: return .high
            case .success: return .high
            case .visit: return .min
            }
        }
    }

    /// Information passed in notification and request user info
    enum ChecklistItemInfo: String {

        /// Checklist
        case list
        /// ID
        case id
        /// subtitle
        case subtitle
        /// title
        case title
        /// visited
        case visited

        /// Dictionary key
        var key: String { return rawValue }
    }

    fileprivate let title: String
    fileprivate let message: String
    fileprivate let category: Category
}

/// Provides alerts, modal messages, and background notifications
protocol NotificationService {

    /// Callback handler type
    typealias Completion = (Result<Bool, String>) -> Void
    /// Information type
    typealias Info = [String: Any]

    /// Ask user for authorization
    ///
    /// - Parameter then: Callback
    func authorizeNotifications(then: @escaping (Bool) -> Void)

    /// Set visited state
    ///
    /// - Parameters:
    ///   - item: Place
    ///   - visited: Whether visited
    ///   - congratulate: Whether to congratulate
    ///   - then: Callback
    func set(item: Checklist.Item,
             visited: Bool,
             congratulate: Bool,
             then: @escaping Completion)
    /// Set visited state
    ///
    /// - Parameters:
    ///   - items: Places
    ///   - visited: Whether visited
    ///   - congratulate: Whether to congratulate
    ///   - then: Callback
    func set(items: [Checklist.Item],
             visited: Bool,
             congratulate: Bool,
             then: @escaping Completion)

    /// Ask question
    ///
    /// - Parameters:
    ///   - question: Question
    ///   - then: Callback
    func ask(question: String,
             then: @escaping (Bool) -> Void)

    /// Check for pending notifications
    func checkPending()
    /// Queue visited notification
    ///
    /// - Parameters:
    ///   - mappable: Place
    ///   - triggered: Last triggered
    ///   - then: Callback
    func notify(mappable: Mappable,
                triggered: Date,
                then: @escaping Completion)
    /// Queue congratulations
    ///
    /// - Parameter item: Place
    func congratulate(item: Checklist.Item)
    /// Queue congratulations
    ///
    /// - Parameter mappable: Place
    func congratulate(mappable: Mappable)

    /// Post information
    ///
    /// - Parameters:
    ///   - title: String
    ///   - body: String
    func postInfo(title: String?,
                  body: String?)
    /// Post visit
    ///
    /// - Parameters:
    ///   - title: String
    ///   - body: String
    ///   - info: Info
    func postVisit(title: String,
                   body: String,
                   info: Info)
    /// Post error
    ///
    /// - Parameter error: String
    func post(error: String)
    /// Execute if in background
    ///
    /// - Parameter then: Action closure
    func background(then: @escaping () -> Void)
    /// Custom post
    ///
    /// - Parameters:
    ///   - title: String
    ///   - subtitle: String
    ///   - body: String
    ///   - category: String
    ///   - info: Info
    func post(title: String,
              subtitle: String,
              body: String,
              category: String,
              info: Info)

    /// Show success
    ///
    /// - Parameter success: String
    func modal(success: String)
    /// Show info
    ///
    /// - Parameter info: String
    func modal(info: String)
    /// Show error
    ///
    /// - Parameter error: String
    func modal(error: String)
    /// Network failure modal
    ///
    /// - Parameters:
    ///   - failure: NetworkError
    ///   - operation: String
    @discardableResult func modal(failure: NetworkError,
                                  operation: String) -> String
    /// Dismiss modal
    func dismissModal()

    /// Show error
    ///
    /// - Parameter error: String
    func message(error: String)
    /// Show unimplemented alert
    func unimplemented()
}

// MARK: - Generic NotificationService

extension NotificationService {

    /// Post information
    ///
    /// - Parameters:
    ///   - title: String
    ///   - body: String
    func postInfo(title: String?,
                  body: String?) {
        post(title: title ?? "",
             subtitle: "",
             body: body ?? "",
             category: Note.Category.information.identifier,
             info: [:])
    }

    /// Post visit
    ///
    /// - Parameters:
    ///   - title: String
    ///   - body: String
    ///   - info: Info
    func postVisit(title: String,
                   body: String,
                   info: Info) {
        post(title: title,
             subtitle: "",
             body: body,
             category: Note.Category.visit.identifier,
             info: info)
    }

    /// Post error
    ///
    /// - Parameter error: String
    func post(error: String) {
        post(title: L.errorState(),
             subtitle: "",
             body: error,
             category: Note.Category.error.identifier,
             info: [:])
    }

    /// Show unimplemented alert
    func unimplemented() {
        message(error: L.unimplemented())
    }
}

/// Production implementation of NotificationService
class NotificationServiceImpl: NotificationService, ServiceProvider {

    private var notifying: Mappable?
    private var congratulating: Mappable?
    private var showingModal = false
    private var alerting = false
    private var asking = false
    private var remindedVerify = false

    private let center: UNUserNotificationCenterProtocol = {
        #if DEBUG
        if UIApplication.isUnitTesting {
            return UNUserNotificationCenterStub()
        }
        #endif
        return UNUserNotificationCenter.current()
    }()

    /// Default constructor
    init() {
        KRProgressHUD.styleAppearance()
    }

    /// Ask user for authorization
    ///
    /// - Parameter then: Callback
    func authorizeNotifications(then: @escaping (Bool) -> Void) {
        let options: UNAuthorizationOptions = [.alert, .badge, .carPlay, .sound]
        center.requestAuthorization(options: options) { granted, _ in
            then(granted)
        }
    }

    /// Set visited state
    ///
    /// - Parameters:
    ///   - item: Place
    ///   - visited: Whether visited
    ///   - congratulate: Whether to congratulate
    ///   - then: Callback
    func set(item: Checklist.Item,
             visited: Bool,
             congratulate: Bool,
             then: @escaping Completion) {
        let changes = item.list.changes(id: item.id,
                                        visited: visited)
        set(items: changes,
            visited: visited,
            congratulate: congratulate,
            then: then)
    }

    /// Set visited state
    ///
    /// - Parameters:
    ///   - items: Places
    ///   - visited: Whether visited
    ///   - congratulate: Whether to congratulate
    ///   - then: Callback
    func set(items: [Checklist.Item],
             visited: Bool,
             congratulate: Bool,
             then: @escaping Completion) {
        guard let first = items.first else {
            then(.success(true))
            return
        }

        #if NOT_QUEUED
        modal(info: L.updatingVisit())
        net.set(items: items,
                visited: visited) { result in
            switch result {
            case .success:
                self.modal(success: L.success())
                DispatchQueue.main.asyncAfter(deadline: .veryShort) {
                    self.dismissModal()
                    self.data.set(items: items,
                                  visited: visited)
                    if congratulate {
                        self.congratulate(item: first)
                    }
                    then(.success(true))
                }
            case .failure(let error):
                let message = self.modal(failure: error,
                                         operation: L.updateVisit())
                DispatchQueue.main.async {
                    then(.failure(message))
                }
            }
        }
        #else
        net.set(items: items,
                visited: visited) { _ in }
        DispatchQueue.main.async {
            self.data.set(items: items,
                          visited: visited)
            if congratulate {
                self.congratulate(item: first)
            }
            then(.success(true))
        }
        #endif
    }

    /// Execute if in background
    ///
    /// - Parameter then: Action closure
    func background(then: @escaping () -> Void) {
        guard UIApplication.shared.isBackground else { return }

        center.getNotificationStatus { status in
            if status == .authorized {
                DispatchQueue.main.async { then() }
            }
        }
    }

    /// Custom post
    ///
    /// - Parameters:
    ///   - title: String
    ///   - subtitle: String
    ///   - body: String
    ///   - category: String
    ///   - info: Info
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

    /// Ask question
    ///
    /// - Parameters:
    ///   - question: Question
    ///   - then: Callback
    func ask(question: String,
             then: @escaping (Bool) -> Void) {
        let note = Note(title: question,
                        message: "",
                        category: .question)
        askForeground(question: note, then: then)
    }

    /// Queue visited notification
    ///
    /// - Parameters:
    ///   - mappable: Place
    ///   - triggered: Last triggered
    ///   - then: Callback
    func notify(mappable: Mappable,
                triggered: Date,
                then: @escaping Completion) {
        notifyForeground(mappable: mappable,
                         triggered: triggered,
                         then: then)
        notifyBackground(mappable: mappable,
                         triggered: triggered)
    }

    /// Queue congratulations
    ///
    /// - Parameter item: Place
    func congratulate(item: Checklist.Item) {
        guard let mappable = data.get(visible: item) else { return }

        congratulate(mappable: mappable)
    }

    /// Queue congratulations
    ///
    /// - Parameter mappable: Place
    func congratulate(mappable: Mappable) {
        guard let note = congratulations(for: mappable) else { return }

        congratulate(mappable: mappable, note: note)
    }

    /// Check for pending notifications
    func checkPending() {
        guard checkRemindedVerify() else { return }

        checkVisitTriggered()
    }

    /// Show error
    ///
    /// - Parameter error: String
    func message(error: String) {
        let note = Note(title: error,
                        message: "",
                        category: .error)
        alert(foreground: note) { }
    }
}

// MARK: - Private

private extension NotificationServiceImpl {

    func congratulate(mappable: Mappable, note: Note) {
        congratulateForeground(mappable: mappable, note: note)
        congratulateBackground(note: note)
    }

    func checkRemindedVerify() -> Bool {
        guard !remindedVerify,
              canNotifyForeground,
              let user = data.user,
              user.isWaiting else { return true }

        let note = Note(title: L.verify(),
                        message: L.verifyInstructions(user.email),
                        category: .information)
        askForeground(question: note,
                      yes: L.ok(),
                      no: L.resend()) { dontResend in
            self.remindedVerify = true
            if !dontResend {
                self.net.userVerify(id: user.id) { _ in }
            }
        }

        return false
    }

    func checkVisitTriggered() {
        let dismissed = data.dismissed ?? Timestamps()
        let visited = data.visited ?? Checked()
        var triggered = data.triggered ?? Timestamps()
        var changed = false
        for (key, value) in triggered {
            let item = key.item
            if visited[item.list].contains(item.id) ||
                dismissed.isStamped(item: item) {
                triggered.set(key: key, stamped: false)
                changed = true
                break
            } else if let mappable = data.get(visible: item) {
                notify(mappable: mappable,
                       triggered: value) { _ in }
                break
            }
        }
        if changed {
            data.triggered = triggered
        }
    }
}

// MARK: - UserNotifications: background

private extension NotificationServiceImpl {

    func notifyBackground(mappable: Mappable,
                          triggered: Date) {
        background {
            self.postVisit(mappable: mappable,
                           triggered: triggered)
        }
    }

    func checkinStrings(mappable: Mappable,
                        triggered: Date) -> (String, String) {
        let title = L.checkinTitle(mappable.checklist.category(full: true))

        let name = mappable.title
        let body: String
        switch (mappable.checklist, mappable.isHere) {
        case (.locations, true):
            body = L.checkinInsideNow(name)
        case (.locations, false):
            let when = triggered.relative
            body = L.checkinInsidePast(name, when)
        case (_, true):
            body = L.checkinNearNow(name)
        case (_, false):
            let when = triggered.relative
            body = L.checkinInsidePast(name, when)
        }

        return (title, body)
    }

    func postVisit(mappable: Mappable,
                   triggered: Date) {
        let list = mappable.checklist
        let id = mappable.checklistId
        guard !list.isNotified(id: id) else { return }

        list.set(notified: true, id: id)

        let (title, body) = checkinStrings(mappable: mappable,
                                           triggered: triggered)
        let noteInfo: NotificationService.Info = [
            Note.ChecklistItemInfo.list.key: list.rawValue,
            Note.ChecklistItemInfo.id.key: id
        ]

        postVisit(title: title, body: body, info: noteInfo)
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
               alerting == false &&
               asking == false &&
               congratulating == nil &&
               notifying == nil &&
               showingModal == false
    }

    // swiftlint:disable:next function_body_length
    func askForeground(question: Note,
                       yes: String = L.yes(),
                       no: String = L.no(),
                       then: @escaping (Bool) -> Void) {
        asking = true
        let simpleMessage = notifyMessage(contentTitle: question.title,
                                          contentMessage: question.message)

        // No
        let buttonFont = Avenir.heavy.of(size: 16)
        let noColor = UIColor(rgb: 0xD0021B)
        let noButtonLabelStyle = EKProperty.LabelStyle(font: buttonFont, color: EKColor(noColor))
        let noButtonLabel = EKProperty.LabelContent(
            text: no,
            style: noButtonLabelStyle)
        let noButton = EKProperty.ButtonContent(
            label: noButtonLabel,
            backgroundColor: .clear,
            highlightedBackgroundColor: EKColor(noColor.withAlphaComponent(0.05))) {
                SwiftEntryKit.dismiss {
                    self.asking = false
                    then(false)
                }
        }

        // Yes
        let yesColor = UIColor(rgb: 0x028DFF)
        let yesButtonLabelStyle = EKProperty.LabelStyle(font: buttonFont, color: EKColor(yesColor))
        let yesButtonLabel = EKProperty.LabelContent(
            text: yes,
            style: yesButtonLabelStyle)
        let yesButton = EKProperty.ButtonContent(
            label: yesButtonLabel,
            backgroundColor: .clear,
            highlightedBackgroundColor: EKColor(yesColor.withAlphaComponent(0.05))) {
                SwiftEntryKit.dismiss {
                    self.asking = false
                    then(true)
                }
        }
        let grayLight = UIColor(white: 230.0 / 255.0, alpha: 1)
        let buttonsBarContent = EKProperty.ButtonBarContent(
            // swiftlint:disable:next multiline_arguments
            with: noButton, yesButton,
            separatorColor: EKColor(grayLight),
            buttonHeight: 60,
            expandAnimatedly: true)

        // Generate
        let alertMessage = EKAlertMessage(
            simpleMessage: simpleMessage,
            imagePosition: .left,
            buttonBarContent: buttonsBarContent)
        let contentView = EKAlertMessageView(with: alertMessage)
        SwiftEntryKit.display(entry: contentView,
                              using: EKAttributes(note: .question))
    }

    // swiftlint:disable:next function_body_length
    func notifyForeground(mappable: Mappable,
                          triggered: Date,
                          then: @escaping Completion) {
        guard canNotifyForeground else { return }

        notifying = mappable
        let (title, body) = checkinStrings(mappable: mappable,
                                           triggered: triggered)
        let simpleMessage = notifyMessage(contentTitle: title,
                                          contentMessage: body)

        // Dismiss
        let buttonFont = Avenir.heavy.of(size: 16)
        let dismissColor = UIColor(rgb: 0xD0021B)
        let closeButtonLabelStyle = EKProperty.LabelStyle(font: buttonFont, color: EKColor(dismissColor))
        let closeButtonLabel = EKProperty.LabelContent(
            text: L.dismissAction(),
            style: closeButtonLabelStyle)
        let closeButton = EKProperty.ButtonContent(
            label: closeButtonLabel,
            backgroundColor: .clear,
            highlightedBackgroundColor: EKColor(dismissColor.withAlphaComponent(0.05))) { [mappable] in
                mappable.isDismissed = true
                SwiftEntryKit.dismiss {
                    self.notifying = nil
                    self.checkPending()
                }
        }

        // Checkin
        let checkinColor = UIColor(rgb: 0x028DFF)
        let okButtonLabelStyle = EKProperty.LabelStyle(font: buttonFont, color: EKColor(checkinColor))
        let okButtonLabel = EKProperty.LabelContent(
            text: L.checkinAction(),
            style: okButtonLabelStyle)
        let okButton = EKProperty.ButtonContent(
            label: okButtonLabel,
            backgroundColor: .clear,
            highlightedBackgroundColor: EKColor(checkinColor.withAlphaComponent(0.05))) { [mappable] in
                SwiftEntryKit.dismiss {
                    self.notifying = nil
                    self.set(item: mappable.item,
                             visited: true,
                             congratulate: true,
                             then: then)
                }
        }
        let grayLight = UIColor(white: 230.0 / 255.0, alpha: 1)
        let buttonsBarContent = EKProperty.ButtonBarContent(
            // swiftlint:disable:next multiline_arguments
            with: closeButton, okButton,
            separatorColor: EKColor(grayLight),
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

    func congratulateForeground(mappable: Mappable, note: Note) {
        guard canNotifyForeground else { return }

        congratulating = mappable
        app.route(reveal: mappable)

        alert(foreground: note) {
            self.congratulating = nil
            self.checkPending()
        }
    }

    func alert(foreground note: Note,
               then: @escaping () -> Void) {
        alerting = true
        let simpleMessage = notifyMessage(contentTitle: note.title,
                                          contentMessage: note.message)

        // OK
        let buttonFont = Avenir.heavy.of(size: 16)
        let okColor = UIColor(rgb: 0x028DFF)
        let okButtonLabelStyle = EKProperty.LabelStyle(font: buttonFont, color: EKColor(okColor))
        let okButtonLabel = EKProperty.LabelContent(
            text: L.ok(),
            style: okButtonLabelStyle)
        let okButton = EKProperty.ButtonContent(
            label: okButtonLabel,
            backgroundColor: .clear,
            highlightedBackgroundColor: EKColor(okColor.withAlphaComponent(0.05))) {
                SwiftEntryKit.dismiss {
                    self.alerting = false
                    then()
                }
        }
        let grayLight = UIColor(white: 230.0 / 255.0, alpha: 1)
        let buttonsBarContent = EKProperty.ButtonBarContent(
            with: okButton,
            separatorColor: EKColor(grayLight),
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

    func congratulations(for mappable: Mappable) -> Note? {
        guard let user = data.user else { return nil }
        let title = L.congratulations(mappable.title)

        let (single, plural) = mappable.checklist.names(full: true)
        let (visited, remaining) = mappable.checklist.visitStatus(of: user)
        let contentVisited = L.status(visited, plural, remaining)

        let contentMilestone = mappable.checklist.milestone(visited: visited)

        let contentNearest: String
        if remaining > 0,
            let place = mappable.nearest?.title {
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

    /// Show success
    ///
    /// - Parameter success: String
    func modal(success: String) {
        showingModal = true
        KRProgressHUD.showSuccess(withMessage: success)
    }

    /// Show info
    ///
    /// - Parameter info: String
    func modal(info: String) {
        showingModal = true
        KRProgressHUD.show(withMessage: info)
    }

    /// Show error
    ///
    /// - Parameter error: String
    func modal(error: String) {
        showingModal = true
        KRProgressHUD.showError(withMessage: error)
    }

    /// Network failure modal
    ///
    /// - Parameters:
    ///   - failure: NetworkError
    ///   - operation: String
    @discardableResult func modal(failure: NetworkError,
                                  operation: String) -> String {
        let errorMessage: String
        switch failure {
        case .deviceOffline:
            errorMessage = L.deviceOfflineError(operation)
        case .serverOffline:
            errorMessage = L.serverOfflineError(operation)
        case .decoding:
            errorMessage = L.decodingErrorReport(operation)
        case .status(let code):
            switch code {
            case 503:
                errorMessage = L.serviceUnavailableError()
            default:
                errorMessage = L.statusErrorReport(operation, code)
            }
        case .message(let message):
            errorMessage = message
        case .network(let message):
            errorMessage = L.networkError(operation, message)
        default:
            errorMessage = L.unexpectedErrorReport(operation)
        }
        modal(error: errorMessage)
        DispatchQueue.main.asyncAfter(deadline: .medium) {
            self.dismissModal()
        }
        return errorMessage
    }

    /// Dismiss modal
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

        let dimmedLightBackground = EKColor(UIColor(white: 100.0 / 255.0, alpha: 0.3))
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

// MARK: - Testing

#if DEBUG

/// Stub for testing
final class NotificationServiceStub: NotificationServiceImpl {

    /// Ask user for authorization
    ///
    /// - Parameter then: Callback
    override func authorizeNotifications(then: @escaping (Bool) -> Void) {
        then(false)
    }
}

#endif
