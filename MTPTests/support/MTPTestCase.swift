// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

class MTPTestCase: XCTestCase {

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
}
