// @copyright Trollwerks Inc.

import FacebookCore
import FacebookLogin
import FBSDKLoginKit

protocol FacebookSDKClient {

    func loginManager(or mock: FacebookLoginManager?) -> FacebookLoginManager
    func infoRequest(or mock: FacebookInfoRequest?) -> FacebookInfoRequest
}

enum FacebookWrapper {

    /// Log out of Facebook
    static func logOut() {
        LoginManager().logOut()
    }

    /// Currently logged in user
    static var token: AccessToken? {
        return AccessToken.current
    }
}

// https://developers.facebook.com/docs/facebook-login/ios/advanced/#custom-login-button

/// Abstract Facebook SDK for testing
protocol FacebookLoginManager {

    /// Abstract Facebook login
    ///
    /// - Parameters:
    ///   - permissions: Array of read permissions
    ///   - viewController: View controller to present from
    ///   - completion: Optional callback
    func logIn(permissions: [Permission],
               viewController: UIViewController?,
               completion: LoginResultBlock?)
}

extension LoginManager: FacebookLoginManager { }

extension FacebookSDKClient {

    func loginManager(or mock: FacebookLoginManager?) -> FacebookLoginManager {
        #if DEBUG
        switch (UIApplication.isTesting, mock) {
        case (false, _):
            break
        case (true, let mock?):
            return mock
        default:
            return FacebookLoginManagerStub()
        }
        #endif
        return LoginManager()
    }

    func infoRequest(or mock: FacebookInfoRequest?) -> FacebookInfoRequest {
        #if DEBUG
        switch (UIApplication.isTesting, mock) {
        case (false, _):
            break
        case (true, let mock?):
            return mock
        default:
            break
        }
        #endif
        return GraphRequest(graphPath: "/me",
                            parameters: ["fields": "birthday,email,first_name,gender,last_name"],
                            httpMethod: .get)
    }
}

#if DEBUG
private final class FacebookLoginManagerStub: FacebookLoginManager {

    func logIn(permissions: [Permission],
               viewController: UIViewController?,
               completion: LoginResultBlock?) {
        completion?(.failed("stub"))
    }
}
#endif

/// Abstract Facebook SDK for testing
protocol FacebookInfoRequest {

    /// Abstract Facebook info request
    ///
    /// - Parameter completionHandler: GraphRequestBlock
    /// - Returns: GraphRequestConnection
    @discardableResult func start(completionHandler: GraphRequestBlock?) -> GraphRequestConnection
}

extension GraphRequest: FacebookInfoRequest { }
