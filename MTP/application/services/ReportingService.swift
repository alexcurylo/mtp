// @copyright Trollwerks Inc.

import Firebase
import Moya
import UIKit
import enum Result.Result

/// Analytics and crash reporting
protocol ReportingService: AnyObject {

    /// Report an event
    ///
    /// - Parameter event: Event to report
    func event(_ event: AnalyticsEvent)
    /// Report screen name
    ///
    /// - Parameters:
    ///   - name: Name of screen
    ///   - vc: Class to describe
    func screen(name: String, vc: AnyClass)
    /// Set user identifier
    ///
    /// - Parameter email: Email
    func user(signIn: String?, signUp: AnalyticsEvent.Method?)
}

/// Reportable events
enum AnalyticsEvent {

    /// API called
    case api(endpoint: MTP,
             success: Bool,
             code: Int,
             message: String)
    /// login
    case login
    // search
    //case search
    // search
    //case select
    // share
    //case share
    /// sign up
    case signup(method: Method)

    /// Signup method
    enum Method: String {

        /// Email
        case email
        /// Facebook
        case facebook
    }

    fileprivate var parameters: [Parameter: Any] {
        switch self {
        case .login:
            return [:]
        case let .api(endpoint, success, code, message):
            return [ .endpoint: endpoint.parameter,
                     .path: endpoint.path.truncate(length: 30),
                     .etag: endpoint.etag.truncate(length: 20),
                     .success: success ? 1 : 0,
                     .code: code,
                     .message: message.truncate(length: 30) ]
        case .signup(let method):
           return [ .method: method.rawValue]
        }
    }

    fileprivate enum Parameter: String {
        case code
        case endpoint
        case etag
        case message
        case method
        case path
        case success
    }
}

/// Production implementation of ReportingService
class FirebaseReportingService: ReportingService {

    // https://firebase.google.com/docs/analytics/ios/events
    // https://firebase.google.com/docs/analytics/configure-data-collection
    // Suggested events: see the FIREventNames.h header file.
    // Prescribed parameters: see the FIRParameterNames.h header file.
    // https://support.google.com/firebase/answer/6317498
    // https://firebase.google.com/docs/analytics/ios/events
    // https://firebase.google.com/docs/analytics/ios/properties
    // https://support.google.com/firebase/topic/6317484?hl=en&ref_topic=6386699

    private let eventMapper = AnalyticsEventMapper()
    fileprivate var enabled: Bool { return true }

    init() {
        Analytics.setAnalyticsCollectionEnabled(enabled)
    }

    /// Report screen name
    ///
    /// - Parameters:
    ///   - name: Name of screen
    ///   - vc: Class to describe
    func screen(name: String, vc: AnyClass) {
        Analytics.setScreenName(name, screenClass: vc.description())
    }

    /// Report an event
    ///
    /// - Parameter event: Event to report
    func event(_ event: AnalyticsEvent) {
        let name = eventMapper.eventName(for: event)
        let parameters = eventMapper.parameters(for: event)
        Analytics.logEvent(name, parameters: parameters)
    }

    /// Report sign in + sign up, set identifier
    ///
    /// - Parameters:
    ///   - signIn: Email
    ///   - signUp: Method
    func user(signIn: String?, signUp: AnalyticsEvent.Method?) {
        let userId = signIn?.md5Value
        Analytics.setUserID(userId)
        Crashlytics.sharedInstance().setUserIdentifier(userId)

        if userId != nil { event(.login) }
        if let signUp = signUp { event( .signup(method: signUp)) }
    }
}

private struct AnalyticsEventMapper {

    func eventName(for event: AnalyticsEvent) -> String {
        switch event {
        case .api:
            return "api"
        case .login:
            return AnalyticsEventLogin
        //case .search:
            // AnalyticsParameterSearchTerm (NSString)
            //return AnalyticsEventSearch
        //case .select:
            // AnalyticsParameterContentType (NSString)
            // AnalyticsParameterItemList (NSString)
            // AnalyticsParameterItemName (NSString)
            // AnalyticsParameterItemID (NSString)
            // AnalyticsParameterIndex (NSNumber)
            // AnalyticsParameterItemLocationID (NSString)
            //return AnalyticsEventSelectContent
        //case .share:
            // AnalyticsParameterContentType (NSString)
            // AnalyticsParameterItemID (NSString)
            //return AnalyticsEventShare
        case .signup:
            return AnalyticsEventSignUp
        }
    }

    func parameters(for event: AnalyticsEvent) -> [String: Any] {
        return event.parameters.mapKeys { parameterName(for: $0) }
    }

    func parameterName(for parameter: AnalyticsEvent.Parameter) -> String {
        switch parameter {
        case .code,
             .endpoint,
             .etag,
             .message,
             .path:
            return parameter.rawValue
        case .method:
            return AnalyticsParameterMethod
        case .success:
            return AnalyticsParameterSuccess
        }
    }
}

private extension Dictionary {

    func mapKeys<NewKeyT>(_ transform: (Key) throws -> NewKeyT) rethrows -> [NewKeyT: Value] {
        var newDictionary = [NewKeyT: Value]()
        try forEach { key, value in
            let newKey = try transform(key)
            newDictionary[newKey] = value
        }
        return newDictionary
    }
}

private extension MTP {

    var parameter: String {
        switch self {
        case .beach:
            return "load_beaches"
        case .checkIn: // (let list, let id):
            return "check_in"
        case .checklists:
            return "load_checklists"
        case .checkOut: // (let list, let id):
            return "check_out"
        case .countriesSearch: // (let query):
            return "search_countries"
        case .divesite:
            return "load_divesites"
        case .faq:
            return "load_faq"
        case .geoJson: // (let map):
            return "load_map"
        case .golfcourse:
            return "load_golfcourses"
        case .location:
            return "load_locations"
        case .locationPhotos: // (let location):
            return "load_location_photos"
        case .locationPosts: // (let location):
            return "load_location_posts"
        case .passwordReset: // (let email):
            return "password_reset"
        case .picture: // (let uuid, let size):
            return "load_picture"
        case .photos: // (let user, let page):
            return "load_user_photos"
        case .postPublish: // (let payload):
            return "upload_post"
        case .rankings: // (let query):
            return "load_rankings"
        case .restaurant:
            return "load_restaurants"
        case .scorecard: // (let list, let user):
            return "load_scorecard"
        case .search: // (let query):
            return "search_query"
        case .settings:
            return "load_settings"
        case .unCountry:
            return "load_uncountries"
        case .upload: // (let photo, let caption, let location):
            return "upload_photo"
        case .userDelete: // (let id):
            return "delete_user"
        case .userGet: // (let id):
            return "load_user_info"
        case .userGetByToken:
            return "load_user_info_token"
        case .userPosts: // (let id):
            return "load_user_posts"
        case .userPost: // (let id, let token):
            return "upload_user_apns"
        case .userPut: // (let payload):
            return "upload_user_info"
        case .userLogin: // (let email, let password):
            return "user_login"
        case .userRegister: // (let payload):
            return "register_user"
        case .userVerify: // (let id):
            return "verify_email"
        case .whs:
            return "load_whss"
        }
    }
}

// MARK: - Testing

#if DEBUG

/// Stub for testing
final class ReportingServiceStub: FirebaseReportingService {

    override fileprivate var enabled: Bool { return false }
}

#endif
