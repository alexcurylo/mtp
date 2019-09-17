// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class PlaceLocationTests: MTPTestCase {

    func testDescription() {
        // given
        let sut = PlaceLocation(countryId: 0,
                                countryName: "Angola",
                                id: 0,
                                locationName: "Angola",
                                regionId: 0,
                                regionName: "Africa")
        let expected = """
                       < PlaceLocation: Angola (0)
                       countryId: 0
                       countryName: Angola
                       id: 0
                       location_name: Angola
                       region_id: 0
                       region_name: Africa
                       /PlaceLocation >
                       """

        // then
        sut.description.assert(equal: "Angola (0)")
        sut.debugDescription.assert(equal: expected)
    }
}
