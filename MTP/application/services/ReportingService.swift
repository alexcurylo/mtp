// @copyright Trollwerks Inc.

import Firebase
import UIKit

/// Analytics and crash reporting
protocol ReportingService: AnyObject {

    /// Report screen name
    ///
    /// - Parameters:
    ///   - name: Name of screen
    ///   - vc: Class to describe
    func screen(name: String, vc: AnyClass?)
    /// Report an event
    ///
    /// - Parameter event: Event to report
    func event(_ event: AnalyticsEvent)
    /// Set user identifier
    ///
    /// - Parameter email: Email
    func user(email: String)
}

/// Reportable events
enum AnalyticsEvent: Equatable {

    /// API called
    case api(Endpoint)
    /// userSignedIn
    case userSignedIn
    /// userSignedOut
    case userSignedOut

    /// API endpoints
    enum Endpoint: String {

        /// login
        case login
    }

    fileprivate var parameters: [Parameter: String] {
        switch self {
        case .userSignedIn,
             .userSignedOut:
            return [:]
        case .api(let endpoint):
            return [ .endpoint: endpoint.rawValue ]
        }
    }

    fileprivate enum Parameter {
        case endpoint
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
    func screen(name: String, vc: AnyClass?) {
        Analytics.setScreenName(name, screenClass: vc?.description())
    }

    /// Report an event
    ///
    /// - Parameter event: Event to report
    func event(_ event: AnalyticsEvent) {
        let name = eventMapper.eventName(for: event)
        let parameters = eventMapper.parameters(for: event)
        send(name: name, parameters: parameters)
    }

    fileprivate func send(name: String,
                          parameters: [String: String]) {
        Analytics.logEvent(name, parameters: parameters)
    }

    /// Set user email
    ///
    /// - Parameter email: Email
    func user(email: String) {
        let userId = email.md5Value
        Analytics.setUserID(userId)
        Crashlytics.sharedInstance().setUserIdentifier(userId)

        let signedIn = !userId.isEmpty
        event(signedIn ? .userSignedIn : .userSignedOut)
    }
}

private struct AnalyticsEventMapper {

    func eventName(for event: AnalyticsEvent) -> String {
        switch event {
        case .api:
            return "api"
        case .userSignedIn:
            return "user_signin"
        case .userSignedOut:
            return "user_signout"
        }
    }

    func parameters(for event: AnalyticsEvent) -> [String: String] {
        return event.parameters.mapKeys { parameterName(for: $0) }
    }

    func parameterName(for parameter: AnalyticsEvent.Parameter) -> String {
        switch parameter {
        case .endpoint:
            return "endpoint"
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

// MARK: - Testing

#if DEBUG

/// Stub for testing
final class ReportingServiceStub: FirebaseReportingService {

    override fileprivate var enabled: Bool { return false }
}

#endif
