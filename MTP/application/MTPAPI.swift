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

enum MTP: Hashable {
    case beach
    case checkIn(list: Checklist, id: Int)
    case checklists
    case checkOut(list: Checklist, id: Int)
    case divesite
    case golfcourse
    case location
    case locationsSearch(parentCountry: Int?, query: String?)
    case rankings(page: RankingsPageSpec)
    case restaurant
    case unCountry
    // case user -- https://mtp.travel/api/user/1
    // case picture -- https://mtp.travel/api/files/preview?uuid=5lePRid3jo2etG0pSHqQs2&size={large|thumb|???}
    case userGetByToken
    case userLogin(email: String, password: String)
    case whs
}

extension MTP: TargetType {

    private var stagingURL: URL? { return URL(string: "https://aws.mtp.travel/api/") }
    private var productionURL: URL? { return URL(string: "https://mtp.travel/api/") }
    // swiftlint:disable:next force_unwrapping
    public var baseURL: URL { return productionURL! }

    public var preventCache: Bool { return false }

    public var path: String {
        switch self {
        case .beach:
            return "beach"
        case .checkIn(let list, _),
             .checkOut(let list, _):
            return list.path
        case .checklists:
            return "me/checklists"
        case .divesite:
            return "divesite"
        case .golfcourse:
            return "golfcourse"
        case .location:
            return "location"
        case .locationsSearch:
            return "locations/search"
        case .rankings:
            return "rankings/users"
        case .restaurant:
            return "restaurant"
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
        case .checkOut:
            return .delete
        case .beach,
             .checklists,
             .divesite,
             .golfcourse,
             .location,
             .locationsSearch,
             .rankings,
             .restaurant,
             .unCountry,
             .userGetByToken,
             .whs:
            return .get
        case .checkIn,
             .userLogin:
            return .post
        }
    }

    var task: Task {
        switch self {
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
        case .checkIn(_, let id):
             return .requestParameters(parameters: ["id": id],
                                       encoding: URLEncoding(destination: .queryString))
        case .checkOut(_, let id):
            return .requestParameters(parameters: ["id": id],
                                      encoding: URLEncoding.default)
        case .rankings(let page):
            return .requestParameters(parameters: page.parameters,
                                      encoding: URLEncoding.default)
        case .beach,
             .checklists,
             .divesite,
             .golfcourse,
             .location,
             .locationsSearch,
             .restaurant,
             .unCountry,
             .userGetByToken,
             .whs:
            if preventCache {
                return .requestParameters(parameters: ["preventCache": "1"],
                                          encoding: URLEncoding.default)
            }
            return .requestPlain
        }
    }

    var validationType: ValidationType {
        return .successCodes
    }

    // swiftlint:disable:next discouraged_optional_collection
    var headers: [String: String]? {
        var headers = ["Content-Type": "application/json; charset=utf-8",
                       "Accept": "application/json; charset=utf-8"]
        if !etag.isEmpty {
            headers["If-None-Match"] = etag
        }
        return headers
    }

    public var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8) ?? Data()
    }
}

extension MTP: AccessTokenAuthorizable {

    var authorizationType: AuthorizationType {
        switch self {
        case .checkIn,
             .checklists,
             .checkOut,
             .rankings,
             .userGetByToken:
            return .bearer
        case .beach,
             .divesite,
             .golfcourse,
             .location,
             .locationsSearch,
             .restaurant,
             .unCountry,
             .userLogin,
             .whs:
            return .none
        }
    }
}

private extension MTP {

    var etag: String {
        return gestalt.etags[path] ?? ""
    }
}

enum MTPAPI {

    typealias BoolResult = (_ result: Result<Bool, MTPAPIError>) -> Void
    typealias ChecklistsResult = (_ result: Result<Checklists, MTPAPIError>) -> Void
    typealias LocationsResult = (_ result: Result<[Location], MTPAPIError>) -> Void
    typealias PlacesResult = (_ result: Result<[Place], MTPAPIError>) -> Void
    typealias RankingsResult = (_ result: Result<RankingsPage, MTPAPIError>) -> Void
    typealias RestaurantsResult = (_ result: Result<[Restaurant], MTPAPIError>) -> Void
    typealias UserResult = (_ result: Result<User, MTPAPIError>) -> Void
    typealias WHSResult = (_ result: Result<[WHS], MTPAPIError>) -> Void

    static let parentCountryUSA = 977
}

// MARK: - Queries

extension MTPAPI {

    static func check(list: Checklist,
                      id: Int,
                      visited: Bool,
                      then: @escaping BoolResult = { _ in }) {
        if visited {
            MTPAPI.checkIn(list: list, id: id, then: then)
        } else {
            MTPAPI.checkOut(list: list, id: id, then: then)
        }
    }

