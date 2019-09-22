// @copyright Trollwerks Inc.

import UIKit

/// Button for Facebook login
final class FacebookButton: UIButton, FacebookSDKClient, ServiceProvider {

    /// Procedural intializer
    ///
    /// - Parameter frame: Display frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    /// :nodoc:
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    /// Perform Facebook login
    ///
    /// - Parameters:
    ///   - vc: Containing view controller
    ///   - mock: Testing injection
    ///   - then: Callback
    func login(vc: UIViewController,
               mock: FacebookLoginManager? = nil,
               then: @escaping (RegistrationPayload?) -> Void) {
        loginManager(or: mock).logIn(
            permissions: [ .publicProfile, .email, .userBirthday, .userGender ],
            viewController: vc
        ) { [weak self] result in
            switch result {
            // swiftlint:disable:next pattern_matching_keywords
            case .success(let granted, let declined, _):
                self?.log.verbose("Facebook login: granted \(granted), declined \(declined)")
                self?.requestInfo(then: then)
            case .cancelled:
                self?.log.verbose("Facebook login cancelled")
                then(nil)
            case .failed(let error):
                self?.log.verbose("Facebook login failed: \(error)")
                then(nil)
            }
        }
    }
}

// MARK: - Private

private extension FacebookButton {

    func setup() {
        backgroundColor = .facebookButton
        imageView?.contentMode = .scaleAspectFit
    }

    func requestInfo(then: @escaping (RegistrationPayload?) -> Void) {
        guard !UIApplication.isTesting else {
            return then(nil)
        }

        infoRequest(or: nil).start { [weak self] _, result, error in
            let info: RegistrationPayload?
            switch (result, error) {
            case let (result?, nil):
                let response = result as? [String: Any] ?? [:]
                info = RegistrationPayload(facebook: response)
            case let (nil, error?):
                self?.log.verbose("Facebook login failed: \(error)")
                info = nil
            default:
                self?.log.verbose("Facebook login failed: unknown error")
                info = nil
            }
            then(info)
        }
    }
}
