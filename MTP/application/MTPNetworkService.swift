// @copyright Trollwerks Inc.

// swiftlint:disable file_length

import Alamofire
import Moya
import enum Result.Result

enum MTPNetworkError: Swift.Error {
    case unknown
    case message(String)
    case network(String)
    case notModified
    case parameter
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
    case countriesSearch(query: String?)
    case divesite
    case golfcourse
    case location
    case passwordReset(email: String)
    case rankings(query: RankingsQuery)
    case restaurant
    case unCountry
    case user(id: Int)
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
        case .countriesSearch:
            return "countries/search"
        case .divesite:
            return "divesite"
        case .golfcourse:
            return "golfcourse"
        case .location:
            return "location"
        case .rankings:
            return "rankings/users"
        case .passwordReset:
            return "password/reset"
        case .restaurant:
            return "restaurant"
        case .unCountry:
            return "un-country"
        case .userGetByToken:
            return "user/getByToken"
        case .user(let id):
            return "user/\(id)"
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
             .countriesSearch,
             .divesite,
             .golfcourse,
             .location,
             .rankings,
             .restaurant,
             .unCountry,
             .user,
             .userGetByToken,
             .whs:
            return .get
        case .checkIn,
             .passwordReset,
             .userLogin:
            return .post
        }
    }

    var task: Task {
        switch self {
        case let .countriesSearch(query?):
            return .requestParameters(parameters: ["query": query],
                                      encoding: URLEncoding.default)
        case .checkIn(_, let id):
             return .requestParameters(parameters: ["id": id],
                                       encoding: URLEncoding(destination: .queryString))
        case .checkOut(_, let id):
            return .requestParameters(parameters: ["id": id],
                                      encoding: URLEncoding.default)
        case .passwordReset(let email):
            return .requestParameters(parameters: ["email": email],
                                      encoding: URLEncoding(destination: .queryString))
        case .rankings(let query):
            return .requestParameters(parameters: query.parameters,
                                      encoding: URLEncoding.default)
        case let .userLogin(email, password):
            return .requestParameters(parameters: ["email": email,
                                                   "password": password],
                                      encoding: JSONEncoding.default)
        case .beach,
             .checklists,
             .countriesSearch,
             .divesite,
             .golfcourse,
             .location,
             .restaurant,
             .unCountry,
             .user,
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
             .countriesSearch,
             .divesite,
             .golfcourse,
             .location,
             .passwordReset,
             .restaurant,
             .unCountry,
             .user,
             .userLogin,
             .whs:
            return .none
        }
    }
}

extension MTP: ServiceProvider {

    var etag: String {
        return data.etags[path] ?? ""
    }
}

protocol MTPNetworkService {

    typealias MTPResult<T> = (_ result: Result<T, MTPNetworkError>) -> Void

    func check(list: Checklist,
               id: Int,
               visited: Bool,
               then: @escaping MTPResult<Bool>)
    func loadRankings(query: RankingsQuery,
                      then: @escaping MTPResult<RankingsPageInfoJSON>)
    func loadUser(id: Int,
                  then: @escaping MTPResult<UserJSON>)
    func userDeleteAccount(then: @escaping MTPResult<Bool>)
    func userForgotPassword(email: String,
                            then: @escaping MTPResult<String>)
    func userLogin(email: String,
                   password: String,
                   then: @escaping MTPResult<UserJSON>)
    func userRegister(name: String,
                      email: String,
                      password: String,
                      then: @escaping MTPResult<Bool>)

    func refreshEverything()
    func refreshRankings()
}

// swiftlint:disable:next type_body_length
struct MoyaMTPNetworkService: MTPNetworkService, ServiceProvider {

    func check(list: Checklist,
               id: Int,
               visited: Bool,
               then: @escaping MTPResult<Bool> = { _ in }) {
        if visited {
            checkIn(list: list, id: id, then: then)
        } else {
            checkOut(list: list, id: id, then: then)
        }
    }

