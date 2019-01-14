// @copyright Trollwerks Inc.

import Alamofire
import Moya
import enum Result.Result

enum MTPAPIError: Swift.Error {
    case unknown
    case parameter
    case network(String)
    case results
    case status
    case throttle
    case token
}

enum MTP {
    case countriesSearch(query: String?)
    case location
    case locationsSearch(parentCountry: Int?, query: String?)
    case userGetByToken
    case userLogin(email: String, password: String)
    case whs
}

extension MTP: TargetType {

    private var stagingURL: URL? { return URL(string: "https://aws.mtp.travel/api/") }
    private var productionURL: URL? { return URL(string: "https://mtp.travel/api/") }
    // swiftlint:disable:next force_unwrapping
    public var baseURL: URL { return stagingURL! }

    public var path: String {
        switch self {
        case .countriesSearch:
            return "countries/search"
        case .location:
            return "location"
        case .locationsSearch:
            return "locations/search"
        case .userGetByToken:
            return "user/getByToken"
        case .userLogin:
            return "user/login"
        case .whs:
            return "whs"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .countriesSearch,
             .location,
             .locationsSearch,
             .userGetByToken,
             .whs:
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
        case .countriesSearch,
             .location,
             .locationsSearch,
             .userGetByToken,
             .whs:
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
        case .countriesSearch,
             .location,
             .locationsSearch,
             .userLogin,
             .whs:
            return .none
        }
    }
}

enum MTPAPI {

    typealias BoolResult = (_ result: Result<Bool, MTPAPIError>) -> Void
    typealias CountriesResult = (_ result: Result<[Country], MTPAPIError>) -> Void
    typealias LocationsResult = (_ result: Result<[Location], MTPAPIError>) -> Void
    typealias UserResult = (_ result: Result<User, MTPAPIError>) -> Void
    typealias WHSResult = (_ result: Result<[WHS], MTPAPIError>) -> Void

    static let parentCountryUSA = 977

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
                let message = error.errorDescription ?? Localized.unknown()
                log.error("countries/search: \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    static func loadLocations(then: @escaping LocationsResult = { _ in }) {
        let provider = MoyaProvider<MTP>()
        provider.request(.location) { response in
            switch response {
            case .success(let result):
                do {
                    let locations = try result.map([Location].self,
                                                   using: JSONDecoder.mtp)
                    log.verbose("locations: " + locations.debugDescription)
                    gestalt.locations = locations
                    return then(.success(locations))
                } catch {
                    log.error("decoding locations: \(error)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                log.error("location: \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    static func loadWHS(then: @escaping WHSResult = { _ in }) {
        let provider = MoyaProvider<MTP>()
        provider.request(.whs) { response in
            switch response {
            case .success(let result):
                do {
                    let whs = try result.map([WHS].self,
                                             using: JSONDecoder.mtp)
                    log.verbose("whs: " + whs.debugDescription)
                    gestalt.whs = whs
                    return then(.success(whs))
                } catch {
                    log.error("decoding whs: \(error)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                log.error("whs: \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

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
                let message = error.errorDescription ?? Localized.unknown()
                log.error("locations/search: \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    static func userDeleteAccount(then: @escaping BoolResult) {
        log.todo("MTPAPI.implement deleteAccount")
        then(.success(true))
    }

    static func userForgotPassword(email: String,
                                   then: @escaping BoolResult) {
        guard !email.isEmpty else {
            log.verbose("forgotPassword attempt invalid: email `\(email)`")
            return then(.failure(.parameter))
        }

        log.todo("implement MTPAPI.forgotPassword: \(email)")
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
                let message = error.errorDescription ?? Localized.unknown()
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

        func parse(result: Response) {
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
        }

        let provider = MoyaProvider<MTP>()
        provider.request(.userLogin(email: email, password: password)) { response in
            switch response {
            case .success(let result):
                return parse(result: result)
            case .failure(.underlying(AFError.responseValidationFailed, _)):
                log.error("user/login API rejection")
                return then(.failure(.status))
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                log.error("user/login failure : \(message)")
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

        log.todo("implement MTPAPI.register: \(name), \(email), \(password)")

        gestalt.email = email
        gestalt.name = name
        gestalt.password = password
        then(.success(true))
    }
}
