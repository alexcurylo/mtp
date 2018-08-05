// @copyright Trollwerks Inc.

import FacebookCore
import FacebookLogin
import UIKit

// https://developers.facebook.com/docs/facebook-login/ios/advanced/#custom-login-button

final class FacebookButton: UIButton {

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

    func login(then: @escaping (String, String, String) -> Void) {
        let info: [ReadPermission] = [ .publicProfile, .email ]
        LoginManager().logIn(readPermissions: info) { [weak self] result in
            switch result {
            // swiftlint:disable:next pattern_matching_keywords
            case .success(let granted, let declined, _):
                log.verbose("Facebook login: granted \(granted), declined \(declined)")
                self?.requestInfo(then: then)
            case .cancelled:
                log.verbose("Facebook login cancelled")
            case .failed(let error):
                log.verbose("Facebook login failed: \(error)")
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

    func requestInfo(then: @escaping (String, String, String) -> Void) {
        let connection = GraphRequestConnection()
        connection.add(InfoRequest()) { _, result in
            let name: String
            let email: String
            let id: String
            switch result {
            case .success(let info):
                name = info.name
                email = info.email
                id = info.id
            case .failed(let error):
                log.verbose("Facebook login failed: \(error)")
                name = ""
                email = ""
                id = ""
            }
            then(name, email, id)
        }
        connection.start()
    }
}

private struct InfoRequest: GraphRequestProtocol {

    struct Response: GraphResponseProtocol {

        let email: String
        let gender: String
        let id: String
        let name: String
        let picture: URL?

        init(rawResponse: Any?) {
            guard let response = rawResponse as? [String: Any] else {
                email = ""
                id = ""
                gender = ""
                name = ""
                picture = nil
                return
            }

            email = response["email"] as? String ?? ""
            gender = response["gender"] as? String ?? ""
            id = response["id"] as? String ?? ""
            name = response["name"] as? String ?? ""
            if let info = response["picture"] as? [String: Any],
               let data = info["data"] as? [String: Any],
               let url = data["url"] as? String {
                picture = URL(string: url)
            } else {
                picture = nil
            }
        }
    }

    var graphPath = "/me"
    // swiftlint:disable:next discouraged_optional_collection
    var parameters: [String: Any]? = ["fields": "email,gender,id,name,picture.type(large)"]
    var accessToken = AccessToken.current
    var httpMethod: GraphRequestHTTPMethod = .GET
    var apiVersion: GraphAPIVersion = .defaultVersion
}