    func checkIn(list: Checklist,
                 id: Int,
                 then: @escaping MTPResult<Bool> = { _ in }) {
        guard data.isLoggedIn else {
            log.verbose("checkIn attempt invalid: not logged in")
            return then(.failure(.parameter))
        }

        let auth = AccessTokenPlugin { self.data.token }
        let provider = MoyaProvider<MTP>(plugins: [auth])
        let endpoint = MTP.checkIn(list: list, id: id)
        provider.request(endpoint) { response in
            switch response {
            case .success:
                return then(.success(true))
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func checkOut(list: Checklist,
                  id: Int,
                  then: @escaping MTPResult<Bool> = { _ in }) {
        guard data.isLoggedIn else {
            log.verbose("checkOut attempt invalid: not logged in")
            return then(.failure(.parameter))
        }

        let auth = AccessTokenPlugin { self.data.token }
        let provider = MoyaProvider<MTP>(plugins: [auth])
        let endpoint = MTP.checkOut(list: list, id: id)
        provider.request(endpoint) { response in
            switch response {
            case .success:
                return then(.success(true))
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func loadBeaches(then: @escaping MTPResult<[PlaceJSON]> = { _ in }) {
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
                    let beaches = try result.map([PlaceJSON].self,
                                                 using: JSONDecoder.mtp)
                    self.data.set(beaches: beaches)
                    return then(.success(beaches))
                } catch {
                    self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                guard error.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                let message = error.errorDescription ?? Localized.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func loadChecklists(then: @escaping MTPResult<Checklists> = { _ in }) {
        guard data.isLoggedIn else {
            log.verbose("load checklists attempt invalid: not logged in")
            return then(.failure(.parameter))
        }

        let auth = AccessTokenPlugin { self.data.token }
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
                    self.log.verbose("checklists: succeeded")
                    self.data.checklists = checklists
                    return then(.success(checklists))
                } catch {
                    self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                guard error.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                let message = error.errorDescription ?? Localized.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func loadDiveSites(then: @escaping MTPResult<[PlaceJSON]> = { _ in }) {
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
                    let divesites = try result.map([PlaceJSON].self,
                                                   using: JSONDecoder.mtp)
                    self.data.set(divesites: divesites)
                    return then(.success(divesites))
                } catch {
                    self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                guard error.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                let message = error.errorDescription ?? Localized.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func loadGolfCourses(then: @escaping MTPResult<[PlaceJSON]> = { _ in }) {
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
                    let golfcourses = try result.map([PlaceJSON].self,
                                                     using: JSONDecoder.mtp)
                    self.data.set(golfcourses: golfcourses)
                    return then(.success(golfcourses))
                } catch {
                    self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                guard error.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                let message = error.errorDescription ?? Localized.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func loadLocations(then: @escaping MTPResult<[LocationJSON]> = { _ in }) {
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
                    let locations = try result.map([LocationJSON].self,
                                                   using: JSONDecoder.mtp)
                    self.data.set(locations: locations)
                    return then(.success(locations))
                } catch {
                    self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                guard error.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                let message = error.errorDescription ?? Localized.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func loadRankings(query: RankingsQuery,
                      then: @escaping MTPResult<RankingsPageInfoJSON> = { _ in }) {
        let provider: MoyaProvider<MTP>
        if data.isLoggedIn {
            let auth = AccessTokenPlugin { self.data.token }
            provider = MoyaProvider<MTP>(plugins: [auth])
        } else {
            provider = MoyaProvider<MTP>()
        }
        let endpoint = MTP.rankings(query: query)
        provider.request(endpoint) { response in
            switch response {
            case .success(let result):
                guard result.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                do {
                    let info = try result.map(RankingsPageInfoJSON.self,
                                              using: JSONDecoder.mtp)
                    self.data.set(rankings: query, info: info)
                    return then(.success(info))
                } catch {
                    self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                guard error.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                let message = error.errorDescription ?? Localized.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func loadRestaurants(then: @escaping MTPResult<[RestaurantJSON]> = { _ in }) {
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
                    let restaurants = try result.map([RestaurantJSON].self,
                                                     using: JSONDecoder.mtp)
                    self.data.set(restaurants: restaurants)
                    return then(.success(restaurants))
                } catch {
                    self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                guard error.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                let message = error.errorDescription ?? Localized.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func loadUNCountries(then: @escaping MTPResult<[LocationJSON]> = { _ in }) {
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
                    let uncountries = try result.map([LocationJSON].self,
                                                     using: JSONDecoder.mtp)
                    self.data.set(uncountries: uncountries)
                    return then(.success(uncountries))
                } catch {
                    self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                guard error.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                let message = error.errorDescription ?? Localized.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func loadUser(id: Int,
                  then: @escaping MTPResult<UserJSON> = { _ in }) {
        let provider = MoyaProvider<MTP>()
        let endpoint = MTP.user(id: id)
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
                    let user = try result.map(UserJSON.self,
                                              using: JSONDecoder.mtp)
                    self.data.set(userId: user)
                    return then(.success(user))
                } catch {
                    self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                guard error.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                let message = error.errorDescription ?? Localized.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func loadWHS(then: @escaping MTPResult<[WHSJSON]> = { _ in }) {
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
                    let whss = try result.map([WHSJSON].self,
                                              using: JSONDecoder.mtp)
                    self.data.set(whss: whss)
                    return then(.success(whss))
                } catch {
                    self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                guard error.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                let message = error.errorDescription ?? Localized.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func searchCountries(query: String = "",
                         then: @escaping MTPResult<[CountryJSON]>) {
        let provider = MoyaProvider<MTP>()
        let queryParam = query.isEmpty ? nil : query
        let endpoint = MTP.countriesSearch(query: queryParam)
        provider.request(endpoint) { response in
            switch response {
            case .success(let result):
                do {
                    let countries = try result.map([CountryJSON].self,
                                                   using: JSONDecoder.mtp)
                    self.data.set(countries: countries)
                    return then(.success(countries))
                } catch {
                    self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func userDeleteAccount(then: @escaping MTPResult<Bool>) {
        log.todo("implement deleteAccount")
        then(.success(true))
    }

    func userForgotPassword(email: String,
                            then: @escaping MTPResult<String>) {
        guard !email.isEmpty else {
            log.verbose("forgotPassword attempt invalid: email `\(email)`")
            return then(.failure(.parameter))
        }

        let provider = MoyaProvider<MTP>()
        let endpoint = MTP.passwordReset(email: email)
        provider.request(endpoint) { response in
            switch response {
            case .success(let result):
                do {
                    let info = try result.map(PasswordResetInfo.self,
                                              using: JSONDecoder.mtp)
                    self.log.verbose("reset password: " + info.debugDescription)
                    if info.isSuccess {
                        return then(.success(info.message))
                    } else {
                        return then(.failure(.message(info.message)))
                    }
                } catch {
                    self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                    return then(.failure(.results))
                }
            case .failure(.underlying(AFError.responseValidationFailed, _)):
                self.log.error("API rejection: \(endpoint.path)")
                return then(.failure(.status))
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func userGetByToken(then: @escaping MTPResult<UserJSON> = { _ in }) {
        guard data.isLoggedIn else {
            log.verbose("userGetByToken attempt invalid: not logged in")
            return then(.failure(.parameter))
        }

        let auth = AccessTokenPlugin { self.data.token }
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
                    let user = try result.map(UserJSON.self,
                                              using: JSONDecoder.mtp)
                    self.data.user = user
                    self.data.set(userId: user)
                    return then(.success(user))
                } catch {
                    self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                    return then(.failure(.results))
                }
            case .failure(let error):
                guard error.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                let message = error.errorDescription ?? Localized.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func userLogin(email: String,
                   password: String,
                   then: @escaping MTPResult<UserJSON>) {
        guard !email.isEmpty && !password.isEmpty else {
            log.verbose("userLogin attempt invalid: email `\(email)` password `\(password)`")
            return then(.failure(.parameter))
        }

        func parse(result: Response) {
            do {
                let user = try result.map(UserJSON.self,
                                          using: JSONDecoder.mtp)
                guard let token = user.token else { throw MTPNetworkError.token }
                data.token = token
                data.user = user
                data.email = email
                data.password = password
                log.verbose("logged in user: " + user.debugDescription)
                self.data.user = user
                self.data.set(userId: user)
                return then(.success(user))
            } catch {
                self.log.error("decoding user: \(error)")
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
                self.log.error("API rejection: \(endpoint.path)")
                return then(.failure(.status))
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func userRegister(name: String,
                      email: String,
                      password: String,
                      then: @escaping MTPResult<Bool>) {
        guard !name.isEmpty && !email.isEmpty && !password.isEmpty else {
            log.verbose("register attempt invalid: name `\(name)` email `\(email)` password `\(password)`")
            return then(.failure(.parameter))
        }

        log.todo("implement register: \(name), \(email), \(password)")

        data.email = email
        data.name = name
        data.password = password
        then(.success(true))
    }
}

extension MoyaError {

    func modified(from endpoint: MTP) -> Bool {
        guard let response = response,
             response.statusCode != 304 else {
                endpoint.markReceived()
                return false
        }
        return true
    }
}

extension Response: ServiceProvider {

    func modified(from endpoint: MTP) -> Bool {
        endpoint.markReceived()

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
            data.etags[endpoint.path] = etag
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

extension MoyaMTPNetworkService {

    func refreshEverything() {
        refreshUser()
        refreshData()
    }

    func refreshRankings() {
        var query = data.lastRankingsQuery
        Checklist.allCases.forEach { list in
            query.checklistType = list
            loadRankings(query: query)
        }
    }
}

private extension MoyaMTPNetworkService {

    func refreshData() {
        searchCountries { _ in
            self.loadLocations { _ in
                self.refreshPlaces()
                self.refreshRankings()
            }
        }
    }

    func refreshPlaces() {
        loadBeaches()
        loadDiveSites()
        loadGolfCourses()
        loadRestaurants()
        loadUNCountries()
        loadWHS()
    }

    func refreshUser() {
        guard data.isLoggedIn else { return }

        userGetByToken()
        loadChecklists()
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
