// @copyright Trollwerks Inc.

import MapKit
@testable import MTP
import XCTest

final class CLLocationCoordinate2DTests: XCTestCase {

    func testCodable() throws {
        // given
        let expected = CLLocationCoordinate2D(latitude: 22,
                                              longitude: 33)

        // when
        let encoded = try JSONEncoder().encode(expected)
        let sut = try JSONDecoder().decode(CLLocationCoordinate2D.self,
                                           from: encoded)

        // then
        XCTAssertEqual(sut, expected)
        XCTAssertFalse(sut.isZero)
    }

    func testDistance() throws {
        // given
        let coordinate = CLLocationCoordinate2D(latitude: 22,
                                                longitude: 33)
        let location = CLLocation(latitude: 22,
                                  longitude: 33)

        // when
        let sut = coordinate.location
        let distance = coordinate.distance(from: CLLocationCoordinate2D.zero)
        let same = coordinate.distance(from: sut)

        // then
        XCTAssertEqual(sut.coordinate, location.coordinate)
        XCTAssertEqual(floor(distance), 4_328_719)
        XCTAssertEqual(same, 0)
    }

    func testFormatting() throws {
        // given
        let kmThousand = CLLocationDistance(1_000_000)
        let kmTwo = CLLocationDistance(2_000)
        let kmHalf = CLLocationDistance(500)

        // when
        let textThousand = kmThousand.formatted
        let textTwo = kmTwo.formatted
        let textHalf = kmHalf.formatted

        // then
        textThousand.assert(equal: "1,000 km")
        textTwo.assert(equal: "2.0 km")
        textHalf.assert(equal: "500 m")
    }

    func testCluster() throws {
        // given
        let coordinates = [
            CLLocationCoordinate2D(latitude: 22, longitude: 33),
            CLLocationCoordinate2D(latitude: 33, longitude: 22)
        ]

        // when
        let sut = ClusterRegion(coordinates: coordinates)

        // then
        XCTAssertEqual(sut.maxDelta, 11)
    }
}