    static func checkIn(list: Checklist,
                        id: Int,
                        then: @escaping BoolResult = { _ in }) {
        guard gestalt.isLoggedIn else {
            log.verbose("checkIn attempt invalid: not logged in")
            return then(.failure(.parameter))
        }

        let auth = AccessTokenPlugin { gestalt.token }
        let provider = MoyaProvider<MTP>(plugins: [auth])
        let endpoint = MTP.checkIn(list: list, id: id)
        provider.request(endpoint) { response in
            switch response {
            case .success:
                return then(.success(true))
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    static func checkOut(list: Checklist,
                         id: Int,
                         then: @escaping BoolResult = { _ in }) {
        guard gestalt.isLoggedIn else {
            log.verbose("checkOut attempt invalid: not logged in")
            return then(.failure(.parameter))
        }

        let auth = AccessTokenPlugin { gestalt.token }
        let provider = MoyaProvider<MTP>(plugins: [auth])
        let endpoint = MTP.checkOut(list: list, id: id)
        provider.request(endpoint) { response in
            switch response {
            case .success:
                return then(.success(true))
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    static func loadBeaches(then: @escaping PlacesResult = { _ in }) {
        let provider = MoyaProvider<MTP>()
        let endpoint = MTP.beach
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }
        provider.request(endpoint) { response in
            endpoint.markResponded()
            switch response {
            case .success(let result):
                guard result.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                do {
                    let beaches = try result.map([Place].self,
                                                 using: JSONDecoder.mtp)
                    log.verbose("beaches succeeded")
                    gestalt.beaches = beaches
                    return then(.success(beaches))
                } catch {
                    log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                log.error("failure: \(endpoint.path) \(message)")
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
        let endpoint = MTP.checklists
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }
        provider.request(endpoint) { response in
            endpoint.markResponded()
            switch response {
            case .success(let result):
                guard result.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                do {
                    let checklists = try result.map(Checklists.self,
                                                    using: JSONDecoder.mtp)
                    log.verbose("checklists: succeeded")
                    gestalt.checklists = checklists
                    return then(.success(checklists))
                } catch {
                    log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    static func loadDiveSites(then: @escaping PlacesResult = { _ in }) {
        let provider = MoyaProvider<MTP>()
        let endpoint = MTP.divesite
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }
        provider.request(endpoint) { response in
            endpoint.markResponded()
            switch response {
            case .success(let result):
                guard result.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                do {
                    let divesites = try result.map([Place].self,
                                                   using: JSONDecoder.mtp)
                    log.verbose("divesites succeeded")
                    gestalt.divesites = divesites
                    return then(.success(divesites))
                } catch {
                    log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    static func loadGolfCourses(then: @escaping PlacesResult = { _ in }) {
        let provider = MoyaProvider<MTP>()
        let endpoint = MTP.golfcourse
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }
        provider.request(endpoint) { response in
            endpoint.markResponded()
            switch response {
            case .success(let result):
                guard result.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                do {
                    let golfcourses = try result.map([Place].self,
                                                     using: JSONDecoder.mtp)
                    log.verbose("golfcourses succeeded")
                    gestalt.golfcourses = golfcourses
                    return then(.success(golfcourses))
                } catch {
                    log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    static func loadLocations(then: @escaping LocationsResult = { _ in }) {
        let provider = MoyaProvider<MTP>()
        let endpoint = MTP.location
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }
        provider.request(endpoint) { response in
            endpoint.markResponded()
            switch response {
            case .success(let result):
                guard result.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                do {
                    let locations = try result.map([Location].self,
                                                   using: JSONDecoder.mtp)
                    log.verbose("locations succeeded")
                    gestalt.locations = locations
                    return then(.success(locations))
                } catch {
                    log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    static func loadRankings(page: RankingsPageSpec,
                             then: @escaping RankingsResult = { _ in }) {
        let provider: MoyaProvider<MTP>
        if gestalt.isLoggedIn {
            let auth = AccessTokenPlugin { gestalt.token }
            provider = MoyaProvider<MTP>(plugins: [auth])
        } else {
            provider = MoyaProvider<MTP>()
        }
        let endpoint = MTP.rankings(page: page)
        provider.request(endpoint) { response in
            switch response {
            case .success(let result):
                guard result.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                do {
                    let page = try result.map(RankingsPage.self,
                                              using: JSONDecoder.mtp)
                    log.verbose("loadRankings succeeded:\n\(page)")
                    gestalt.rankingsPage = page
                    return then(.success(page))
                } catch {
                    log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    static func loadRestaurants(then: @escaping RestaurantsResult = { _ in }) {
        let provider = MoyaProvider<MTP>()
        let endpoint = MTP.restaurant
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }
        provider.request(endpoint) { response in
            endpoint.markResponded()
            switch response {
            case .success(let result):
                guard result.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                do {
                    let restaurants = try result.map([Restaurant].self,
                                                     using: JSONDecoder.mtp)
                    log.verbose("restaurants succeeded")
                    gestalt.restaurants = restaurants
                    return then(.success(restaurants))
                } catch {
                    log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    static func loadUNCountries(then: @escaping LocationsResult = { _ in }) {
        let provider = MoyaProvider<MTP>()
        let endpoint = MTP.unCountry
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }
        provider.request(endpoint) { response in
            endpoint.markResponded()
            switch response {
            case .success(let result):
                guard result.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                do {
                    let uncountries = try result.map([Location].self,
                                                     using: JSONDecoder.mtp)
                    log.verbose("uncountries succeeded")
                    gestalt.uncountries = uncountries
                    return then(.success(uncountries))
                } catch {
                    log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    static func loadWHS(then: @escaping WHSResult = { _ in }) {
        let provider = MoyaProvider<MTP>()
        let endpoint = MTP.whs
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }
        provider.request(endpoint) { response in
            endpoint.markResponded()
            switch response {
            case .success(let result):
                guard result.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                do {
                    let whss = try result.map([WHS].self,
                                              using: JSONDecoder.mtp)
                    log.verbose("whss succeeded")
                    gestalt.whss = whss
                    return then(.success(whss))
                } catch {
                    log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    static func locationsSearch(query: String,
                                parentCountry: Int? = nil,
                                then: @escaping LocationsResult) {
        let provider = MoyaProvider<MTP>()
        let queryParam = query.isEmpty ? nil : query
        let endpoint = MTP.locationsSearch(parentCountry: parentCountry,
                                           query: queryParam)
        provider.request(endpoint) { response in
            switch response {
            case .success(let result):
                do {
                    let locations = try result.map([Location].self,
                                                   using: JSONDecoder.mtp)
                    log.verbose("locations[\(query)] succeeded")
                    return then(.success(locations))
                } catch {
                    log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                log.error("failure: \(endpoint.path) \(message)")
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

        let auth = AccessTokenPlugin { gestalt.token }
        let provider = MoyaProvider<MTP>(plugins: [auth])
        let endpoint = MTP.userGetByToken
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }
        provider.request(endpoint) { response in
            endpoint.markResponded()
            switch response {
            case .success(let result):
                do {
                    guard result.modified(from: endpoint) else {
                        return then(.failure(.notModified))
                    }
                    let user = try result.map(User.self,
                                              using: JSONDecoder.mtp)
                    gestalt.user = user
                    log.verbose("refreshed user: " + user.debugDescription)
                    return then(.success(user))
                } catch {
                    log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                log.error("failure: \(endpoint.path) \(message)")
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

extension Response {

    func modified(from endpoint: MTP) -> Bool {
        endpoint.markReceived()

        // nothing currently supports real 304
        guard let response = response,
              response.statusCode != 304 else {
                return false
        }
        // staging sends "Not-Modified=1", production sends "not-modified=1"
        if let header = response.find(header: "Not-Modified"),
           header == "1" {
            return false
        }
        // This is the internal caching
        if let body = try? mapString(),
           body == "{\"status\":\"Not-Modified\"}" {
            return false
        }

        if let etag = response.find(header: "Etag") {
            gestalt.etags[endpoint.path] = etag
        }

        return true
    }

    var toString: String {
        return (try? mapString()) ?? "mapString failed"
    }
}

extension HTTPURLResponse {

    func find(header: String) -> String? {
        let keyValues = allHeaderFields.map {
            (String(describing: $0.key).lowercased(), String(describing: $0.value))
        }

        if let headerValue = keyValues.first(where: { $0.0 == header.lowercased() }) {
            return headerValue.1
        }
        return nil
    }
}

// MARK: - Support

extension MTPAPI {

    static func refreshData() {
        loadBeaches()
        loadDiveSites()
        loadGolfCourses()
        loadLocations()
        loadRestaurants()
        loadUNCountries()
        loadWHS()

        loadRankings(page: RankingsPageSpec())
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

private var active: Set<MTP> = []
private var received: [MTP: Date] = [:]

extension MTP {

    var isThrottled: Bool {
        guard !active.contains(self) else {
            return true
        }
        active.update(with: self)

        let throttle = TimeInterval(60 * 5)
        if let last = received[self] {
            let next = last.addingTimeInterval(throttle)
            let now = Date().toUTC
            guard next <= now else {
                return true
            }
        }
        return false
    }

    func markResponded() {
        active.remove(self)
    }

    func markReceived() {
        markResponded()
        received[self] = Date().toUTC
    }
}
