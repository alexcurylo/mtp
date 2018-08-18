// @copyright Trollwerks Inc.

import Foundation

enum MTPAPI {

    static func forgotPassword(email: String,
                               then: @escaping (Bool) -> Void) {
        guard !email.isEmpty else {
            log.verbose("forgotPassword attempt invalid: email `\(email)`")
            then(false)
            return
        }

        log.info("TO DO: implement MTPAPI.forgotPassword: \(email)")
        then(true)
    }

    // swiftlint:disable:next function_body_length
    static func login(email: String,
                      password: String,
                      then: @escaping (Bool) -> Void) {
        guard !email.isEmpty && !password.isEmpty else {
            log.verbose("login attempt invalid: email `\(email)` password `\(password)`")
            return then(false)
        }

        // server endpoint
        let endpoint = "https://mtp.travel/api/user/login"
        guard let endpointUrl = URL(string: endpoint) else {
            return then(false)
        }
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        //Make JSON to send to send to server
        var json = [String: Any]()

        json["email"] = email
        json["password"] = password

        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])

            var request = URLRequest(url: endpointUrl)
            request.httpMethod = "POST"
            request.httpBody = data
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")

            let task = session.dataTask(with: request) { data, _, error in
                guard error == nil else {
                    print("error calling POST on /user/login: \(String(describing: error))")
                    return then(false)
                }
                guard let responseData = data else {
                    print("Error: did not receive data")
                    return then(false)
                }

                do {
                    guard let userData = try JSONSerialization.jsonObject(with: responseData,
                                                                          options: []) as? [String: Any] else {
                        print("Could not get JSON from responseData as dictionary")
                        return
                    }
                    print("The userData is: " + userData.description)
                    if let token = userData["token"] as? String {
                        print("The token is: \(token)")
                        UserDefaults.standard.token = token
                        return then(true)
                    }
                } catch {
                    print("error parsing response from POST on /login")
                }
                return then(false)
            }
            task.resume()
        } catch {
            log.info("Error on login: \(email), \(password)")
            return then(false)
        }
    }

    static func register(name: String,
                         email: String,
                         password: String,
                         then: @escaping (Bool) -> Void) {
        guard !name.isEmpty && !email.isEmpty && !password.isEmpty else {
            log.verbose("register attempt invalid: name `\(name)` email `\(email)` password `\(password)`")
            return
        }

        log.info("TO DO: implement MTPAPI.register: \(name), \(email), \(password)")
        then(true)
    }
}
