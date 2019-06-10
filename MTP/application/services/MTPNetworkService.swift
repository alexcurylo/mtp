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

    enum Map: String {
        case uncountries
        case world
    }

    enum Size: String {
        case any = ""
        case large
        case thumb
    }

    enum Status: String {
        case draft = "D"
        case published = "A"
    }

    case beach
    case checkIn(list: Checklist, id: Int)
    case checklists
    case checkOut(list: Checklist, id: Int)
    case countriesSearch(query: String?)
    case divesite
    case geoJson(map: Map)
    case golfcourse
    case location
    case locationPhotos(location: Int)
    case locationPosts(location: Int)
    case passwordReset(email: String)
    case picture(uuid: String, size: Size)
    case photos(user: Int?, page: Int)
    case rankings(query: RankingsQuery)
    case restaurant
    case scorecard(list: Checklist, user: Int)
    case search(query: String?)
    case settings
    case unCountry
    case user(id: Int)
    case userDelete(id: Int)
    case userGetByToken
    case userPosts(id: Int)
    case userLogin(email: String, password: String)
    case userRegister(info: RegistrationInfo)
    case whs

    // GET minimap: /minimaps/{user_id}.png
    // force map reload: POST /api/users/{user_id}/minimap
}

extension MTP: TargetType {

    // swiftlint:disable:next force_unwrapping
    public var baseURL: URL { return URL(string: "https://mtp.travel/api/")! }

    public var preventCache: Bool { return false }

