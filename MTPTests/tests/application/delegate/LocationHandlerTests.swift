// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class LocationHandlerTests: MTPTestCase {

    private var dataService: DataService?
    private var dataSpy: DataServiceSpy?
    private var locService: LocationService?
    private var locSpy: LocationServiceSpy?

    override func setUp() {
        super.setUp()
        dataService = ServiceProviderInstances.dataServiceInstance
        dataSpy = DataServiceSpy()
        dataSpy?.stubbedResolveResult = Mappable()
        ServiceProviderInstances.dataServiceInstance = dataSpy
        locService = ServiceProviderInstances.locServiceInstance
        locSpy = LocationServiceSpy()
        ServiceProviderInstances.locServiceInstance = locSpy
    }

    override func tearDown() {
        ServiceProviderInstances.dataServiceInstance = dataService
        ServiceProviderInstances.locServiceInstance = locService
        dataSpy = nil
        //locSpy = nil
        super.tearDown()
    }

    func testLaunch() throws {
        // given
        let app = UIApplication.shared
        let sut = LocationHandler()
        let spy = try XCTUnwrap(locSpy)

        // when
        let will = sut.application(app, willFinishLaunchingWithOptions: [:])
        let did = sut.application(app, didFinishLaunchingWithOptions: [:])

        // then
        XCTAssertTrue(will)
        XCTAssertTrue(did)
        XCTAssertTrue(spy.invokedInject)
        locSpy = nil
    }

    func testBroadcasting() throws {
        // given
        let tracker = LocationsVC()
        let realm = RealmDataController()
        let mappable = try XCTUnwrap(realm.mappable(item: (.locations, 1)))
        let sut = LocationHandler()

        // when
        sut.insert(tracker: tracker)
        let called = expectation(description: "called")
        sut.broadcast { _ in called.fulfill() }
        let received = expectation(description: "received")
        sut.broadcast(mappable: mappable) { _, _ in received.fulfill() }
        waitForExpectations(timeout: 5, handler: nil)
        sut.remove(tracker: tracker)
        let notCalled = expectation(description: "notCalled")
        notCalled.isInverted = true
        sut.broadcast { _ in notCalled.fulfill() }

        // then
        waitForExpectations(timeout: 2, handler: nil)
        XCTAssertTrue(try XCTUnwrap(dataSpy).invokedResolve)
    }
}
