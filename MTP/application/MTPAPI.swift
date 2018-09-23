// @copyright Trollwerks Inc.

import Moya
import Result

enum MTPAPIError: Swift.Error {
    case unknown
    case parameter
    case network(String)
    case results
    case throttle
    case token
}

enum MTP {
    case countriesSearch(query: String?)
    case locationsSearch(parentCountry: Int?, query: String?)
    case userGetByToken
    case userLogin(email: String, password: String)
}

extension MTP: TargetType {

    // swiftlint:disable:next force_unwrapping
    public var baseURL: URL { return URL(string: "https://mtp.travel/api/")! }

    public var path: String {
        switch self {
        case .countriesSearch:
            return "countries/search"
        case .locationsSearch:
            return "locations/search"
        case .userGetByToken:
            return "user/getByToken"
        case .userLogin:
            return "user/login"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .countriesSearch, .locationsSearch, .userGetByToken:
            return .get
        case .userLogin:
            return .post
        }
    }

    var task: Task {
        switch self {
        case let .countriesSearch(query?):
            return .requestParameters(parameters: ["query": query],
                                      encoding: URLEncoding.default)
        case let .locationsSearch(parentCountry?, query?):
            return .requestParameters(parameters: ["parentCountry": parentCountry,
                                                   "query": query],
                                      encoding: URLEncoding.default)
        case let .locationsSearch(parentCountry?, nil):
            return .requestParameters(parameters: ["parentCountry": parentCountry],
                                      encoding: URLEncoding.default)
        case let .locationsSearch(nil, query?):
            return .requestParameters(parameters: ["query": query],
                                      encoding: URLEncoding.default)
        case let .userLogin(email, password):
            return .requestParameters(parameters: ["email": email,
                                                   "password": password],
                                      encoding: JSONEncoding.default)
        case .countriesSearch, .locationsSearch, .userGetByToken:
            return .requestPlain
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
        return "{}".data(using: String.Encoding.utf8) ?? Data()
    }
}

extension MTP: AccessTokenAuthorizable {

    var authorizationType: AuthorizationType {
        switch self {
        case .userGetByToken:
            return .bearer
        case .countriesSearch, .locationsSearch, .userLogin:
            return .none
        }
    }
}

enum MTPAPI {

    typealias BoolResult = (_ result: Result<Bool, MTPAPIError>) -> Void
    typealias CountriesResult = (_ result: Result<[Country], MTPAPIError>) -> Void
    typealias UserResult = (_ result: Result<User, MTPAPIError>) -> Void

    static func countriesSearch(query: String,
                                then: @escaping CountriesResult) {
        let provider = MoyaProvider<MTP>()
        let queryParam = query.isEmpty ? nil : query
        provider.request(.countriesSearch(query: queryParam)) { response in
            switch response {
            case .success(let result):
                do {
                    let countries = try result.map([Country].self,
                                                   using: JSONDecoder.mtp)
                    log.verbose("countries[\(query)]: " + countries.debugDescription)
                    return then(.success(countries))
                } catch {
                    log.error("decoding countries: \(error)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                let message = error.errorDescription ?? "undefined"
                log.error("countries/search: \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    static let parentCountryUSA = 977

    static func locationsSearch(query: String,
                                parentCountry: Int? = nil,
                                then: @escaping CountriesResult) {
        let provider = MoyaProvider<MTP>()
        let queryParam = query.isEmpty ? nil : query
        provider.request(.locationsSearch(parentCountry: parentCountry,
                                          query: queryParam)) { response in
            switch response {
            case .success(let result):
                do {
                    let locations = try result.map([Country].self,
                                                   using: JSONDecoder.mtp)
                    log.verbose("locations[\(query)]: " + locations.debugDescription)
                    return then(.success(locations))
                } catch {
                    log.error("decoding locations: \(error)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                let message = error.errorDescription ?? "undefined"
                log.error("locations/search: \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    static func userDeleteAccount(then: @escaping BoolResult) {
        log.info("TO DO: MTPAPI.implement deleteAccount")
        then(.success(true))
    }

    static func userForgotPassword(email: String,
                                   then: @escaping BoolResult) {
        guard !email.isEmpty else {
            log.verbose("forgotPassword attempt invalid: email `\(email)`")
            return then(.failure(.parameter))
        }

        log.info("TO DO: implement MTPAPI.forgotPassword: \(email)")
        then(.success(true))
    }

    static func userGetByToken(then: @escaping UserResult = { _ in }) {
        guard gestalt.isLoggedIn else {
            log.verbose("userGetByToken attempt invalid: not logged in")
            return then(.failure(.parameter))
        }
        if let last = gestalt.lastUserRefresh {
            let next = last.addingTimeInterval(60 * 5)
            guard next < Date().toUTC else {
                log.verbose("userGetByToken attempt invalid: 5 minute throttle")
                return then(.failure(.throttle))
            }
        }

        let auth = AccessTokenPlugin { gestalt.token }
        let provider = MoyaProvider<MTP>(plugins: [auth])
        provider.request(.userGetByToken) { response in
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
                log.error("user/getByToken: \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    static func userLogin(email: String,
                          password: String,
                          then: @escaping UserResult) {
        guard !email.isEmpty && !password.isEmpty else {
            log.verbose("userLogin attempt invalid: email `\(email)` password `\(password)`")
            return then(.failure(.parameter))
        }

        let provider = MoyaProvider<MTP>()
        provider.request(.userLogin(email: email, password: password)) { response in
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
                log.error("user/login: \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    static func userRegister(name: String,
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
