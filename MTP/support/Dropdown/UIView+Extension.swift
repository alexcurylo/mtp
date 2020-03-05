// @copyright Trollwerks Inc.

// migrated from https://github.com/AssistoLab/Dropdown

//
//  UIView+Constraints.swift
//  Dropdown
//
//  Created by Kevin Hirsch on 28/07/15.
//  Copyright (c) 2015 Kevin Hirsch. All rights reserved.
//

import UIKit

// MARK: - Constraints

extension UIView {

    /// addConstraints
    /// - Parameter format: format
    /// - Parameter options: options
    /// - Parameter metrics: metrics
    /// - Parameter views: views
    func addConstraints(format: String,
                        options: NSLayoutConstraint.FormatOptions = [],
                        // swiftlint:disable:next discouraged_optional_collection
                        metrics: [String: AnyObject]? = nil,
                        views: [String: UIView] = [:]) {
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format,
                                                      options: options,
                                                      metrics: metrics,
                                                      views: views))
	}

    /// addUniversalConstraints
    /// - Parameter format: format
    /// - Parameter options: options
    /// - Parameter metrics: metrics
    /// - Parameter views: views
    func addUniversalConstraints(format: String,
                                 options: NSLayoutConstraint.FormatOptions = [],
                                 // swiftlint:disable:next discouraged_optional_collection
                                 metrics: [String: AnyObject]? = nil,
                                 views: [String: UIView] = [:]) {
		addConstraints(format: "H:\(format)", options: options, metrics: metrics, views: views)
		addConstraints(format: "V:\(format)", options: options, metrics: metrics, views: views)
	}
}

// MARK: - Bounds

extension UIView {

    /// windowFrame
    var windowFrame: CGRect? {
        superview?.convert(frame, to: nil)
    }
}

extension UIWindow {

    /// visibleWindow
    static func visibleWindow() -> UIWindow? {
        var currentWindow = UIApplication.shared.keyWindow

        if currentWindow == nil {
            let frontToBackWindows = Array(UIApplication.shared.windows.reversed())

            for window in frontToBackWindows where window.windowLevel == UIWindow.Level.normal {
                currentWindow = window
                break
            }
        }

        return currentWindow
    }
}
