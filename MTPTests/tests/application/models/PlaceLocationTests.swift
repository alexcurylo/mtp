// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class PlaceLocationTests: TestCase {

    func testDescription() {
        // given
        let sut = PlaceLocation(countryId: 0,
                                countryName: "Angola",
                                id: 0,
                                locationName: "Angola",
                                regionId: 0,
                                regionName: "Africa")
        let expected = """
                       < PlaceLocation: Angola
                       countryId: Optional(0)
                       countryName: Optional("Angola")
                       id: 0
                       location_name: Optional("Angola")
                       region_id: Optional(0)
                       region_name: Optional("Africa")
                       /PlaceLocation >
                       """

        // then
        sut.description.assert(equal: "Angola")
        sut.debugDescription.assert(equal: expected)
    }
}
