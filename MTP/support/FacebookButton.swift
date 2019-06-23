// @copyright Trollwerks Inc.

import FacebookLogin
import FBSDKLoginKit

// https://developers.facebook.com/docs/facebook-login/ios/advanced/#custom-login-button

final class FacebookButton: UIButton, ServiceProvider {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }

    func login(vc: UIViewController,
               then: @escaping (RegistrationInfo?) -> Void) {
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

    static func logOut () {
        LoginManager().logOut()
    }
}

private extension FacebookButton {

    func setup() {
        backgroundColor = .facebookButton
        imageView?.contentMode = .scaleAspectFit
    }

    func requestInfo(then: @escaping (RegistrationInfo?) -> Void) {
        let request = GraphRequest(graphPath: "/me",
                                   parameters: ["fields": "birthday,email,first_name,gender,last_name"],
                                   httpMethod: .get)
        request.start { [weak self] _, result, error in
            let info: RegistrationInfo?
            switch (result, error) {
            case let (result?, nil):
                let response = result as? [String: Any] ?? [:]
                info = RegistrationInfo(facebook: response)
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
