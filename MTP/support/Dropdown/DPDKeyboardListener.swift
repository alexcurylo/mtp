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

final class DPDKeyboardListener {

	static let sharedInstance = DPDKeyboardListener()

	fileprivate(set) var isVisible = false
	fileprivate(set) var keyboardFrame = CGRect.zero
	fileprivate var isListening = false

	deinit {
		stopListeningToKeyboard()
	}
}

// MARK: - Notifications

extension DPDKeyboardListener {

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

	func stopListeningToKeyboard() {
		NotificationCenter.default.removeObserver(self)
	}

	@objc
	fileprivate func keyboardWillShow(_ notification: Notification) {
		isVisible = true
		keyboardFrame = keyboardFrame(fromNotification: notification)
	}

	@objc
	fileprivate func keyboardWillHide(_ notification: Notification) {
		isVisible = false
		keyboardFrame = keyboardFrame(fromNotification: notification)
	}

	fileprivate func keyboardFrame(fromNotification notification: Notification) -> CGRect {
        guard let info = (notification as NSNotification).userInfo else { return .zero }

		return (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero
	}
}
