// @copyright Trollwerks Inc.

// swiftlint:disable file_length

import Alamofire
import Moya
import enum Result.Result

private typealias SuccessHandler = (Moya.Response) -> Void
private typealias FailureHandler = (MoyaError) -> Void

/// MTP.travel API endpoints
enum MTP: Hashable {

    /// Map arguments
    enum Map: String {

        /// uncountries
        case uncountries
        /// world
        case world
    }

    /// Size argumens
    enum Size: String {

        /// Unspecified
        case any = ""
        /// Large
        case large
        /// Thumbnail
        case thumb
    }

    /// Published status
    enum Status: String {

        /// Draft
        case draft = "D"
        /// Published
        case published = "A"
    }

    /// beach
    case beach
    /// brands
    case brands
    /// checkIn(list: Checklist, id: Int)
    case checkIn(list: Checklist, id: Int)
    /// checklists
    case checklists
    /// checkOut(list: Checklist, id: Int)
    case checkOut(list: Checklist, id: Int)
    /// countriesSearch(query: String?)
    case countriesSearch(query: String?)
    /// contact(payload: ContactPayload)
    case contact(payload: ContactPayload)
    /// divesite
    case divesite
    /// faq
    case faq
    /// geoJson(map: Map)
    case geoJson(map: Map)
    /// golfcourse
    case golfcourse
    /// hotels
    case hotels
    /// location
    case location
    /// locationPhotos(location: Int)
    case locationPhotos(location: Int)
    /// locationPosts(location: Int)
    case locationPosts(location: Int)
    /// passwordReset(email: String)
    case passwordReset(email: String)
    /// picture(uuid: String, size: Size)
    case picture(uuid: String, size: Size)
    /// photoDelete(file: Int)
    case photoDelete(file: Int)
    /// photoPut(payload: PhotoUpdatePayload)
    case photoPut(payload: PhotoUpdatePayload)
    /// photos(user: Int?, page: Int)
    case photos(user: Int?, page: Int)
    /// postDelete(post: Int)
    case postDelete(post: Int)
    /// postPut(payload: PostUpdatePayload)
    case postPut(payload: PostUpdatePayload)
    /// postPublish(payload: PostPayload)
    case postPublish(payload: PostPayload)
    /// rankings(query: RankingsQuery)
    case rankings(query: RankingsQuery)
    /// restaurant
    case restaurant
    /// scorecard(list: Checklist, user: Int)
    case scorecard(list: Checklist, user: Int)
    /// search(query: String?)
    case search(query: String?)
    /// settings
    case settings
    /// unCountry
    case unCountry
    /// upload(photo: Data, caption: String?, location: Int?)
    case upload(photo: Data, caption: String?, location: Int?)
    /// userDelete(id: Int)
    case userDelete(id: Int)
    /// userFix(id: Int)
    case userFix(id: Int)
    /// userGet(id: Int)
    case userGet(id: Int)
    /// userGetByToken
    case userGetByToken
    /// userPosts(id: Int)
    case userPosts(id: Int)
    /// userPost(token: String)
    case userPost(id: Int, token: String)
    /// userPut(payload: UserUpdatePayload)
    case userPut(payload: UserUpdatePayload)
    /// userLogin(email: String, password: String)
    case userLogin(email: String, password: String)
    /// userRegister(payload: RegistrationPayload)
    case userRegister(payload: RegistrationPayload)
    /// userVerify(id: Int)
    case userVerify(id: Int)
    /// whs
    case whs

    // GET minimap: /minimaps/{user_id}.png
    // force map reload: POST /api/users/{user_id}/minimap

    /// Reset all throttling
    static func unthrottle() {
        active = []
        received = [:]
    }
}

extension MTP: TargetType {

    /// The target's base `URL`.
    var baseURL: URL { return URL(string: "https://mtp.travel/api/")! }
    // swiftlint:disable:previous force_unwrapping

