// @copyright Trollwerks Inc.

// swiftlint:disable file_length

import Alamofire
import Moya
import enum Result.Result

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
    case faq
    case geoJson(map: Map)
    case golfcourse
    case location
    case locationPhotos(location: Int)
    case locationPosts(location: Int)
    case passwordReset(email: String)
    case picture(uuid: String, size: Size)
    case photos(user: Int?, page: Int)
    case postPublish(payload: PostPayload)
    case rankings(query: RankingsQuery)
    case restaurant
    case scorecard(list: Checklist, user: Int)
    case search(query: String?)
    case settings
    case unCountry
    case upload(photo: Data, caption: String?, location: Int?)
    case userDelete(id: Int)
    case userGet(id: Int)
    case userGetByToken
    case userPosts(id: Int)
    case userPut(payload: UserUpdatePayload)
    case userLogin(email: String, password: String)
    case userRegister(payload: RegistrationPayload)
    case userVerify(id: Int)
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
            return "me/checklists/\(list.key)"
        case .checklists:
            return "me/checklists"
        case .countriesSearch:
            return "countries/search"
        case .divesite:
            return "divesite"
        case .faq:
            return "article/faq"
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
        case .postPublish:
            return "location-posts"
        case .rankings:
            return "rankings/users"
        case .passwordReset:
            return "password/reset"
        case .restaurant:
            return "restaurant"
        case let .scorecard(list, user):
            return "users/\(user)/scorecard/\(list.key)"
        case .search:
            return "search"
        case .settings:
            return "settings"
        case .unCountry:
            return "un-country"
        case .upload:
            return "files/upload"
        case .userGetByToken:
            return "user/getByToken"
        case .userDelete(let id),
             .userGet(let id):
            return "user/\(id)"
        case .userPut(let payload):
            return "user/\(payload.id)"
        case .userPosts(let id):
            return "users/\(id)/location-posts"
        case .userLogin:
            return "user/login"
        case .userRegister:
            return "user"
        case .userVerify(let id):
            return "users/\(id)/send-verification-email"
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
             .faq,
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
             .userGet,
             .userGetByToken,
             .userPosts,
             .userVerify,
             .whs:
            return .get
        case .checkIn,
             .passwordReset,
             .postPublish,
             .upload,
             .userLogin,
             .userRegister:
            return .post
        case .userPut:
            return .put
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
                                      encoding: URLEncoding(destination: .queryString))
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
        case let .upload(photo: photo, caption: caption, location: location):
            let filePart = MultipartFormData(provider: .data(photo),
                                             name: "files[0]",
                                             fileName: "photo.jpeg",
                                             mimeType: "iimage/jpeg")
            var parts = [filePart]
            if let caption = caption,
               !caption.isEmpty,
               let captionData = caption.data(using: .utf8) {
                let captionPart = MultipartFormData(provider: .data(captionData),
                                                    name: "args[0][desc]")
                parts.append(captionPart)
            }
            if let location = location,
                location > 0,
                let locationData = "\(location)".data(using: .utf8) {
                let locationPart = MultipartFormData(provider: .data(locationData),
                                                     name: "args[0][location_id]")
                parts.append(locationPart)
            }
            return .uploadMultipart(parts)
        case let .userLogin(email, password):
            return .requestParameters(parameters: ["email": email,
                                                   "password": password],
                                      encoding: JSONEncoding.default)
        case .postPublish(let payload):
            return .requestJSONEncodable(payload)
        case .userPut(let payload):
            return .requestJSONEncodable(payload)
        case .userRegister(let payload):
            return .requestJSONEncodable(payload)
        case .userVerify:
            return .requestParameters(parameters: ["preventCache": "1"],
                                      encoding: URLEncoding.default)
        case .beach,
             .checklists,
             .countriesSearch,
             .divesite,
             .faq,
             .geoJson,
             .golfcourse,
             .location,
             .locationPhotos, // &page=1&orderBy=-created_at&limit=6
             .restaurant,
             .scorecard,
             .search,
             .settings,
             .unCountry,
             .userDelete,
             .userGet,
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
        switch self {
        case .userLogin:
            return .none // expect 401 with wrong password message
        default:
            return .successCodes
        }
    }

    // swiftlint:disable:next discouraged_optional_collection
    var headers: [String: String]? {
        var headers: [String: String] = [:]
        headers["Accept"] = "application/json; charset=utf-8"

        switch self {
        case .upload:
            headers["Content-Type"] = "multipart/form-data"
        default:
            headers["Content-Type"] = "application/json; charset=utf-8"
            if !etag.isEmpty {
                headers["If-None-Match"] = etag
            }
        }

        return headers
    }

    public var sampleData: Data {
        let file: String
        switch self {
        case .checklists,
             .userGetByToken:
            file = "\(self)"
        //case let .photos(user?, page):
            //file = "photos-\(user)-\(page)"
        case .photos(_, let page):
            file = "photos-7853-\(page)"
        case .rankings:
            file = "rankings"
        case let .scorecard(list, _):
            //file = "scorecard-\(list.key)-\(user)"
            file = "scorecard-\(list.key)-7853"
        case .userGet:
            //file = "userGet-\(id)"
            file = "userGet-1"
        case .userPosts:
            //file = "userPosts-\(id)"
            file = "userPosts-7853"
        default:
            log.error("sampleData not provided for \(self)")
            return "{}".data(using: String.Encoding.utf8) ?? Data()
        }

        do {
            let path = try unwrap(Bundle.main.path(forResource: file,
                                                   ofType: "json"))
            let data = try Data(contentsOf: URL(fileURLWithPath: path),
                                options: .mappedIfSafe)
            return data
        } catch {
            log.error("could not load sampleData for \(self)")
            return Data()
        }
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
             .postPublish,
             .rankings,
             .upload,
             .userDelete,
             .userGetByToken,
             .userPut,
             .userVerify:
            return .bearer
        case .beach,
             .countriesSearch,
             .divesite,
             .faq,
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
             .userGet,
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

typealias MTPProvider = MoyaProvider<MTP>

// swiftlint:disable:next type_body_length
struct MTPNetworkController: ServiceProvider {

    func set(items: [Checklist.Item],
             visited: Bool,
             then: @escaping NetworkCompletion<Bool>) {
        guard let item = items.first else {
            then(.success(true))
            return
        }

        if visited {
            checkIn(list: item.list, id: item.id) { result in
                switch result {
                case .success:
                    self.set(items: Array(items.dropFirst()),
                             visited: visited,
                             then: then)
                default:
                    then(result)
                }
            }
        } else {
            checkOut(list: item.list, id: item.id) { result in
                switch result {
                case .success:
                    self.set(items: Array(items.dropFirst()),
                             visited: visited,
                             then: then)
                default:
                    then(result)
                }
            }
        }
    }

    func checkIn(list: Checklist,
                 id: Int,
                 then: @escaping NetworkCompletion<Bool>) {
        guard data.isLoggedIn else {
            return then(.failure(.parameter))
        }

        let auth = AccessTokenPlugin { self.data.token }
        let provider = MTPProvider(plugins: [auth])
        let endpoint = MTP.checkIn(list: list, id: id)
        provider.request(endpoint) { response in
            switch response {
            case .success:
                return then(.success(true))
            case let .failure(.underlying(error, response)):
                let problem = self.parse(error: error, response: response)
                return then(.failure(problem))
            case .failure(let error):
                let message = error.errorDescription ?? L.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func checkOut(list: Checklist,
                  id: Int,
                  then: @escaping NetworkCompletion<Bool>) {
        guard data.isLoggedIn else {
            return then(.failure(.parameter))
        }

        let auth = AccessTokenPlugin { self.data.token }
        let provider = MTPProvider(plugins: [auth])
        let endpoint = MTP.checkOut(list: list, id: id)
        provider.request(endpoint) { response in
            switch response {
            case .success:
                return then(.success(true))
            case let .failure(.underlying(error, response)):
                let problem = self.parse(error: error, response: response)
                return then(.failure(problem))
            case .failure(let error):
                let message = error.errorDescription ?? L.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func loadBeaches(then: @escaping NetworkCompletion<[PlaceJSON]> = { _ in }) {
        let provider = MTPProvider()
        let endpoint = MTP.beach
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        //swiftlint:disable:next closure_body_length
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
                    return then(.failure(.decoding))
                }
            case let .failure(.underlying(error, response)):
                let problem = self.parse(error: error, response: response)
                return then(.failure(problem))
            case .failure(let error):
                guard error.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                let message = error.errorDescription ?? L.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func loadChecklists(stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
                        then: @escaping NetworkCompletion<Checked> = { _ in }) {
        guard data.isLoggedIn else {
            return then(.failure(.parameter))
        }

        let auth = AccessTokenPlugin { self.data.token }
        let provider = MTPProvider(stubClosure: stub, plugins: [auth])
        let endpoint = MTP.checklists
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        //swiftlint:disable:next closure_body_length
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
                    return then(.failure(.decoding))
                }
            case let .failure(.underlying(error, response)):
                let problem = self.parse(error: error, response: response)
                return then(.failure(problem))
            case .failure(let error):
                guard error.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                let message = error.errorDescription ?? L.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func loadDiveSites(then: @escaping NetworkCompletion<[PlaceJSON]> = { _ in }) {
        let provider = MTPProvider()
        let endpoint = MTP.divesite
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        //swiftlint:disable:next closure_body_length
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
                    return then(.failure(.decoding))
                }
            case let .failure(.underlying(error, response)):
                let problem = self.parse(error: error, response: response)
                return then(.failure(problem))
            case .failure(let error):
                guard error.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                let message = error.errorDescription ?? L.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func loadGolfCourses(then: @escaping NetworkCompletion<[PlaceJSON]> = { _ in }) {
        let provider = MTPProvider()
        let endpoint = MTP.golfcourse
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        //swiftlint:disable:next closure_body_length
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
                    return then(.failure(.decoding))
                }
            case let .failure(.underlying(error, response)):
                let problem = self.parse(error: error, response: response)
                return then(.failure(problem))
            case .failure(let error):
                guard error.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                let message = error.errorDescription ?? L.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func loadLocations(then: @escaping NetworkCompletion<[LocationJSON]> = { _ in }) {
        let provider = MTPProvider()
        let endpoint = MTP.location
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        //swiftlint:disable:next closure_body_length
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
                    return then(.failure(.decoding))
                }
            case let .failure(.underlying(error, response)):
                let problem = self.parse(error: error, response: response)
                return then(.failure(problem))
            case .failure(let error):
                guard error.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                let message = error.errorDescription ?? L.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func loadPhotos(location id: Int,
                    reload: Bool,
                    then: @escaping NetworkCompletion<PhotosInfoJSON> = { _ in }) {
        let provider = MTPProvider()
        let endpoint = MTP.locationPhotos(location: id)
        guard reload || !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        //swiftlint:disable:next closure_body_length
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
                    return then(.failure(.decoding))
                }
            case let .failure(.underlying(error, response)):
                let problem = self.parse(error: error, response: response)
                return then(.failure(problem))
            case .failure(let error):
                guard error.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                let message = error.errorDescription ?? L.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func loadPhotos(page: Int,
                    reload: Bool,
                    stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
                    then: @escaping NetworkCompletion<PhotosPageInfoJSON> = { _ in }) {
        loadPhotos(id: nil,
                   page: page,
                   reload: reload,
                   stub: stub,
                   then: then)
    }

    func loadPhotos(profile id: Int,
                    page: Int,
                    reload: Bool,
                    stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
                    then: @escaping NetworkCompletion<PhotosPageInfoJSON> = { _ in }) {
        loadPhotos(id: id,
                   page: page,
                   reload: reload,
                   stub: stub,
                   then: then)
    }

    func loadPhotos(id: Int?,
                    page: Int,
                    reload: Bool,
                    stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
                    then: @escaping NetworkCompletion<PhotosPageInfoJSON>) {
        guard data.isLoggedIn else {
            return then(.failure(.parameter))
        }

        let auth = AccessTokenPlugin { self.data.token }
        let provider = MTPProvider(stubClosure: stub, plugins: [auth])
        let endpoint = MTP.photos(user: id, page: page)
        guard reload || !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        //swiftlint:disable:next closure_body_length
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
                    if let id = id {
                        self.data.set(photos: page, user: id, info: info)
                    } else if let userId = self.data.user?.id {
                        self.data.set(photos: page, user: userId, info: info)
                    }
                    return then(.success(info))
                } catch {
                    self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                    return then(.failure(.decoding))
                }
            case let .failure(.underlying(error, response)):
                let problem = self.parse(error: error, response: response)
                return then(.failure(problem))
            case .failure(let error):
                guard error.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                let message = error.errorDescription ?? L.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func loadPosts(location id: Int,
                   then: @escaping NetworkCompletion<PostsJSON> = { _ in }) {
        let provider = MTPProvider()
        let endpoint = MTP.locationPosts(location: id)
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        //swiftlint:disable:next closure_body_length
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
                    return then(.failure(.decoding))
                }
            case let .failure(.underlying(error, response)):
                let problem = self.parse(error: error, response: response)
                return then(.failure(problem))
            case .failure(let error):
                guard error.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                let message = error.errorDescription ?? L.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func loadPosts(user id: Int,
                   stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
                   then: @escaping NetworkCompletion<PostsJSON> = { _ in }) {
        guard data.isLoggedIn else {
            return then(.failure(.parameter))
        }

        let auth = AccessTokenPlugin { self.data.token }
        let provider = MTPProvider(stubClosure: stub, plugins: [auth])
        let endpoint = MTP.userPosts(id: id)
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        //swiftlint:disable:next closure_body_length
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
                    return then(.failure(.decoding))
                }
            case let .failure(.underlying(error, response)):
                let problem = self.parse(error: error, response: response)
                return then(.failure(problem))
            case .failure(let error):
                guard error.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                let message = error.errorDescription ?? L.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func loadRankings(query: RankingsQuery,
                      stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
                      then: @escaping NetworkCompletion<RankingsPageInfoJSON> = { _ in }) {
        let provider: MTPProvider
        if data.isLoggedIn {
            let auth = AccessTokenPlugin { self.data.token }
            provider = MTPProvider(stubClosure: stub, plugins: [auth])
        } else {
            provider = MTPProvider(stubClosure: stub)
        }
        let endpoint = MTP.rankings(query: query)

        //swiftlint:disable:next closure_body_length
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
                    return then(.failure(.decoding))
                }
            case let .failure(.underlying(error, response)):
                let problem = self.parse(error: error, response: response)
                return then(.failure(problem))
            case .failure(let error):
                guard error.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                let message = error.errorDescription ?? L.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func loadRestaurants(then: @escaping NetworkCompletion<[RestaurantJSON]> = { _ in }) {
        let provider = MTPProvider()
        let endpoint = MTP.restaurant
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        //swiftlint:disable:next closure_body_length
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
                    return then(.failure(.decoding))
                }
            case let .failure(.underlying(error, response)):
                let problem = self.parse(error: error, response: response)
                return then(.failure(problem))
            case .failure(let error):
                guard error.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                let message = error.errorDescription ?? L.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func loadScorecard(list: Checklist,
                       user id: Int,
                       stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
                       then: @escaping NetworkCompletion<ScorecardJSON> = { _ in }) {
        let provider = MTPProvider(stubClosure: stub)
        let endpoint = MTP.scorecard(list: list, user: id)

        //swiftlint:disable:next closure_body_length
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
                    return then(.failure(.decoding))
                }
            case let .failure(.underlying(error, response)):
                let problem = self.parse(error: error, response: response)
                return then(.failure(problem))
            case .failure(let error):
                guard error.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                let message = error.errorDescription ?? L.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func loadSettings(then: @escaping NetworkCompletion<SettingsJSON> = { _ in }) {
        let provider = MTPProvider()
        let endpoint = MTP.settings
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        //swiftlint:disable:next closure_body_length
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
                    self.data.set(milestones: settings)
                    return then(.success(settings))
                } catch {
                    self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                    return then(.failure(.decoding))
                }
            case let .failure(.underlying(error, response)):
                let problem = self.parse(error: error, response: response)
                return then(.failure(problem))
            case .failure(let error):
                guard error.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                let message = error.errorDescription ?? L.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func loadUNCountries(then: @escaping NetworkCompletion<[LocationJSON]> = { _ in }) {
        let provider = MTPProvider()
        let endpoint = MTP.unCountry
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        //swiftlint:disable:next closure_body_length
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
                    return then(.failure(.decoding))
                }
            case let .failure(.underlying(error, response)):
                let problem = self.parse(error: error, response: response)
                return then(.failure(problem))
            case .failure(let error):
                guard error.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                let message = error.errorDescription ?? L.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func loadUser(id: Int,
                  stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
                  then: @escaping NetworkCompletion<UserJSON> = { _ in }) {
        let provider = MTPProvider(stubClosure: stub)
        let endpoint = MTP.userGet(id: id)
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        //swiftlint:disable:next closure_body_length
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
                    return then(.failure(.decoding))
                }
            case let .failure(.underlying(error, response)):
                let problem = self.parse(error: error, response: response)
                return then(.failure(problem))
            case .failure(let error):
                guard error.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                let message = error.errorDescription ?? L.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func loadWHS(then: @escaping NetworkCompletion<[WHSJSON]> = { _ in }) {
        let provider = MTPProvider()
        let endpoint = MTP.whs
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        //swiftlint:disable:next closure_body_length
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
                    return then(.failure(.decoding))
                }
            case let .failure(.underlying(error, response)):
                let problem = self.parse(error: error, response: response)
                return then(.failure(problem))
            case .failure(let error):
                guard error.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                let message = error.errorDescription ?? L.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func postPublish(payload: PostPayload,
                     then: @escaping NetworkCompletion<PostReply>) {
        guard data.isLoggedIn else {
            return then(.failure(.parameter))
        }

        let auth = AccessTokenPlugin { self.data.token }
        let provider = MTPProvider(plugins: [auth])
        let endpoint = MTP.postPublish(payload: payload)

        func parse(success response: Response) {
            do {
                let reply = try response.map(PostReply.self,
                                             using: JSONDecoder.mtp)
                self.data.set(post: reply)
                return then(.success(reply))
            } catch {
                do {
                    let reply = try response.map(OperationReply.self,
                                                 using: JSONDecoder.mtp)
                    return then(.failure(.message(reply.message)))
                } catch {
                    log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                    return then(.failure(.decoding))
                }
            }
        }

        provider.request(endpoint) { response in
            switch response {
            case .success(let response):
                return parse(success: response)
            case .failure(.underlying(AFError.responseValidationFailed, _)):
                self.log.error("API rejection: \(endpoint.path)")
                return then(.failure(.status))
            case let .failure(.underlying(error, response)):
                let problem = self.parse(error: error, response: response)
                return then(.failure(problem))
            case .failure(let error):
                let message = error.errorDescription ?? L.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func searchCountries(query: String = "",
                         then: @escaping NetworkCompletion<[CountryJSON]>) {
        let provider = MTPProvider()
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
                    return then(.failure(.decoding))
                }
            case let .failure(.underlying(error, response)):
                let problem = self.parse(error: error, response: response)
                return then(.failure(problem))
            case .failure(let error):
                let message = error.errorDescription ?? L.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func search(query: String,
                then: @escaping NetworkCompletion<SearchResultJSON>) {
        let provider = MTPProvider()
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
                    return then(.failure(.decoding))
                }
            case let .failure(.underlying(error, response)):
                let problem = self.parse(error: error, response: response)
                return then(.failure(problem))
            case .failure(let error):
                let message = error.errorDescription ?? L.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func upload(photo: Data,
                caption: String?,
                location id: Int?,
                then: @escaping NetworkCompletion<PhotoReply>) {
        guard data.isLoggedIn else {
            return then(.failure(.parameter))
        }

        let auth = AccessTokenPlugin { self.data.token }
        let provider = MTPProvider(plugins: [auth])
        let endpoint = MTP.upload(photo: photo,
                                  caption: caption,
                                  location: id)

        func parse(success response: Response) {
            do {
                let replies = try response.map([PhotoReply].self,
                                               using: JSONDecoder.mtp)
                let reply = try unwrap(replies.first)
                self.data.set(photo: reply)
                return then(.success(reply))
            } catch {
                do {
                    let reply = try response.map(OperationReply.self,
                                                 using: JSONDecoder.mtp)
                    return then(.failure(.message(reply.message)))
                } catch {
                    log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                    return then(.failure(.decoding))
                }
            }
        }

        provider.request(endpoint) { response in
            switch response {
            case .success(let response):
                return parse(success: response)
            case .failure(.underlying(AFError.responseValidationFailed, _)):
                self.log.error("API rejection: \(endpoint.path)")
                return then(.failure(.status))
            case let .failure(.underlying(error, response)):
                let problem = self.parse(error: error, response: response)
                return then(.failure(problem))
            case .failure(let error):
                let message = error.errorDescription ?? L.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func userDeleteAccount(then: @escaping NetworkCompletion<String>) {
        guard let userId = data.user?.id else {
            return then(.failure(.parameter))
        }

        let auth = AccessTokenPlugin { self.data.token }
        let provider = MTPProvider(plugins: [auth])
        let endpoint = MTP.userDelete(id: userId)

        //swiftlint:disable:next closure_body_length
        provider.request(endpoint) { response in
            switch response {
            case .success(let result):
                do {
                    let reply = try result.map(OperationReply.self,
                                               using: JSONDecoder.mtp)
                    if reply.isSuccess {
                        return then(.success(reply.message))
                    } else {
                        return then(.failure(.message(reply.message)))
                    }
                } catch {
                    self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                    return then(.failure(.decoding))
                }
            case .failure(.underlying(AFError.responseValidationFailed, _)):
                self.log.error("API rejection: \(endpoint.path)")
                return then(.failure(.status))
            case let .failure(.underlying(error, response)):
                let problem = self.parse(error: error, response: response)
                return then(.failure(problem))
            case .failure(let error):
                let message = error.errorDescription ?? L.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func userForgotPassword(email: String,
                            then: @escaping NetworkCompletion<String>) {
        guard !email.isEmpty else {
            return then(.failure(.parameter))
        }

        let provider = MTPProvider()
        let endpoint = MTP.passwordReset(email: email)

        //swiftlint:disable:next closure_body_length
        provider.request(endpoint) { response in
            switch response {
            case .success(let result):
                do {
                    let reply = try result.map(PasswordResetReply.self,
                                               using: JSONDecoder.mtp)
                    if reply.isSuccess {
                        return then(.success(reply.message))
                    } else {
                        return then(.failure(.message(reply.message)))
                    }
                } catch {
                    self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                    return then(.failure(.decoding))
                }
            case .failure(.underlying(AFError.responseValidationFailed, _)):
                self.log.error("API rejection: \(endpoint.path)")
                return then(.failure(.status))
            case let .failure(.underlying(error, response)):
                let problem = self.parse(error: error, response: response)
                return then(.failure(problem))
            case .failure(let error):
                let message = error.errorDescription ?? L.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func userGetByToken(
        stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
        then: @escaping NetworkCompletion<UserJSON>
    ) {
        guard data.isLoggedIn else {
            return then(.failure(.parameter))
        }

        let auth = AccessTokenPlugin { self.data.token }
        let provider = MTPProvider(stubClosure: stub, plugins: [auth])
        let endpoint = MTP.userGetByToken
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        //swiftlint:disable:next closure_body_length
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
                    return then(.failure(.decoding))
                }
            case let .failure(.underlying(error, response)):
                let problem = self.parse(error: error, response: response)
                return then(.failure(problem))
            case .failure(let error):
                guard error.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                let message = error.errorDescription ?? L.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func userLogin(email: String,
                   password: String,
                   then: @escaping NetworkCompletion<UserJSON>) {
        guard !email.isEmpty && !password.isEmpty else {
            return then(.failure(.parameter))
        }

        let provider = MTPProvider()
        let endpoint = MTP.userLogin(email: email, password: password)

        func parse(success response: Response) {
            do {
                let user = try response.map(UserJSON.self,
                                            using: JSONDecoder.mtp)
                guard let token = user.token else { throw NetworkError.token }
                data.token = token
                data.user = user
                return then(.success(user))
            } catch {
                do {
                    let reply = try response.map(OperationReply.self,
                                                 using: JSONDecoder.mtp)
                    return then(.failure(.message(reply.message)))
                } catch {
                    log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                    return then(.failure(.decoding))
                }
            }
        }

        provider.request(endpoint) { result in
            switch result {
            case .success(let response):
                return parse(success: response)
            case let .failure(.underlying(error, response)):
                let problem = self.parse(error: error, response: response)
                return then(.failure(problem))
            case .failure(let error):
                let message = error.errorDescription ?? L.unknown()
                self.log.error("failure: \(endpoint.path) \(message) \(error)")
                return then(.failure(.network(message)))
            }
        }
    }

    func userRegister(payload: RegistrationPayload,
                      then: @escaping NetworkCompletion<UserJSON>) {
        guard payload.isValid else {
            return then(.failure(.parameter))
        }

        let provider = MTPProvider()
        let endpoint = MTP.userRegister(payload: payload)

        func parse(result: Response) {
            do {
                let user = try result.map(UserJSON.self,
                                          using: JSONDecoder.mtp)
                guard let token = user.token else { throw NetworkError.token }
                data.token = token
                data.user = user
                userGetByToken { _ in
                    then(.success(user))
                }
            } catch {
                log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                return then(.failure(.decoding))
            }
        }

        provider.request(endpoint) { response in
            switch response {
            case .success(let result):
                return parse(result: result)
            case let .failure(.underlying(error, response)):
                let problem = self.parse(error: error, response: response)
                return then(.failure(problem))
            case .failure(let error):
                let message = error.errorDescription ?? L.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func userUpdate(payload: UserUpdatePayload,
                    then: @escaping NetworkCompletion<UserJSON>) {
        let auth = AccessTokenPlugin { self.data.token }
        let provider = MTPProvider(plugins: [auth])
        let endpoint = MTP.userPut(payload: payload)

        //swiftlint:disable:next closure_body_length
        provider.request(endpoint) { response in
            switch response {
            case .success(let result):
                do {
                    let reply = try result.map(UserUpdateReply.self,
                                               using: JSONDecoder.mtp)
                    if reply.isSuccess {
                        self.data.user = reply.user
                        return then(.success(reply.user))
                    } else {
                        return then(.failure(.message(reply.message)))
                    }
                } catch {
                    self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                    return then(.failure(.decoding))
                }
            case let .failure(.underlying(error, response)):
                let problem = self.parse(error: error, response: response)
                return then(.failure(problem))
            case .failure(let error):
                guard error.modified(from: endpoint) else {
                    return then(.failure(.notModified))
                }
                let message = error.errorDescription ?? L.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }

    func userVerify(id: Int,
                    then: @escaping NetworkCompletion<String>) {
        let auth = AccessTokenPlugin { self.data.token }
        let provider = MTPProvider(plugins: [auth])
        let endpoint = MTP.userVerify(id: id)

        //swiftlint:disable:next closure_body_length
        provider.request(endpoint) { response in
            switch response {
            case .success(let result):
                do {
                    let reply = try result.map(OperationReply.self,
                                               using: JSONDecoder.mtp)
                    if reply.isSuccess {
                        return then(.success(reply.message))
                    } else {
                        return then(.failure(.message(reply.message)))
                    }
                } catch {
                    self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(result.toString)")
                    return then(.failure(.decoding))
                }
            case .failure(.underlying(AFError.responseValidationFailed, _)):
                self.log.error("API rejection: \(endpoint.path)")
                return then(.failure(.status))
            case let .failure(.underlying(error, response)):
                let problem = self.parse(error: error, response: response)
                return then(.failure(problem))
            case .failure(let error):
                let message = error.errorDescription ?? L.unknown()
                self.log.error("failure: \(endpoint.path) \(message)")
                return then(.failure(.network(message)))
            }
        }
    }
}

// MARK: - Support

private extension MoyaError {

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
        guard let response = response else {
            // expected in a stubbed response
            return true
        }

        endpoint.markReceived()

        guard response.statusCode != 304 else {
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

private extension MTPNetworkController {

    func parse(error: Error?,
               response: Response?) -> NetworkError {
        if let aferror = error as? AFError?,
           case let .responseValidationFailed(.unacceptableStatusCode(code))? = aferror {
            switch code {
            case 304:
                return .notModified
            case 409: // Conflict - found in signup
                break
            default:
                return .status
            }
        }

        if let nserror = error as NSError?,
            nserror.domain == NSURLErrorDomain,
            // swiftlint:disable:next number_separator
            nserror.code == -1009 {
            return .deviceOffline
        }

        guard let response = response else {
            return .serverOffline
        }

        do {
            let reply = try response.map(OperationReply.self,
                                         using: JSONDecoder.mtp)
            return .message(reply.message)
        } catch {
            self.log.error("decoding error response: \(error)\n-\n\(response.toString)")
            return .decoding
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

        let throttle = TimeInterval(10)
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
