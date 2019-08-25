// @copyright Trollwerks Inc.

import FacebookCore
import FacebookLogin
import FBSDKLoginKit

// https://developers.facebook.com/docs/facebook-login/ios/advanced/#custom-login-button

/// Button for Facebook login
final class FacebookButton: UIButton, ServiceProvider {

    /// Procedural intializer
    ///
    /// - Parameter frame: Display frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    /// Decoding intializer
    ///
    /// - Parameter aDecoder: Decoder
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    /// Perform Facebook login
    ///
    /// - Parameters:
    ///   - vc: Containing view controller
    ///   - then: Callback
    func login(vc: UIViewController,
               then: @escaping (RegistrationPayload?) -> Void) {
        guard !UIApplication.isTesting else {
            return then(nil)
        }

        LoginManager().logIn(
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

    /// Log out of Facebook
    static func logOut() {
        LoginManager().logOut()
    }

    /// Currently logged in user
    static var current: AccessToken? {
        return AccessToken.current
    }
}

// MARK: - Private

private extension FacebookButton {

    func setup() {
        backgroundColor = .facebookButton
        imageView?.contentMode = .scaleAspectFit
    }

    func requestInfo(then: @escaping (RegistrationPayload?) -> Void) {
        let request = GraphRequest(graphPath: "/me",
                                   parameters: ["fields": "birthday,email,first_name,gender,last_name"],
                                   httpMethod: .get)
        request.start { [weak self] _, result, error in
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
