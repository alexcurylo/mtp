// @copyright Trollwerks Inc.

import FacebookCore
import FacebookLogin

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

    func login(then: @escaping (RegistrationInfo?) -> Void) {
        let info: [ReadPermission] = [ .publicProfile, .email, .userBirthday, .userGender ]
        LoginManager().logIn(readPermissions: info) { [weak self] result in
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
        let connection = GraphRequestConnection()
        connection.add(InfoRequest()) { [weak self] _, result in
            let info: RegistrationInfo?
            switch result {
            case .success(let fbInfo):
                info = fbInfo.info
            case .failed(let error):
                self?.log.verbose("Facebook login failed: \(error)")
                info = nil
            }
            then(info)
        }
        connection.start()
    }
}

private struct InfoRequest: GraphRequestProtocol {

    struct Response: GraphResponseProtocol {

        let info: RegistrationInfo?

        init(rawResponse: Any?) {
            guard let response = rawResponse as? [String: Any] else {
                info = nil
                return
            }

            info = RegistrationInfo(facebook: response)
        }
    }

    var graphPath = "/me"
    // swiftlint:disable:next discouraged_optional_collection
    var parameters: [String: Any]? = ["fields": "birthday,email,first_name,gender,last_name"]
    var accessToken = AccessToken.current
    var httpMethod: GraphRequestHTTPMethod = .GET
    var apiVersion: GraphAPIVersion = .defaultVersion
}
