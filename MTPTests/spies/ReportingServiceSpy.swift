// @copyright Trollwerks Inc.

@testable import MTP

// generated by https://github.com/seanhenry/SwiftMockGeneratorForXcode
// swiftlint:disable all

final class ReportingServiceSpy: ReportingService {
    var invokedScreen = false
    var invokedScreenCount = 0
    var invokedScreenParameters: (name: String, vc: AnyClass?)?
    var invokedScreenParametersList = [(name: String, vc: AnyClass?)]()
    func screen(name: String, vc: AnyClass?) {
        invokedScreen = true
        invokedScreenCount += 1
        invokedScreenParameters = (name, vc)
        invokedScreenParametersList.append((name, vc))
    }
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
    var invokedUser = false
    var invokedUserCount = 0
    var invokedUserParameters: (email: String, Void)?
    var invokedUserParametersList = [(email: String, Void)]()
    func user(email: String) {
        invokedUser = true
        invokedUserCount += 1
        invokedUserParameters = (email, ())
        invokedUserParametersList.append((email, ()))
    }
}
