// @copyright Trollwerks Inc.

import FBSDKCoreKit
import UIKit

/// Stub for startup construction
struct ActionHandler: AppHandler { }

extension ActionHandler: AppOpenURLHandler {

    /// Open URL handler
    /// - Parameters:
    ///   - app: Application
    ///   - url: URL
    ///   - options: Options
    /// - Returns: Success
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return handleFacebookURL(app: app, open: url, options: options)
    }
}

// MARK: - Facebook

extension ActionHandler {

    /// Handle Facebook URL
    /// - Parameters:
    ///   - app: Application
    ///   - url: URL
    ///   - options: Options
    /// - Returns: Success
    func handleFacebookURL(app: UIApplication,
                           open url: URL,
                           options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return FBSDKCoreKit.ApplicationDelegate.shared.application(
            app,
            open: url,
            options: options
        )
    }
}
