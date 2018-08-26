// @copyright Trollwerks Inc.

import Moya
import Result

enum MTPAPIError: Swift.Error {
    case unknown
    case parameter
    case network(String)
    case results
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
                      then: @escaping (_ result: Result<User, MTPAPIError>) -> Void) {
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
                    log.verbose("Logged in: " + user.debugDescription)
                    gestalt.user = user
                    gestalt.email = email
                    gestalt.password = password
                    return then(.success(user))
                } catch {
                    log.error("decoding User: \(error)")
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
                         then: @escaping (_ result: Result<Bool, MTPAPIError>) -> Void) {
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

extension JSONDecoder {

    static let mtp: JSONDecoder = {
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            if let date = DateFormatter.mtpDay.date(from: dateString) {
                return date
            }
            if let date = DateFormatter.mtpTime.date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date: '\(dateString)'")
        }
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return decoder
    }()
}

extension DateFormatter {

    static let mtpDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    static let mtpTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
