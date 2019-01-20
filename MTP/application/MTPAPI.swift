// @copyright Trollwerks Inc.

// swiftlint:disable file_length

import Alamofire
import Moya
import enum Result.Result

enum MTPAPIError: Swift.Error {
    case unknown
    case parameter
    case network(String)
    case notModified
    case results
    case status
    case throttle
    case token
}

enum MTP {
    case beach
    case checklists
    case countries // appears same as `location` but returns 891 in production
    case countriesSearch(query: String?)
    case location // appears same as `countries` but returns 915 in production
    case locationsSearch(parentCountry: Int?, query: String?)
    case unCountry
    case userGetByToken
    case userLogin(email: String, password: String)
    case whs

    // To get the full, non-cached, re-computed data, use preventCache with a random number
    // https://mtp.travel/api/location?preventCache=1234
}

extension MTP: TargetType {

    private var stagingURL: URL? { return URL(string: "https://aws.mtp.travel/api/") }
    private var productionURL: URL? { return URL(string: "https://mtp.travel/api/") }
    // swiftlint:disable:next force_unwrapping
    public var baseURL: URL { return productionURL! }

    public var path: String {
        switch self {
        case .beach:
            return "beach"
        case .checklists:
            return "me/checklists"
        case .countries:
            return "countries"
        case .countriesSearch:
            return "countries/search"
        case .location:
            return "location"
        case .locationsSearch:
            return "locations/search"
        case .unCountry:
            return "un-country"
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
        case .beach,
             .checklists,
             .countries,
             .countriesSearch,
             .location,
             .locationsSearch,
             .unCountry,
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
        case .beach,
             .checklists,
             .countries,
             .countriesSearch,
             .location,
             .locationsSearch,
             .unCountry,
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
        case .checklists,
             .userGetByToken:
            return .bearer
        case .beach,
             .countries,
             .countriesSearch,
             .location,
             .locationsSearch,
             .unCountry,
             .userLogin,
             .whs:
            return .none
        }
    }
}

enum MTPAPI {

    typealias BoolResult = (_ result: Result<Bool, MTPAPIError>) -> Void
    typealias ChecklistsResult = (_ result: Result<Checklists, MTPAPIError>) -> Void
    typealias CountriesResult = (_ result: Result<[Country], MTPAPIError>) -> Void
    typealias LocationsResult = (_ result: Result<[Location], MTPAPIError>) -> Void
    typealias PlacesResult = (_ result: Result<[Place], MTPAPIError>) -> Void
    typealias UserResult = (_ result: Result<User, MTPAPIError>) -> Void
    typealias WHSResult = (_ result: Result<[WHS], MTPAPIError>) -> Void

    static let parentCountryUSA = 977
}

// MARK: - Queries

extension MTPAPI {

    static func countriesSearch(query: String,
                                then: @escaping CountriesResult) {
        let provider = MoyaProvider<MTP>()
        let queryParam = query.isEmpty ? nil : query
        let endpoint = MTP.countriesSearch(query: queryParam)
        provider.request(endpoint) { response in
            switch response {
            case .success(let result):
                do {
                    let countries = try result.map([Country].self,
                                                   using: JSONDecoder.mtp)
                    //log.verbose("countries[\(query)]: " + countries.debugDescription)
                    return then(.success(countries))
                } catch {
                    log.error("decoding countries: \(error)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    static func loadBeaches(then: @escaping PlacesResult = { _ in }) {
        let provider = MoyaProvider<MTP>()
        provider.request(.beach) { response in
            switch response {
            case .success(let result):
                do {
                    let beaches = try result.map([Place].self,
                                                 using: JSONDecoder.mtp)
                    //log.verbose("beaches: " + beaches.debugDescription)
                    gestalt.beaches = beaches
                    return then(.success(beaches))
                } catch {
                    log.error("decoding beaches: \(error)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                log.error("failure: \(MTP.beach.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    static func loadChecklists(then: @escaping ChecklistsResult = { _ in }) {
        guard gestalt.isLoggedIn else {
            log.verbose("load checklists attempt invalid: not logged in")
            return then(.failure(.parameter))
        }

        let auth = AccessTokenPlugin { gestalt.token }
        let provider = MoyaProvider<MTP>(plugins: [auth])
        provider.request(.checklists) { response in
            switch response {
            case .success(let result):
                do {
                    let checklists = try result.map(Checklists.self,
                                                    using: JSONDecoder.mtp)
                    //log.verbose("checklists: " + checklists.debugDescription)
                    gestalt.checklists = checklists
                    return then(.success(checklists))
                } catch {
                    log.error("decoding checklists: \(error)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                log.error("failure: \(MTP.checklists.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    static func loadCountries(then: @escaping CountriesResult = { _ in }) {
        let provider = MoyaProvider<MTP>()
        provider.request(.countries) { response in
            switch response {
            case .success(let result):
                do {
                    let countries = try result.map([Country].self,
                                                   using: JSONDecoder.mtp)
                    //log.verbose("countries: " + countries.debugDescription)
                    return then(.success(countries))
                } catch {
                    log.error("decoding countries: \(error)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                log.error("failure: \(MTP.countries.path) \(message)")
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
                    //log.verbose("locations: " + locations.debugDescription)
                    gestalt.locations = locations
                    return then(.success(locations))
                } catch {
                    log.error("decoding locations: \(error)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                log.error("failure: \(MTP.location.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    static func loadUNCountries(then: @escaping CountriesResult = { _ in }) {
        let provider = MoyaProvider<MTP>()
        provider.request(.unCountry) { response in
            switch response {
            case .success(let result):
                do {
                    let unCountries = try result.map([Country].self,
                                                     using: JSONDecoder.mtp)
                    //log.verbose("unCountries: " + unCountries.debugDescription)
                    gestalt.unCountries = unCountries
                    return then(.success(unCountries))
                } catch {
                    log.error("decoding unCountries: \(error)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                log.error("failure: \(MTP.unCountry.path) \(message)")
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
                    //log.verbose("whs: " + whs.debugDescription)
                    gestalt.whs = whs
                    return then(.success(whs))
                } catch {
                    if let resultString = try? result.mapString(),
                       resultString == "{\"status\":\"Not-Modified\"}" {
                        // on staging also can check not-modified 1 in result.response.allHeaderFields
                        return then(.failure(.notModified))
                    }
                    log.error("decoding whs: \(error)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                log.error("failure: \(MTP.whs.path) \(message)")
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
                    //log.verbose("locations[\(query)]: " + locations.debugDescription)
                    return then(.success(locations))
                } catch {
                    log.error("decoding locations: \(error)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                log.error("failure: \(MTP.checklists.path) \(message)")
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
                log.error("failure: \(MTP.userGetByToken.path) \(message)")
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
        let endpoint = MTP.userLogin(email: email, password: password)
        provider.request(endpoint) { response in
            switch response {
            case .success(let result):
                return parse(result: result)
            case .failure(.underlying(AFError.responseValidationFailed, _)):
                log.error("user/login API rejection")
                return then(.failure(.status))
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                log.error("failure: \(endpoint.path) \(message)")
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

// MARK: - Support

extension MTPAPI {

    static func refreshData() {
        loadBeaches()
        loadLocations()
        loadUNCountries()
        loadWHS()
    }

    static func refreshUser() {
        guard gestalt.isLoggedIn else { return }

        userGetByToken()
        loadChecklists()
    }

    static func applicationDidBecomeActive() {
        refreshData()
        refreshUser()
    }
}