    public var path: String {
        switch self {
        case .beach:
            return "beach"
        case .checkIn(let list, _),
             .checkOut(let list, _):
            return "me/checklists/\(list.rawValue)"
        case .checklists:
            return "me/checklists"
        case .countriesSearch:
            return "countries/search"
        case .divesite:
            return "divesite"
        case .geoJson(let map):
            return "geojson-files/\(map.rawValue)-map"
        case .golfcourse:
            return "golfcourse"
        case .location:
            return "location"
        case .locationPhotos(let location):
            return "locations/\(location)/photos"
        case .locationPosts(let location):
            return "locations/\(location)/posts"
        case .photos(let user?, _):
            return "users/\(user)/photos"
        case .photos:
            return "users/me/photos"
        case .picture:
            return "files/preview"
        case .rankings:
            return "rankings/users"
        case .passwordReset:
            return "password/reset"
        case .restaurant:
            return "restaurant"
        case let .scorecard(list, user):
            return "users/\(user)/scorecard/\(list.rawValue)"
        case .search:
            return "search"
        case .settings:
            return "settings"
        case .unCountry:
            return "un-country"
        case .userGetByToken:
            return "user/getByToken"
        case .user(let id),
             .userDelete(let id):
            return "user/\(id)"
        case .userPosts(let id):
            return "users/\(id)/location-posts"
        case .userLogin:
            return "user/login"
        case .userRegister:
            return "user"
        case .whs:
            return "whs"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .checkOut,
             .userDelete:
            return .delete
        case .beach,
             .checklists,
             .countriesSearch,
             .divesite,
             .geoJson,
             .golfcourse,
             .location,
             .locationPhotos,
             .locationPosts,
             .photos,
             .picture,
             .rankings,
             .restaurant,
             .scorecard,
             .search,
             .settings,
             .unCountry,
             .user,
             .userGetByToken,
             .userPosts,
             .whs:
            return .get
        case .checkIn,
             .passwordReset,
             .userLogin,
             .userRegister:
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
        case .locationPosts: // &limit=1&page=1&orderBy=-created_at
            return .requestParameters(parameters: ["status": Status.published.rawValue],
                                      encoding: URLEncoding.default)
        case .passwordReset(let email):
            return .requestParameters(parameters: ["email": email],
                                      encoding: URLEncoding(destination: .queryString))
        case .photos(_, let page):
            return .requestParameters(parameters: ["page": page],
                                      encoding: URLEncoding.default)
        case .picture(let uuid, .any):
            return .requestParameters(parameters: ["uuid": uuid],
                                      encoding: URLEncoding.default)
        case let .picture(uuid, size):
            return .requestParameters(parameters: ["uuid": uuid,
                                                   "size": size.rawValue],
                                      encoding: URLEncoding.default)
        case .rankings(let query):
            return .requestParameters(parameters: query.parameters,
                                      encoding: URLEncoding.default)
        case let .search(query?):
            return .requestParameters(parameters: ["query": query],
                                      encoding: URLEncoding.default)
        case let .userLogin(email, password):
            return .requestParameters(parameters: ["email": email,
                                                   "password": password],
                                      encoding: JSONEncoding.default)
        case .userRegister(let info):
            return .requestJSONEncodable(info)
        case .beach,
             .checklists,
             .countriesSearch,
             .divesite,
             .geoJson,
             .golfcourse,
             .location,
             .locationPhotos, // &page=1&orderBy=-created_at&limit=6
             .restaurant,
             .scorecard,
             .search,
             .settings,
             .unCountry,
             .user,
             .userDelete,
             .userGetByToken,
             .userPosts,
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

    var requestUrl: URL? {
        let request = try? MoyaProvider.defaultEndpointMapping(for: self).urlRequest()
        return request?.url
    }
}

extension MTP: AccessTokenAuthorizable {

    var authorizationType: AuthorizationType {
        switch self {
        case .checkIn,
             .checklists,
             .checkOut,
             .photos,
             .rankings,
             .userDelete,
             .userGetByToken:
            return .bearer
        case .beach,
             .countriesSearch,
             .divesite,
             .geoJson,
             .golfcourse,
             .location,
             .locationPhotos,
             .locationPosts,
             .passwordReset,
             .picture,
             .restaurant,
             .scorecard,
             .search,
             .settings,
             .unCountry,
             .user,
             .userLogin,
             .userPosts,
             .userRegister,
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
    func loadPhotos(location id: Int,
                    then: @escaping MTPResult<PhotosInfoJSON>)
    func loadPhotos(user id: Int,
                    page: Int,
                    then: @escaping MTPResult<PhotosPageInfoJSON>)
    func loadPosts(location id: Int,
                   then: @escaping MTPResult<PostsJSON>)
    func loadPosts(user id: Int,
                   then: @escaping MTPResult<PostsJSON>)
    func loadRankings(query: RankingsQuery,
                      then: @escaping MTPResult<RankingsPageInfoJSON>)
    func loadScorecard(list: Checklist,
                       user id: Int,
                       then: @escaping MTPResult<ScorecardJSON>)
    func loadUser(id: Int,
                  then: @escaping MTPResult<UserJSON>)
    func search(query: String,
                then: @escaping MTPResult<SearchResultJSON>)
    func userDeleteAccount(then: @escaping MTPResult<String>)
    func userForgotPassword(email: String,
                            then: @escaping MTPResult<String>)
    func userLogin(email: String,
                   password: String,
                   then: @escaping MTPResult<UserJSON>)
    func userRegister(info: RegistrationInfo,
                      then: @escaping MTPResult<UserJSON>)

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

    func loadChecklists(then: @escaping MTPResult<Checked> = { _ in }) {
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
                    let visited = try result.map(Checked.self,
                                                 using: JSONDecoder.mtp)
                    self.data.visited = visited
                    return then(.success(visited))
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

    func loadPhotos(location id: Int,
                    then: @escaping MTPResult<PhotosInfoJSON> = { _ in }) {
        let provider = MoyaProvider<MTP>()
        let endpoint = MTP.locationPhotos(location: id)
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
                    let photos = try result.map(PhotosInfoJSON.self,
                                                using: JSONDecoder.mtp)
                    self.data.set(location: id, photos: photos)
                    return then(.success(photos))
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

    func loadPhotos(user id: Int,
                    page: Int,
                    then: @escaping MTPResult<PhotosPageInfoJSON> = { _ in }) {
        guard data.isLoggedIn else {
            log.verbose("load photos attempt invalid: not logged in")
            return then(.failure(.parameter))
        }

        let auth = AccessTokenPlugin { self.data.token }
        let provider = MoyaProvider<MTP>(plugins: [auth])
        let endpoint = MTP.photos(user: id, page: page)
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
                    let info = try result.map(PhotosPageInfoJSON.self,
                                              using: JSONDecoder.mtp)
                    self.data.set(photos: page, user: id, info: info)
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

    func loadPosts(location id: Int,
                   then: @escaping MTPResult<PostsJSON> = { _ in }) {
        let provider = MoyaProvider<MTP>()
        let endpoint = MTP.locationPosts(location: id)
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
                    let posts = try result.map(PostsJSON.self,
                                               using: JSONDecoder.mtp)
                    self.data.set(location: id, posts: posts.data)
                    return then(.success(posts))
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

    func loadPosts(user id: Int,
                   then: @escaping MTPResult<PostsJSON> = { _ in }) {
        guard data.isLoggedIn else {
            log.verbose("load posts attempt invalid: not logged in")
            return then(.failure(.parameter))
        }

        let auth = AccessTokenPlugin { self.data.token }
        let provider = MoyaProvider<MTP>(plugins: [auth])
        let endpoint = MTP.userPosts(id: id)
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
                    let posts = try result.map(PostsJSON.self,
                                               using: JSONDecoder.mtp)
                    self.data.set(posts: posts.data)
                    return then(.success(posts))
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

    func loadScorecard(list: Checklist,
                       user id: Int,
                       then: @escaping MTPResult<ScorecardJSON> = { _ in }) {
        let provider = MoyaProvider<MTP>()
        let endpoint = MTP.scorecard(list: list, user: id)
        provider.request(endpoint) { response in
            switch response {
            case .success(let result):
                guard result.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                do {
                    let scorecard = try result.map(ScorecardWrapperJSON.self,
                                                   using: JSONDecoder.mtp)
                    self.data.set(scorecard: scorecard)
                    return then(.success(scorecard.data))
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

    func loadSettings(then: @escaping MTPResult<SettingsJSON> = { _ in }) {
        let provider = MoyaProvider<MTP>()
        let endpoint = MTP.settings
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
                    let settings = try result.map(SettingsJSON.self,
                                                  using: JSONDecoder.mtp)
                    self.data.settings = settings
                    return then(.success(settings))
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
                    self.data.set(user: user)
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

    func search(query: String,
                then: @escaping MTPResult<SearchResultJSON>) {
        let provider = MoyaProvider<MTP>()
        let queryParam = query.isEmpty ? nil : query
        let endpoint = MTP.search(query: queryParam)
        provider.request(endpoint) { response in
            switch response {
            case .success(let result):
                do {
                    let results = try result.map(SearchResultJSON.self,
                                                 using: JSONDecoder.mtp)
                    return then(.success(results))
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

    func userDeleteAccount(then: @escaping MTPResult<String>) {
        guard let userId = data.user?.id else {
            log.verbose("userDeleteAccount attempt invalid: not logged in")
            return then(.failure(.parameter))
        }

        let auth = AccessTokenPlugin { self.data.token }
        let provider = MoyaProvider<MTP>(plugins: [auth])
        let endpoint = MTP.userDelete(id: userId)
        provider.request(endpoint) { response in
            switch response {
            case .success(let result):
                do {
                    let info = try result.map(OperationInfo.self,
                                              using: JSONDecoder.mtp)
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

        let provider = MoyaProvider<MTP>()
        let endpoint = MTP.userLogin(email: email, password: password)

        func parse(success response: Response) {
            do {
                let user = try response.map(UserJSON.self,
                                            using: JSONDecoder.mtp)
                guard let token = user.token else { throw MTPNetworkError.token }
                log.verbose("logged in user: " + user.debugDescription)
                data.token = token
                data.user = user
                refreshUserInfo()
                return then(.success(user))
            } catch {
                log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                return then(.failure(.results))
            }
        }

        func parse(error response: Response?) {
            guard let response = response else {
                return then(.failure(.results))
            }

            do {
                let info = try response.map(OperationInfo.self,
                                            using: JSONDecoder.mtp)
                return then(.failure(.message(info.message)))
            } catch {
                self.log.error("decoding error response: \(error)\n-\n\(response.toString)")
                return then(.failure(.results))
            }
        }

        provider.request(endpoint) { result in
            switch result {
            case .success(let response):
                return parse(success: response)
            case .failure(.underlying(_, let response)):
                return parse(error: response)
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                self.log.error("failure: \(endpoint.path) \(message) \(error)")
                return then(.failure(.network(message)))
            }
        }
    }

    func userRegister(info: RegistrationInfo,
                      then: @escaping MTPResult<UserJSON>) {
        guard info.isValid else {
            log.verbose("register attempt invalid: \(info)")
            return then(.failure(.parameter))
        }

        let provider = MoyaProvider<MTP>()
        let endpoint = MTP.userRegister(info: info)

        func parse(result: Response) {
            do {
                let user = try result.map(UserJSON.self,
                                          using: JSONDecoder.mtp)
                guard let token = user.token else { throw MTPNetworkError.token }
                log.verbose("registered user: " + user.debugDescription)
                log.verbose("from result: " + result.toString)
                data.token = token
                data.user = user
                userGetByToken { _ in
                    then(.success(user))
                }
            } catch {
                log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                return then(.failure(.results))
            }
        }

        provider.request(endpoint) { response in
            switch response {
            case .success(let result):
                return parse(result: result)
            case .failure(let error):
                let message = error.errorDescription ?? Localized.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
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
        loadSettings()
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

        userGetByToken { _ in
            self.refreshUserInfo()
        }
    }

    func refreshUserInfo() {
        guard let user = data.user else { return }

        loadChecklists()
        loadPosts(user: user.id)
        loadPhotos(user: user.id, page: 1)
        Checklist.allCases.forEach { list in
            loadScorecard(list: list, user: user.id)
        }
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

    static func unthrottle() {
        active = []
        received = [:]
    }

    func markResponded() {
        active.remove(self)
    }

    func markReceived() {
        markResponded()
        received[self] = Date().toUTC
    }
}
