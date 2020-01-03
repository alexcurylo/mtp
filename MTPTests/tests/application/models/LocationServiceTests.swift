// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class LocationServiceTests: TestCase {

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
        sut.add(photo: mappable)
        sut.add(post: mappable)
        sut.notify(mappable: mappable, triggered: Date())
        sut.reveal(mappable: mappable, callout: true)
        sut.show(more: mappable)
        sut.show(nearby: mappable)
        sut.update(mappable: mappable)
        sut.remove(tracker: tracker)

        // then
        XCTAssertNil(sut.here)
        XCTAssertNil(sut.inside)
        XCTAssertEqual(sut.distances, [:])
        XCTAssertNil(sut.nearest(list: .beaches, id: 1, to: .zero))
   }
}
