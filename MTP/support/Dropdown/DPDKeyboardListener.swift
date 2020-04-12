// @copyright Trollwerks Inc.

// migrated from https://github.com/AssistoLab/Dropdown

//
//  KeyboardListener.swift
//  Dropdown
//
//  Created by Kevin Hirsch on 30/07/15.
//  Copyright (c) 2015 Kevin Hirsch. All rights reserved.
//

import UIKit

/// DPDKeyboardListener
final class DPDKeyboardListener {

    /// sharedInstance
	static let sharedInstance = DPDKeyboardListener()

    /// isVisible
    fileprivate(set) var isVisible = false
    /// keyboardFrame
	fileprivate(set) var keyboardFrame = CGRect.zero
	fileprivate var isListening = false

    /// :nodoc:
	deinit {
		stopListeningToKeyboard()
	}

    /// Start listening to keuboard
    func startListeningToKeyboard() {
        if isListening {
            return
        }

        isListening = true

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }

    /// Stop listening to keuboard
    func stopListeningToKeyboard() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
}

// MARK: - Notifications

private extension DPDKeyboardListener {

	@objc func keyboardWillShow(_ notification: Notification) {
		isVisible = true
		keyboardFrame = keyboardFrame(fromNotification: notification)
	}

	@objc func keyboardWillHide(_ notification: Notification) {
		isVisible = false
		keyboardFrame = keyboardFrame(fromNotification: notification)
	}

	func keyboardFrame(fromNotification notification: Notification) -> CGRect {
        guard let info = (notification as NSNotification).userInfo else { return .zero }

		return (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero
	}
}
