// @copyright Trollwerks Inc.

import Moya
import Result

enum MTPAPIError: Swift.Error {
    case unknown
    case parameter
    case network(String)
    case results
    case token
}

enum MTP {
    case getByToken
    case login(String, String)
}

extension MTP: TargetType {

    // swiftlint:disable:next force_unwrapping
    public var baseURL: URL { return URL(string: "https://mtp.travel/api/user/")! }

    public var path: String {
        switch self {
        case .getByToken:
            return "getByToken"
        case .login:
            return "login"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .getByToken:
            return .get
        case .login:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .getByToken:
            return .requestPlain
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
        case .getByToken, .login:
            return "{}".data(using: String.Encoding.utf8) ?? Data()
        }
    }
}

extension MTP: AccessTokenAuthorizable {

    var authorizationType: AuthorizationType {
        switch self {
        case .getByToken:
            return .bearer
        case .login:
            return .none
        }
    }
}

enum MTPAPI {

    typealias BoolResult = (_ result: Result<Bool, MTPAPIError>) -> Void
    typealias UserResult = (_ result: Result<User, MTPAPIError>) -> Void

    static func deleteAccount(then: @escaping BoolResult) {
        log.info("TO DO: MTPAPI.implement deleteAccount")
        then(.success(true))
    }

    static func forgotPassword(email: String,
                               then: @escaping BoolResult) {
        guard !email.isEmpty else {
            log.verbose("forgotPassword attempt invalid: email `\(email)`")
            return then(.failure(.parameter))
        }

        log.info("TO DO: implement MTPAPI.forgotPassword: \(email)")
        then(.success(true))
    }

    static func refreshUser() {
        guard gestalt.isLoggedIn else { return }
        if let last = gestalt.lastUserRefresh {
            let next = last.addingTimeInterval(60 * 5)
            guard next < Date().toUTC else { return }
        }
        getByToken()
    }

    static func getByToken(then: @escaping UserResult = { _ in }) {
        guard gestalt.isLoggedIn else {
            log.verbose("getByToken attempt invalid: not logged in")
            return then(.failure(.parameter))
        }

        let auth = AccessTokenPlugin(tokenClosure: gestalt.token)
        let provider = MoyaProvider<MTP>(plugins: [auth])
        provider.request(.getByToken) { response in
            switch response {
            case .success(let result):
                do {
                    let user = try result.map(User.self,
                                              using: JSONDecoder.mtp)
                    gestalt.user = user
                    gestalt.lastUserRefresh = Date().toUTC
                    log.verbose("refreshed user: " + user.debugDescription)
                    return then(.success(user))
                } catch {
                    log.error("decoding user: \(error)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                let message = error.errorDescription ?? "undefined"
                log.error("/getByToken: \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    static func login(email: String,
                      password: String,
                      then: @escaping UserResult) {
        guard !email.isEmpty && !password.isEmpty else {
            log.verbose("login attempt invalid: email `\(email)` password `\(password)`")
            return then(.failure(.parameter))
        }

        let provider = MoyaProvider<MTP>()
        provider.request(.login(email, password)) { response in
            switch response {
            case .success(let result):
                do {
                    let user = try result.map(User.self,
                                              using: JSONDecoder.mtp)
                    guard let token = user.token else { throw MTPAPIError.token }
                    gestalt.token = token
                    gestalt.user = user
                    gestalt.lastUserRefresh = Date().toUTC
                    gestalt.email = email
                    gestalt.password = password
                    log.verbose("logged in user: " + user.debugDescription)
                    return then(.success(user))
                } catch {
                    log.error("decoding user: \(error)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                let message = error.errorDescription ?? "undefined"
                log.error("/login: \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    static func register(name: String,
                         email: String,
                         password: String,
                         then: @escaping BoolResult) {
        guard !name.isEmpty && !email.isEmpty && !password.isEmpty else {
            log.verbose("register attempt invalid: name `\(name)` email `\(email)` password `\(password)`")
            return then(.failure(.parameter))
        }

        log.info("TO DO: implement MTPAPI.register: \(name), \(email), \(password)")

        gestalt.email = email
        gestalt.name = name
        gestalt.password = password
        then(.success(true))
    }
}
