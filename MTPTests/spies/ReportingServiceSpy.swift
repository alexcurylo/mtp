// @copyright Trollwerks Inc.

@testable import MTP

// generated by https://github.com/seanhenry/SwiftMockGeneratorForXcode
// swiftlint:disable all

final class ReportingServiceSpy: ReportingService {
    var invokedEvent = false
    var invokedEventCount = 0
    var invokedEventParameters: (event: AnalyticsEvent, Void)?
    var invokedEventParametersList = [(event: AnalyticsEvent, Void)]()
    func event(_ event: AnalyticsEvent) {
        invokedEvent = true
        invokedEventCount += 1
        invokedEventParameters = (event, ())
        invokedEventParametersList.append((event, ()))
    }
    var invokedScreen = false
    var invokedScreenCount = 0
    var invokedScreenParameters: (name: String, vc: AnyClass)?
    var invokedScreenParametersList = [(name: String, vc: AnyClass)]()
    func screen(name: String, vc: AnyClass) {
        invokedScreen = true
        invokedScreenCount += 1
        invokedScreenParameters = (name, vc)
        invokedScreenParametersList.append((name, vc))
    }
    var invokedUser = false
    var invokedUserCount = 0
    var invokedUserParameters: (signIn: String?, signUp: AnalyticsEvent.Method?)?
    var invokedUserParametersList = [(signIn: String?, signUp: AnalyticsEvent.Method?)]()
    func user(signIn: String?, signUp: AnalyticsEvent.Method?) {
        invokedUser = true
        invokedUserCount += 1
        invokedUserParameters = (signIn, signUp)
        invokedUserParametersList.append((signIn, signUp))
    }
}
