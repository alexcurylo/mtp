// @copyright Trollwerks Inc.

import Firebase

/// Analytics and crash reporting
protocol ReportingService {

    func report(event: AnalyticsEvent)
    func set(userId: String)
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
final class FirebaseReportingService: ReportingService {

    // https://firebase.google.com/docs/analytics/ios/events
    // Suggested events: see the FIREventNames.h header file.
    // Prescribed parameters: see the FIRParameterNames.h header file.

    private let eventMapper = AnalyticsEventMapper()

    func report(event: AnalyticsEvent) {
        let name = eventMapper.eventName(for: event)
        let parameters = eventMapper.parameters(for: event)
        Analytics.logEvent(name, parameters: parameters)
    }

    func set(userId: String) {
        let signedIn = !userId.isEmpty
        Crashlytics.sharedInstance().setUserIdentifier(userId)
        report(event: signedIn ? .userSignedIn : .userSignedOut)
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
final class ReportingServiceStub: ReportingService {

    func report(event: AnalyticsEvent) { }
    func set(userId: String) { }
}

#endif