    private var preventCache: Bool { return false }

    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .beach:
            return "beach"
        case .brands:
            return "checklists/attributes/hotels"
        case .checkIn(let list, _),
             .checkOut(let list, _):
            return "me/checklists/\(list.key)"
        case .checklists:
            return "me/checklists"
        case .contact:
            return "send-message/contact-form"
        case .countriesSearch:
            return "countries/search"
        case .divesite:
            return "divesite"
        case .faq:
            return "article/faq"
        case .geoJson(let map):
            return "geojson-files/\(map.rawValue)-map"
            // curl https://mtp.travel/api/geojson-files/{world-map} -o "#1.geojson"
        case .golfcourse:
            return "golfcourse"
        case .hotels:
            return "hotels"
        case .location:
            return "location"
        case .locationPhotos(let location):
            return "locations/\(location)/photos"
        case .locationPosts(let location):
            return "locations/\(location)/posts"
        case .photoDelete:
            return "me/photos"
        case .photoPut(let payload):
            return "file/\(payload.id)"
        case .photos(let user?, _):
            return "users/\(user)/photos"
        case .photos:
            return "users/me/photos"
        case .picture:
            return "files/preview"
        case .postDelete(let post):
            return "location-posts/\(post)"
        case .postPut(let payload):
            return "location-posts/\(payload.id)"
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
        case .userDelete(let id),
             .userGet(let id):
            return "user/\(id)"
        case .userFix(let id):
            return "v2/users/\(id)/fix/scores"
        case .userGetByToken:
            return "user/getByToken"
        case .userPost(let id, _):
            return "user/\(id)/token"
        case .userPosts(let id):
            return "users/\(id)/location-posts"
        case .userLogin:
            return "user/login"
        case .userPut(let payload):
            return "user/\(payload.id)"
        case .userRegister:
            return "user"
        case .userVerify(let id):
            return "users/\(id)/send-verification-email"
        case .whs:
            return "whs"
        }
    }

    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .checkOut,
             .photoDelete,
             .postDelete,
             .userDelete:
            return .delete
        case .beach,
             .brands,
             .checklists,
             .countriesSearch,
             .divesite,
             .faq,
             .geoJson,
             .golfcourse,
             .hotels,
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
             .userFix,
             .userGet,
             .userGetByToken,
             .userPosts,
             .userVerify,
             .whs:
            return .get
        case .checkIn,
             .contact,
             .passwordReset,
             .postPublish,
             .upload,
             .userLogin,
             .userPost,
             .userRegister:
            return .post
        case .photoPut,
             .postPut,
             .userPut:
            return .put
        }
    }

    /// The type of HTTP task to be performed.
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
        case .photoDelete(let file):
            return .requestParameters(parameters: ["ids": file],
                                      encoding: URLEncoding.default)
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
        case .userPost(_, let token):
            return .requestParameters(parameters: ["type": "apn_device_token",
                                                   "value": token],
                                      encoding: URLEncoding(destination: .queryString))
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
        case .contact(let payload):
            return .requestJSONEncodable(payload)
        case .photoPut(let payload):
            return .requestJSONEncodable(payload)
        case .postPublish(let payload):
            return .requestJSONEncodable(payload)
        case .postPut(let payload):
            return .requestJSONEncodable(payload)
        case .userPut(let payload):
            return .requestJSONEncodable(payload)
        case .userRegister(let payload):
            return .requestJSONEncodable(payload)
        case .userVerify:
            return .requestParameters(parameters: ["preventCache": "1"],
                                      encoding: URLEncoding.default)
        case .beach,
             .brands,
             .checklists,
             .countriesSearch,
             .divesite,
             .faq,
             .geoJson,
             .golfcourse,
             .hotels, // add ?with=location for location info
             .location,
             .locationPhotos, // &page=1&orderBy=-created_at&limit=6
             .postDelete,
             .restaurant,
             .scorecard,
             .search,
             .settings,
             .unCountry,
             .userDelete,
             .userFix,
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

    /// The type of validation to perform on the request. Default is `.none`.
    var validationType: ValidationType {
        switch self {
        case .userLogin:
            return .none // expect 401 with wrong password message
        default:
            return .successCodes
        }
    }

    /// The headers to be used in the request.
    var headers: [String: String]? {
        // swiftlint:disable:previous discouraged_optional_collection
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

    /// Provides stub data for use in testing.
    var sampleData: Data {
        let file: String
        switch self {
        case .checkIn,
             .checkOut:
            file = "checkin-whss-1187"
        case .checklists,
             .userGetByToken:
            file = "\(self)"
        //case let .photos(user?, page):
            //file = "photos-\(user)-\(page)"
        case .locationPhotos:
            //file = "locationPhotos-\(location)"
            file = "locationPhotos-554"
        case .locationPosts:
            //file = "locationPosts-\(location)"
            file = "locationPosts-554"
        case .passwordReset(let email):
            if email.contains("error") {
                file = "error999"
            } else {
                file = "passwordReset"
            }
        case .photos(_, let page):
            file = "photos-7853-\(page)"
        case .postPublish:
            file = "postPublish"
        case .rankings:
            file = "rankings"
        case let .scorecard(list, _):
            //file = "scorecard-\(list.key)-\(user)"
            file = "scorecard-\(list.key)-7853"
        case .search:
            file = "search-Fred"
        case .upload:
            file = "uploadPhoto"
        case .userDelete:
            file = "userDelete"
        case .userGet:
            //file = "userGet-\(id)"
            file = "userGet-1"
        case .userLogin(_, let password):
            switch password {
            case "fail":
                file = "userLogin-fail"
            default:
                file = "userLogin-7853"
            }
        case .userPost:
            file = "userPostToken"
        case .userPut:
            file = "userUpdate"
        case .userPosts:
            //file = "userPosts-\(id)"
            file = "userPosts-7853"
        case .userRegister:
            file = "userRegister"
        case .userVerify:
            file = "userVerify"
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

    /// Convenience URL accessor
    var requestUrl: URL? {
        let request = try? MoyaProvider.defaultEndpointMapping(for: self).urlRequest()
        return request?.url
    }

    /// Convenience etag accessor
    var etag: String {
        return data.etags[path] ?? ""
    }
}

extension MTP: AccessTokenAuthorizable {

    /// Represents the authorization header to use for requests.
    var authorizationType: AuthorizationType {
        switch self {
        case .checkIn,
             .checklists,
             .checkOut,
             .contact,
             .photoDelete,
             .photoPut,
             .photos,
             .postDelete,
             .postPublish,
             .postPut,
             .rankings,
             .upload,
             .userDelete,
             .userGetByToken,
             .userPost,
             .userPut,
             .userVerify:
            return .bearer
        case .beach,
             .brands,
             .countriesSearch,
             .divesite,
             .faq,
             .geoJson,
             .golfcourse,
             .hotels,
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
             .userFix,
             .userGet,
             .userLogin,
             .userPosts,
             .userRegister,
             .whs:
            return .none
        }
    }
}

/// Convenience provider shorthand
typealias MTPProvider = MoyaProvider<MTP>

/// Calls the MTP API via Moya
class MTPNetworkController: ServiceProvider {
    // swiftlint:disable:previous type_body_length

    /// Set places visit status
    /// - Parameters:
    ///   - items: Places
    ///   - visited: Whether visited
    ///   - stub: Stub behaviour
    ///   - then: Completion
    func set(items: [Checklist.Item],
             visited: Bool,
             stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
             then: @escaping NetworkCompletion<Bool>) {
        guard let item = items.first else {
            then(.success(true))
            return
        }

        if visited {
            checkIn(list: item.list, id: item.id, stub: stub) { result in
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
            checkOut(list: item.list, id: item.id, stub: stub) { result in
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

    /// Send contact form
    /// - Parameters:
    ///   - payload: Post payload
    ///   - stub: Stub behaviour
    ///   - then: Completion
    func contact(payload: ContactPayload,
                 stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
                 then: @escaping NetworkCompletion<String>) {
        guard data.isLoggedIn else {
            return then(.failure(.parameter))
        }

        let auth = AccessTokenPlugin { self.data.token }
        let provider = MTPProvider(stubClosure: stub, plugins: [auth])
        let endpoint = MTP.contact(payload: payload)

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                let reply = try response.map(OperationMessageReply.self,
                                             using: JSONDecoder.mtp)
                if reply.isSuccess {
                    self.report(success: endpoint)
                    return then(.success(reply.message))
                } else {
                    problem = .message(reply.message)
                }
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Load beaches
    func loadBeaches(then: @escaping NetworkCompletion<[PlaceJSON]> = { _ in }) {
        let provider = MTPProvider()
        let endpoint = MTP.beach
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                guard response.modified(from: endpoint) else {
                    throw NetworkError.notModified
                }
                let beaches = try response.map([PlaceJSON].self,
                                               using: JSONDecoder.mtp)
                self.data.set(beaches: beaches)
                self.report(success: endpoint)
                return then(.success(beaches))
            } catch let error as NetworkError {
                problem = error
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            endpoint.markResponded()
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Load brands
    func loadBrands(then: @escaping NetworkCompletion<[BrandJSON]> = { _ in }) {
        let provider = MTPProvider()
        let endpoint = MTP.brands
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                guard response.modified(from: endpoint) else {
                    throw NetworkError.notModified
                }
                let brandsData = try response.map(BrandsJSON.self,
                                                  using: JSONDecoder.mtp)
                let brands = brandsData.data.brands
                self.data.set(brands: brands)
                self.report(success: endpoint)
                return then(.success(brands))
            } catch let error as NetworkError {
                problem = error
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            endpoint.markResponded()
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Load checklists
    /// - Parameters:
    ///   - stub: Stub behaviour
    ///   - then: Completion
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

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                guard response.modified(from: endpoint) else {
                    throw NetworkError.notModified
                }
                let visited = try response.map(Checked.self,
                                               using: JSONDecoder.mtp)
                let trigger = self.data.visited == nil
                self.data.visited = visited
                if trigger {
                    self.loc.calculateDistances()
                }
                self.report(success: endpoint)
                return then(.success(visited))
            } catch let error as NetworkError {
                problem = error
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            endpoint.markResponded()
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Load dive sites
    func loadDiveSites(then: @escaping NetworkCompletion<[PlaceJSON]> = { _ in }) {
        let provider = MTPProvider()
        let endpoint = MTP.divesite
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                guard response.modified(from: endpoint) else {
                    throw NetworkError.notModified
                }
                let divesites = try response.map([PlaceJSON].self,
                                                 using: JSONDecoder.mtp)
                self.data.set(divesites: divesites)
                self.report(success: endpoint)
                return then(.success(divesites))
            } catch let error as NetworkError {
                problem = error
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            endpoint.markResponded()
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Load golf courses
    func loadGolfCourses(then: @escaping NetworkCompletion<[PlaceJSON]> = { _ in }) {
        let provider = MTPProvider()
        let endpoint = MTP.golfcourse
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                guard response.modified(from: endpoint) else {
                    throw NetworkError.notModified
                }
                let golfcourses = try response.map([PlaceJSON].self,
                                                   using: JSONDecoder.mtp)
                self.data.set(golfcourses: golfcourses)
                self.report(success: endpoint)
                return then(.success(golfcourses))
            } catch let error as NetworkError {
                problem = error
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            endpoint.markResponded()
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Load hotels
    func loadHotels(then: @escaping NetworkCompletion<[HotelJSON]> = { _ in }) {
        let provider = MTPProvider()
        let endpoint = MTP.hotels
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                guard response.modified(from: endpoint) else {
                    throw NetworkError.notModified
                }
                let hotels = try response.map([HotelJSON].self,
                                              using: JSONDecoder.mtp)
                self.data.set(hotels: hotels)
                self.report(success: endpoint)
                return then(.success(hotels))
            } catch let error as NetworkError {
                problem = error
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            endpoint.markResponded()
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Load locations
    func loadLocations(then: @escaping NetworkCompletion<[LocationJSON]> = { _ in }) {
        let provider = MTPProvider()
        let endpoint = MTP.location
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                guard response.modified(from: endpoint) else {
                    throw NetworkError.notModified
                }
                let locations = try response.map([LocationJSON].self,
                                                 using: JSONDecoder.mtp)
                self.data.set(locations: locations)
                self.report(success: endpoint)
                return then(.success(locations))
            } catch let error as NetworkError {
                problem = error
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            endpoint.markResponded()
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Load location photos
    /// - Parameters:
    ///   - id: Location ID
    ///   - reload: Force reload
    ///   - stub: Stub behaviour
    ///   - then: Completion
    func loadPhotos(location id: Int,
                    reload: Bool,
                    stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
                    then: @escaping NetworkCompletion<PhotosInfoJSON> = { _ in }) {
        let provider = MTPProvider(stubClosure: stub)
        let endpoint = MTP.locationPhotos(location: id)
        guard reload || !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                guard response.modified(from: endpoint) else {
                    throw NetworkError.notModified
                }
                let photos = try response.map(PhotosInfoJSON.self,
                                              using: JSONDecoder.mtp)
                self.data.set(location: id, photos: photos)
                self.report(success: endpoint)
                return then(.success(photos))
            } catch let error as NetworkError {
                problem = error
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            endpoint.markResponded()
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Load logged in user photos
    /// - Parameters:
    ///   - page: Index
    ///   - reload: Force reload
    ///   - stub: Stub behaviour
    ///   - then: Completion
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

    /// Load user photos
    /// - Parameters:
    ///   - id: User ID
    ///   - page: Index
    ///   - reload: Force reload
    ///   - stub: Stub behaviour
    ///   - then: Completion
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

    /// Load location posts
    /// - Parameters:
    ///   - id: Location ID
    ///   - reload: Force reload
    ///   - stub: Stub behaviour
    ///   - then: Completion
    func loadPosts(location id: Int,
                   reload: Bool,
                   stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
                   then: @escaping NetworkCompletion<PostsJSON> = { _ in }) {
        let provider = MTPProvider(stubClosure: stub)
        let endpoint = MTP.locationPosts(location: id)
        guard reload || !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                guard response.modified(from: endpoint) else {
                    throw NetworkError.notModified
                }
                let posts = try response.map(PostsJSON.self,
                                             using: JSONDecoder.mtp)
                self.data.set(location: id, posts: posts.data)
                self.report(success: endpoint)
                return then(.success(posts))
            } catch let error as NetworkError {
                problem = error
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            endpoint.markResponded()
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Load user posts
    /// - Parameters:
    ///   - id: User ID
    ///   - reload: Force reload
    ///   - stub: Stub behaviour
    ///   - then: Completion
    func loadPosts(user id: Int,
                   reload: Bool,
                   stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
                   then: @escaping NetworkCompletion<PostsJSON> = { _ in }) {
        guard data.isLoggedIn else {
            return then(.failure(.parameter))
        }

        let auth = AccessTokenPlugin { self.data.token }
        let provider = MTPProvider(stubClosure: stub, plugins: [auth])
        let endpoint = MTP.userPosts(id: id)
        guard reload || !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                guard response.modified(from: endpoint) else {
                    throw NetworkError.notModified
                }
                let posts = try response.map(PostsJSON.self,
                                             using: JSONDecoder.mtp)
                self.data.set(posts: posts.data)
                self.report(success: endpoint)
                return then(.success(posts))
            } catch let error as NetworkError {
                problem = error
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            endpoint.markResponded()
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Load rankings
    /// - Parameters:
    ///   - query: Filter
    ///   - stub: Stub behaviour
    ///   - then: Completion
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

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                guard response.modified(from: endpoint) else {
                    throw NetworkError.notModified
                }
                let info = try response.map(RankingsPageInfoJSON.self,
                                            using: JSONDecoder.mtp)
                self.data.set(rankings: query, info: info)
                self.report(success: endpoint)
                return then(.success(info))
            } catch let error as NetworkError {
                problem = error
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Load restaurants
    /// - Parameters:
    ///   - then: Completion
    func loadRestaurants(then: @escaping NetworkCompletion<[RestaurantJSON]> = { _ in }) {
        let provider = MTPProvider()
        let endpoint = MTP.restaurant
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                guard response.modified(from: endpoint) else {
                    throw NetworkError.notModified
                }
                let restaurants = try response.map([RestaurantJSON].self,
                                                   using: JSONDecoder.mtp)
                self.data.set(restaurants: restaurants)
                self.report(success: endpoint)
                return then(.success(restaurants))
            } catch let error as NetworkError {
                problem = error
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            endpoint.markResponded()
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Load scorecard
    /// - Parameters:
    ///   - list: Checklist
    ///   - id: User ID
    ///   - stub: Stub behaviour
    ///   - then: Completion
    func loadScorecard(list: Checklist,
                       user id: Int,
                       stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
                       then: @escaping NetworkCompletion<ScorecardJSON> = { _ in }) {
        let provider = MTPProvider(stubClosure: stub)
        let endpoint = MTP.scorecard(list: list, user: id)

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                guard response.modified(from: endpoint) else {
                    throw NetworkError.notModified
                }
                let scorecard = try response.map(ScorecardWrapperJSON.self,
                                                 using: JSONDecoder.mtp)
                self.data.set(scorecard: scorecard)
                self.report(success: endpoint)
                return then(.success(scorecard.data))
            } catch let error as NetworkError {
                problem = error
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Load settings
    func loadSettings(then: @escaping NetworkCompletion<SettingsJSON> = { _ in }) {
        let provider = MTPProvider()
        let endpoint = MTP.settings
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                guard response.modified(from: endpoint) else {
                    throw NetworkError.notModified
                }
                let settings = try response.map(SettingsJSON.self,
                                                using: JSONDecoder.mtp)
                self.data.set(milestones: settings)
                self.report(success: endpoint)
                return then(.success(settings))
            } catch let error as NetworkError {
                problem = error
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            endpoint.markResponded()
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Load UN countries
    /// - Parameters:
    ///   - then: Completion
    func loadUNCountries(then: @escaping NetworkCompletion<[LocationJSON]> = { _ in }) {
        let provider = MTPProvider()
        let endpoint = MTP.unCountry
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                guard response.modified(from: endpoint) else {
                    throw NetworkError.notModified
                }
                let uncountries = try response.map([LocationJSON].self,
                                                   using: JSONDecoder.mtp)
                self.data.set(uncountries: uncountries)
                self.report(success: endpoint)
                return then(.success(uncountries))
            } catch let error as NetworkError {
                problem = error
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            endpoint.markResponded()
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Load user
    /// - Parameters:
    ///   - id: User ID
    ///   - stub: Stub behaviour
    ///   - then: Completion
    func loadUser(id: Int,
                  stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
                  then: @escaping NetworkCompletion<UserJSON> = { _ in }) {
        let provider = MTPProvider(stubClosure: stub)
        let endpoint = MTP.userGet(id: id)
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                guard response.modified(from: endpoint) else {
                    throw NetworkError.notModified
                }
                let user = try response.map(UserJSON.self,
                                            using: JSONDecoder.mtp)
                self.data.set(user: user)
                self.report(success: endpoint)
                return then(.success(user))
            } catch let error as NetworkError {
                problem = error
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            endpoint.markResponded()
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Load WHS
    /// - Parameters:
    ///   - then: Completion
    func loadWHS(then: @escaping NetworkCompletion<[WHSJSON]> = { _ in }) {
        let provider = MTPProvider()
        let endpoint = MTP.whs
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                guard response.modified(from: endpoint) else {
                    throw NetworkError.notModified
                }
                let whss = try response.map([WHSJSON].self,
                                            using: JSONDecoder.mtp)
                self.data.set(whss: whss)
                self.report(success: endpoint)
                return then(.success(whss))
            } catch let error as NetworkError {
                problem = error
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            endpoint.markResponded()
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Load world map
    func loadWorldMap(then: @escaping NetworkCompletion<GeoJSON> = { _ in }) {
        let provider = MTPProvider()
        let endpoint = MTP.geoJson(map: .world)
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                guard response.modified(from: endpoint) else {
                    throw NetworkError.notModified
                }
                let map = try response.map(GeoJSON.self,
                                           using: JSONDecoder.mtp)
                self.data.set(world: map)
                self.report(success: endpoint)
                return then(.success(map))
            } catch let error as NetworkError {
                problem = error
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            endpoint.markResponded()
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Update photo
    /// - Parameters:
    ///   - payload: PhotoUpdatePayload
    ///   - stub: Stub behaviour
    ///   - then: Completion
    func photoUpdate(payload: PhotoUpdatePayload,
                     stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
                     then: @escaping NetworkCompletion<Bool>) {
        let auth = AccessTokenPlugin { self.data.token }
        let provider = MTPProvider(stubClosure: stub, plugins: [auth])
        let endpoint = MTP.photoPut(payload: payload)

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                _ = try response.map(PhotoUpdateReply.self,
                                     using: JSONDecoder.mtp)
                self.report(success: endpoint)
                return then(.success(true))
            } catch let error as NetworkError {
                problem = error
            } catch {
                do {
                    let reply = try response.map(OperationReply.self,
                                                 using: JSONDecoder.mtp)
                    problem = .message(reply.message)
                } catch {
                    self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                    problem = .decoding(error.localizedDescription)
                }
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Delete photo
    /// - Parameters:
    ///   - photo: Int
    ///   - stub: Stub behaviour
    ///   - then: Completion
    func delete(photo: Int,
                stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
                then: @escaping NetworkCompletion<Bool>) {
        let auth = AccessTokenPlugin { self.data.token }
        let provider = MTPProvider(stubClosure: stub, plugins: [auth])
        let endpoint = MTP.photoDelete(file: photo)

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                let reply = try response.map(QuietOperationReply.self,
                                             using: JSONDecoder.mtp)
                if reply.isSuccess {
                    self.report(success: endpoint)
                    return then(.success(reply.isSuccess))
                } else {
                    problem = .status(reply.code)
                }
            } catch let error as NetworkError {
                problem = error
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Publish post
    /// - Parameters:
    ///   - payload: Post payload
    ///   - stub: Stub behaviour
    ///   - then: Completion
    func postPublish(payload: PostPayload,
                     stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
                     then: @escaping NetworkCompletion<PostReply>) {
        guard data.isLoggedIn else {
            return then(.failure(.parameter))
        }

        let auth = AccessTokenPlugin { self.data.token }
        let provider = MTPProvider(stubClosure: stub, plugins: [auth])
        let endpoint = MTP.postPublish(payload: payload)

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                let reply = try response.map(PostReply.self,
                                             using: JSONDecoder.mtp)
                self.data.set(post: reply)
                self.report(success: endpoint)
                return then(.success(reply))
            } catch {
                do {
                    let reply = try response.map(OperationReply.self,
                                                 using: JSONDecoder.mtp)
                    problem = .message(reply.message)
                } catch {
                    self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                    problem = .decoding(error.localizedDescription)
                }
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Update post
    /// - Parameters:
    ///   - payload: PostUpdatePayload
    ///   - stub: Stub behaviour
    ///   - then: Completion
    func postUpdate(payload: PostUpdatePayload,
                    stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
                    then: @escaping NetworkCompletion<Bool>) {
        let auth = AccessTokenPlugin { self.data.token }
        let provider = MTPProvider(stubClosure: stub, plugins: [auth])
        let endpoint = MTP.postPut(payload: payload)

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                // updated response in /data
                let reply = try response.map(CodelessOperationReply.self,
                                             using: JSONDecoder.mtp)
                if reply.isSuccess {
                    self.report(success: endpoint)
                    return then(.success(true))
                } else {
                    problem = .message(reply.message)
                }
            } catch let error as NetworkError {
                problem = error
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Delete post
    /// - Parameters:
    ///   - post: Int
    ///   - stub: Stub behaviour
    ///   - then: Completion
    func delete(post: Int,
                stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
                then: @escaping NetworkCompletion<Bool>) {
        let auth = AccessTokenPlugin { self.data.token }
        let provider = MTPProvider(stubClosure: stub, plugins: [auth])
        let endpoint = MTP.postDelete(post: post)

        let success: SuccessHandler = { response in
            // apparently this returns a simple "1" or "0"
            self.report(success: endpoint)
            return then(.success(true))
        }

        provider.request(endpoint) { result in
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Search countries
    /// - Parameters:
    ///   - query: Query
    ///   - then: Completion
    func searchCountries(query: String = "",
                         then: @escaping NetworkCompletion<[CountryJSON]>) {
        let provider = MTPProvider()
        let queryParam = query.isEmpty ? nil : query
        let endpoint = MTP.countriesSearch(query: queryParam)

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                let countries = try response.map([CountryJSON].self,
                                                 using: JSONDecoder.mtp)
                self.data.set(countries: countries)
                self.report(success: endpoint)
                return then(.success(countries))
            } catch {
                do {
                    let reply = try response.map(OperationReply.self,
                                                 using: JSONDecoder.mtp)
                    problem = .message(reply.message)
                } catch {
                    self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                    problem = .decoding(error.localizedDescription)
                }
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Search
    /// - Parameters:
    ///   - query: Query
    ///   - stub: Stub behaviour
    ///   - then: Completion
    func search(query: String,
                stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
                then: @escaping NetworkCompletion<SearchResultJSON>) {
        let provider = MTPProvider(stubClosure: stub)
        let queryParam = query.isEmpty ? nil : query
        let endpoint = MTP.search(query: queryParam)

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                guard response.modified(from: endpoint) else {
                    throw NetworkError.notModified
                }
                let results = try response.map(SearchResultJSON.self,
                                               using: JSONDecoder.mtp)
                self.report(success: endpoint)
                return then(.success(results))
            } catch let error as NetworkError {
                problem = error
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Upload photo
    /// - Parameters:
    ///   - photo: Data
    ///   - caption: String
    ///   - id: Location ID if any
    ///   - stub: Stub behaviour
    ///   - then: Completion
    func upload(photo: Data,
                caption: String?,
                location id: Int?,
                stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
                then: @escaping NetworkCompletion<PhotoReply>) {
        guard data.isLoggedIn else {
            return then(.failure(.parameter))
        }

        let auth = AccessTokenPlugin { self.data.token }
        let provider = MTPProvider(stubClosure: stub, plugins: [auth])
        let endpoint = MTP.upload(photo: photo,
                                  caption: caption,
                                  location: id)

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                let replies = try response.map([PhotoReply].self,
                                               using: JSONDecoder.mtp)
                let reply = try unwrap(replies.first)
                self.data.set(photo: reply)
                self.report(success: endpoint)
                return then(.success(reply))
            } catch {
                do {
                    let reply = try response.map(OperationReply.self,
                                                 using: JSONDecoder.mtp)
                    problem = .message(reply.message)
                } catch {
                    self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                    problem = .decoding(error.localizedDescription)
                }
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
       }

        provider.request(endpoint) { result in
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Delete user account
    /// - Parameters:
    ///   - stub: Stub behaviour
    ///   - then: Completion
    func userDeleteAccount(
        stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
        then: @escaping NetworkCompletion<String>
    ) {
        guard let userId = data.user?.id else {
            return then(.failure(.parameter))
        }

        let auth = AccessTokenPlugin { self.data.token }
        let provider = MTPProvider(stubClosure: stub, plugins: [auth])
        let endpoint = MTP.userDelete(id: userId)

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                guard response.modified(from: endpoint) else {
                    throw NetworkError.notModified
                }
                let reply = try response.map(OperationReply.self,
                                             using: JSONDecoder.mtp)
                if reply.isSuccess {
                    self.report(success: endpoint)
                    return then(.success(reply.message))
                } else {
                    problem = .message(reply.message)
                }
            } catch let error as NetworkError {
                problem = error
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Load user, triggering visit rebuild to sort problems like 2020 country changes
    /// - Parameters:
    ///   - id: User ID
    ///   - stub: Stub behaviour
    ///   - then: Completion
    func userFix(id: Int,
                 stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
                 then: @escaping NetworkCompletion<UserJSON> = { _ in }) {
        let provider = MTPProvider(stubClosure: stub)
        let endpoint = MTP.userGet(id: id)
        guard !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                guard response.modified(from: endpoint) else {
                    throw NetworkError.notModified
                }
                let user = try response.map(UserJSON.self,
                                            using: JSONDecoder.mtp)
                self.data.fix(user: user)
                self.report(success: endpoint)
                return then(.success(user))
            } catch let error as NetworkError {
                problem = error
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            endpoint.markResponded()
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Send reset password link
    /// - Parameters:
    ///   - email: Email
    ///   - stub: Stub behaviour
    ///   - then: Completion
    func userForgotPassword(
        email: String,
        stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
        then: @escaping NetworkCompletion<String>
    ) {
        guard !email.isEmpty else {
            return then(.failure(.parameter))
        }

        let provider = MTPProvider(stubClosure: stub)
        let endpoint = MTP.passwordReset(email: email)

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                guard response.modified(from: endpoint) else {
                    throw NetworkError.notModified
                }
                let reply = try response.map(OperationMessageReply.self,
                                             using: JSONDecoder.mtp)
                if reply.isSuccess {
                    self.report(success: endpoint)
                    return then(.success(reply.message))
                } else {
                    problem = .message(reply.message)
                }
            } catch let error as NetworkError {
                problem = error
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Get logged in user info
    /// - Parameters:
    ///   - reload: Force reload
    ///   - stub: Stub behaviour
    ///   - then: Completion
    func userGetByToken(
        reload: Bool,
        stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
        then: @escaping NetworkCompletion<UserJSON> = { _ in }
    ) {
        guard data.isLoggedIn else {
            return then(.failure(.parameter))
        }

        let auth = AccessTokenPlugin { self.data.token }
        let provider = MTPProvider(stubClosure: stub, plugins: [auth])
        let endpoint = MTP.userGetByToken
        guard reload || !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                guard response.modified(from: endpoint) else {
                    throw NetworkError.notModified
                }
                let user = try response.map(UserJSON.self,
                                            using: JSONDecoder.mtp)
                self.data.user = user
                self.report(success: endpoint)
                return then(.success(user))
            } catch let error as NetworkError {
                problem = error
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            endpoint.markResponded()
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Login user
    /// - Parameters:
    ///   - email: Email
    ///   - password: Password
    ///   - stub: Stub behaviour
    ///   - then: Completion
    func userLogin(email: String,
                   password: String,
                   stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
                   then: @escaping NetworkCompletion<UserJSON>) {
        guard !email.isEmpty && !password.isEmpty else {
            return then(.failure(.parameter))
        }

        let provider = MTPProvider(stubClosure: stub)
        let endpoint = MTP.userLogin(email: email, password: password)

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                let user = try response.map(UserJSON.self,
                                            using: JSONDecoder.mtp)
                guard let token = user.token else { throw NetworkError.token }
                self.data.token = token
                self.data.user = user
                self.report(success: endpoint)
                return then(.success(user))
            } catch {
                do {
                    let reply = try response.map(OperationReply.self,
                                                 using: JSONDecoder.mtp)
                    problem = .message(reply.message)
                } catch {
                    self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                    problem = .decoding(error.localizedDescription)
                }
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Register new user
    /// - Parameters:
    ///   - payload: RegistrationPayload
    ///   - stub: Stub behaviour
    ///   - then: Completion
    func userRegister(payload: RegistrationPayload,
                      stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
                      then: @escaping NetworkCompletion<UserJSON>) {
        guard payload.isValid else {
            return then(.failure(.parameter))
        }

        let provider = MTPProvider(stubClosure: stub)
        let endpoint = MTP.userRegister(payload: payload)

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                let user = try response.map(UserJSON.self,
                                            using: JSONDecoder.mtp)
                guard let token = user.token else { throw NetworkError.token }
                self.data.token = token
                self.data.user = user
                self.report(success: endpoint)
                self.userGetByToken(reload: true) { _ in
                    then(.success(user))
                }
                return
            } catch let error as NetworkError {
                problem = error
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            switch result {
            case .success(let response):
               success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Update user info
    /// - Parameters:
    ///   - payload: UserUpdatePayload
    ///   - stub: Stub behaviour
    ///   - then: Completion
    func userUpdate(payload: UserUpdatePayload,
                    stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
                    then: @escaping NetworkCompletion<UserJSON>) {
        let auth = AccessTokenPlugin { self.data.token }
        let provider = MTPProvider(stubClosure: stub, plugins: [auth])
        let endpoint = MTP.userPut(payload: payload)

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                let reply = try response.map(UserUpdateReply.self,
                                             using: JSONDecoder.mtp)
                if reply.isSuccess {
                    self.data.user = reply.user
                    self.report(success: endpoint)
                    return then(.success(reply.user))
                } else {
                    problem = .message(reply.message)
                }
            } catch let error as NetworkError {
                problem = error
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Update user token
    /// - Parameters:
    ///   - token: String
    ///   - stub: Stub behaviour
    ///   - then: Completion
    func userUpdate(token: String,
                    stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
                    then: @escaping NetworkCompletion<UserTokenReply>) {
        guard let userId = data.user?.id else {
            return then(.failure(.parameter))
        }

        let auth = AccessTokenPlugin { self.data.token }
        let provider = MTPProvider(stubClosure: stub, plugins: [auth])
        let endpoint = MTP.userPost(id: userId, token: token)

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                let reply = try response.map(UserTokenReply.self,
                                             using: JSONDecoder.mtp)
                self.report(success: endpoint)
                return then(.success(reply))
            } catch let error as NetworkError {
                problem = error
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    /// Resend verification email
    /// - Parameters:
    ///   - id: User ID
    ///   - stub: Stub behaviour
    ///   - then: Completion
    func userVerify(id: Int,
                    stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
                    then: @escaping NetworkCompletion<String>) {
        let auth = AccessTokenPlugin { self.data.token }
        let provider = MTPProvider(stubClosure: stub, plugins: [auth])
        let endpoint = MTP.userVerify(id: id)

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                let reply = try response.map(OperationReply.self,
                                             using: JSONDecoder.mtp)
                if reply.isSuccess {
                    self.report(success: endpoint)
                    return then(.success(reply.message))
                } else {
                    problem = .message(reply.message)
                }
            } catch let error as NetworkError {
                problem = error
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }
}

// MARK: - Private

private extension MTPNetworkController {

    func report(success endpoint: MTP) {
        report.event(.api(endpoint: endpoint,
                          success: true,
                          code: 0,
                          message: ""))
    }

    func report(failure endpoint: MTP,
                problem: NetworkError) {
        log.error("API \(endpoint): \(problem.errorDescription ?? "")")
        report.event(.api(endpoint: endpoint,
                          success: false,
                          code: problem.code,
                          message: problem.message))
    }

    func problem(with endpoint: MTP,
                 from moya: MoyaError) -> NetworkError {
        guard moya.modified(from: endpoint) else { return .notModified }

        let problem: NetworkError
        switch moya {
        case .statusCode(let response):
            problem = .status(response.statusCode)
        case let .underlying(error, response):
            problem = self.parse(error: error, response: response)
        default:
            problem = .network(moya.errorDescription ?? L.unknown())
        }
        report(failure: endpoint, problem: problem)
        return problem
    }

    func checkIn(list: Checklist,
                 id: Int,
                 stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
                 then: @escaping NetworkCompletion<Bool>) {
        guard data.isLoggedIn else { return then(.failure(.parameter)) }

        let auth = AccessTokenPlugin { self.data.token }
        let provider = MTPProvider(stubClosure: stub, plugins: [auth])
        let endpoint = MTP.checkIn(list: list, id: id)

        let success: SuccessHandler = { _ in
            self.report(success: endpoint)
            then(.success(true))
        }

        provider.request(endpoint) { result in
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    func checkOut(list: Checklist,
                  id: Int,
                  stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
                  then: @escaping NetworkCompletion<Bool>) {
        guard data.isLoggedIn else { return then(.failure(.parameter)) }

        let auth = AccessTokenPlugin { self.data.token }
        let provider = MTPProvider(stubClosure: stub, plugins: [auth])
        let endpoint = MTP.checkOut(list: list, id: id)

        let success: SuccessHandler = { _ in
            self.report(success: endpoint)
            then(.success(true))
        }

        provider.request(endpoint) { result in
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    func loadPhotos(id: Int?,
                    page: Int,
                    reload: Bool,
                    stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
                    then: @escaping NetworkCompletion<PhotosPageInfoJSON>) {
        guard data.isLoggedIn else { return then(.failure(.parameter)) }

        let auth = AccessTokenPlugin { self.data.token }
        let provider = MTPProvider(stubClosure: stub, plugins: [auth])
        let endpoint = MTP.photos(user: id, page: page)
        guard reload || !endpoint.isThrottled else {
            return then(.failure(.throttle))
        }

        let success: SuccessHandler = { response in
            let problem: NetworkError
            do {
                guard response.modified(from: endpoint) else {
                    throw NetworkError.notModified
                }
                let info = try response.map(PhotosPageInfoJSON.self,
                                            using: JSONDecoder.mtp)
                if let id = id {
                    self.data.set(photos: page, user: id, info: info)
                } else if let userId = self.data.user?.id {
                    self.data.set(photos: page, user: userId, info: info)
                }
                self.report(success: endpoint)
                return then(.success(info))
            } catch let error as NetworkError {
                problem = error
            } catch {
                self.log.error("decoding: \(endpoint.path): \(error)\n-\n\(response.toString)")
                problem = .decoding(error.localizedDescription)
            }
            self.report(failure: endpoint, problem: problem)
            then(.failure(problem))
        }

        provider.request(endpoint) { result in
            endpoint.markResponded()
            switch result {
            case .success(let response):
                success(response)
            case .failure(let error):
                then(.failure(self.problem(with: endpoint, from: error)))
            }
        }
    }

    func parse(error: Error?,
               response: Response?) -> NetworkError {
        if let aferror = error as? AFError?,
            case let .responseValidationFailed(.unacceptableStatusCode(code))? = aferror {
            switch code {
            case 304:
                return .notModified
            case 409: // Conflict - found in signup
                // expect message in OperationReply below
                break
            default:
                return .status(code)
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
            return .decoding(error.localizedDescription)
        }
    }
}

// MARK: - Support

private var active: Set<MTP> = []
private var received: [MTP: Date] = [:]

private extension MTP {

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

    func markResponded() {
        active.remove(self)
    }

    func markReceived() {
        markResponded()
        received[self] = Date().toUTC
    }
}

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

private extension Response {

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

        // expect x-ratelimit-limit = 60
        // check x-ratelimit-remaining?

        return true
    }

    var toString: String {
        return (try? mapString()) ?? "mapString failed"
    }
}

extension NetworkError: LocalizedError {

    /// Displayable description of NetworkError
    var errorDescription: String? {
        return L.errorDescription(code, message)
    }
}

private extension NetworkError {

    var code: Int {
        switch self {
        case .unknown:
            return 1_010
        case .decoding:
            return 1_020
        case .deviceOffline:
            return 1_030
        case .message:
            return 1_040
        case .network:
            return 1_050
        case .notModified:
            return 1_060
        case .parameter:
            return 1_070
        case .serverOffline:
            return 1_080
        case .status(let status):
            return status
        case .throttle:
            return 1_090
        case .token:
            return 1_100
        case .queued:
            return 2_000
        }
    }

    var message: String {
        switch self {
        case .unknown:
            return "unknown"
        case .decoding(let message):
            return message
        case .deviceOffline:
            return "device offline"
        case .message(let message):
            return message
        case .network(let message):
            return message
        case .notModified:
            return "not modified"
        case .parameter:
            return "parameter invalid"
        case .serverOffline:
            return "server offline"
        case .status(let status):
            return "status \(status)"
        case .throttle:
            return "network throttled"
        case .token:
            return "user token not found"
        case .queued:
            return "queued for later"
       }
    }
}

// MARK: - ServiceProvider conformance

extension MTP: ServiceProvider { }

extension Response: ServiceProvider { }
