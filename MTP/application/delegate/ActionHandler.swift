// @copyright Trollwerks Inc.

import FBSDKCoreKit
import UIKit

struct ActionHandler: AppHandler { }

extension ActionHandler: AppOpenURLHandler {

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return handleFacebookURL(app: app, open: url, options: options)
    }
}

// MARK: - Facebook

extension ActionHandler {

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
