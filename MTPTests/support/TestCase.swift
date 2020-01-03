// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

class TestCase: XCTestCase {

    override class func setUp() {
        super.setUp()
        guard ServiceProviderInstances.appServiceInstance == nil else { return }

        ServiceProviderInstances.appServiceInstance = ApplicationServiceSpy()
        ServiceProviderInstances.dataServiceInstance = DataServiceSpy()
        ServiceProviderInstances.locServiceInstance = LocationServiceSpy()
        ServiceProviderInstances.logServiceInstance = LoggingServiceSpy()
        ServiceProviderInstances.netServiceInstance = NetworkServiceSpy()
        ServiceProviderInstances.noteServiceInstance = NotificationServiceSpy()
        ServiceProviderInstances.reportServiceInstance = ReportingServiceSpy()
        ServiceProviderInstances.styleServiceInstance = StyleServiceSpy()
    }

    func wait(for seconds: TimeInterval) {
        let wait = XCTestExpectation(description: "wait")
        _ = XCTWaiter.wait(for: [wait], timeout: seconds)
    }
}
