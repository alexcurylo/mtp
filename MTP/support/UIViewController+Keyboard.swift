// @copyright Trollwerks Inc.

import UIKit

/// Provide scroll view for keyboard avoidance
protocol KeyboardListener {

    /// Scroll view for keyboard avoidance
    var keyboardScrollee: UIScrollView? { get }
}

extension UIViewController {

    func startKeyboardListening() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(UIViewController.keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(UIViewController.keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
        // TBD: UIKeyboardWillChangeFrameNotification
    }

    func stopKeyboardListening() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        guard let scrollView = (self as? KeyboardListener)?.keyboardScrollee else { return }

        let payload = KeyboardPayload(note: notification)
        let scrollFrame = scrollView.frame
        let keyboardFrame = view.convert(payload.endFrame, from: nil)
        let options = UIView.AnimationOptions.beginFromCurrentState
        UIView.animate(
            withDuration: payload.duration,
            delay: 0,
            options: options,
            animations: {
                let insetHeight = (scrollFrame.height + scrollFrame.origin.y) - keyboardFrame.origin.y
                let insets = UIEdgeInsets(top: 0, left: 0, bottom: insetHeight, right: 0)
                scrollView.contentInset = insets
                scrollView.scrollIndicatorInsets = insets
            },
            completion: nil)
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        guard let scrollView = (self as? KeyboardListener)?.keyboardScrollee else { return }

        let payload = KeyboardPayload(note: notification)
        let options = UIView.AnimationOptions.beginFromCurrentState
        UIView.animate(
            withDuration: payload.duration,
            delay: 0,
            options: options,
            animations: {
                scrollView.contentInset = .zero
                scrollView.scrollIndicatorInsets = .zero
            },
            completion: nil)
    }
}

struct KeyboardPayload {
    let beginFrame: CGRect
    let endFrame: CGRect
    let curve: UIView.AnimationCurve
    let duration: TimeInterval
    let isLocal: Bool
}

extension KeyboardPayload {

    init(note: Notification) {
        let userInfo = note.userInfo
        beginFrame = userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect ?? .zero
        endFrame = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
        let rawValue = userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int ?? 0
        curve = UIView.AnimationCurve(rawValue: rawValue) ?? .easeInOut
        duration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0
        isLocal = userInfo?[UIResponder.keyboardIsLocalUserInfoKey] as? Bool ?? false
    }
}

#if BLOCK_OBSERVATIONS

struct NotificationDescriptor<Payload> {

    let name: Notification.Name
    let convert: (Notification) -> Payload
}

extension NotificationCenter {

    func addObserver<Payload>(with descriptor: NotificationDescriptor<Payload>, block: @escaping (Payload) -> Void) {
        addObserver(forName: descriptor.name,
                    object: nil,
                    queue: nil) { note in
            block(descriptor.convert(note))
        }
    }
}

extension UIViewController {

    static let keyboardWillShow = NotificationDescriptor(
        name: UIResponder.keyboardWillShowNotification,
        convert: KeyboardPayload.init)
    static let keyboardWillHide = NotificationDescriptor(
        name: UIResponder.keyboardWillHideNotification,
        convert: KeyboardPayload.init)

    func addBlockKeyboardObservers() {
        guard let scrollView = (self as? KeyboardListener)?.keyboardScrollee else { return }

        let center = NotificationCenter.default
        center.addObserver(with: UIViewController.keyboardWillShow) { payload in
            let contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: payload.endFrame.height, right: 0.0)
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset
        }
        center.addObserver(with: UIViewController.keyboardWillHide) { _ in
            let contentInset = UIEdgeInsets.zero
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset
        }
    }
}

#endif
