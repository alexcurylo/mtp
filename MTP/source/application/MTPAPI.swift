// @copyright Trollwerks Inc.

import Moya
import Result

enum MTPAPIError: Swift.Error {
    case unknown
    case parameter
    case operation(String)
}

enum MTP {
    case login(String, String)
}

extension MTP: TargetType {

    // swiftlint:disable:next force_unwrapping
    public var baseURL: URL { return URL(string: "https://mtp.travel")! }

    public var path: String {
        switch self {
        case .login:
            return "/api/user/login"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .login:
            return .post
        }
    }

    var task: Task {
        switch self {
        case let .login(email, password):
            return .requestParameters(parameters: ["email": email,
                                                   "password": password],
                                      encoding: JSONEncoding.default)
        }
    }

    var validationType: ValidationType {
        return .successCodes
    }

    // swiftlint:disable:next discouraged_optional_collection
    var headers: [String: String]? {
        return ["Content-Type": "application/json; charset=utf-8",
                "Accept": "application/json; charset=utf-8"]
    }

    public var sampleData: Data {
        switch self {
        case .login:
            return "{}".data(using: String.Encoding.utf8) ?? Data()
        }
    }
}

enum MTPAPI {

    static func forgotPassword(email: String,
                               then: @escaping (_ result: Result<Bool, MTPAPIError>) -> Void) {
        guard !email.isEmpty else {
            log.verbose("forgotPassword attempt invalid: email `\(email)`")
            return then(.failure(.parameter))
        }

        log.info("TO DO: implement MTPAPI.forgotPassword: \(email)")
        then(.success(true))
    }

    static func login(email: String,
                      password: String,
                      then: @escaping (_ result: Result<Bool, MTPAPIError>) -> Void) {
        guard !email.isEmpty && !password.isEmpty else {
            log.verbose("login attempt invalid: email `\(email)` password `\(password)`")
            return then(.failure(.parameter))
        }

        let provider = MoyaProvider<MTP>()
        provider.request(.login(email, password)) { result in
            switch result {
            case .success(let response):
                do {
                    let userData = try response.mapJSON()
                    if let userDict = userData as? [String: Any],
                       let token = userDict["token"] as? String {
                        print("The userData is: " + userDict.description)
                        print("The token is: \(token)")
                        UserDefaults.standard.email = email
                        UserDefaults.standard.password = password
                        UserDefaults.standard.token = token
                        return then(.success(true))
                    }
                } catch {
                    log.error("error decoding /login response")
               }
            case .failure(let error):
                log.error("TO DO: handle error calling /login: \(String(describing: error))")
            }
            return then(.failure(.operation(result.description)))
        }
    }

    static func register(name: String,
                         email: String,
                         password: String,
                         then: @escaping (_ result: Result<Bool, MTPAPIError>) -> Void) {
        guard !name.isEmpty && !email.isEmpty && !password.isEmpty else {
            log.verbose("register attempt invalid: name `\(name)` email `\(email)` password `\(password)`")
            return then(.failure(.parameter))
        }

        log.info("TO DO: implement MTPAPI.register: \(name), \(email), \(password)")

        UserDefaults.standard.email = email
        UserDefaults.standard.name = name
        UserDefaults.standard.password = password
        then(.success(true))
    }
}
