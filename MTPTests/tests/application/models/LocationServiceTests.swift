// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class LocationServiceTests: MTPTestCase {

    func testBroadcast() {
        // given
        let sut = LocationServiceImpl()
        let handler = LocationHandlerSpy()
        let tracker = LocationsVCSpy()
        let mappable = Mappable()

        // when
        sut.inject(handler: handler)
        sut.calculateDistances()
        sut.insert(tracker: tracker)
        sut.close(mappable: mappable)
        sut.notify(mappable: mappable, triggered: Date())
        sut.reveal(mappable: mappable, callout: true)
        sut.show(mappable: mappable)
        sut.update(mappable: mappable)
        sut.remove(tracker: tracker)

        // then
        XCTAssertNil(sut.here)
        XCTAssertNil(sut.inside)
        XCTAssertEqual(sut.distances, [:])
        XCTAssertNil(sut.nearest(list: .beaches, id: 1, to: .zero))
   }
}
