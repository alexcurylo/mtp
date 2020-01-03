// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class CountryTests: TestCase {

    func testPlaceholderAll() throws {
        // given
        let all = Country.all
        let same = Country.all

        // then
        XCTAssertEqual(all.placeCountry, "(All countries)")
        XCTAssertEqual(all, same)
        XCTAssertFalse(all.isEqual(nil))
    }

    func testDecoding() throws {
        // given
        let realm = RealmDataController()
        let data = try XCTUnwrap(complete.data(using: .utf8))

        // when
        let json = try JSONDecoder.mtp.decode(CountryJSON.self,
                                              from: data)
        realm.set(countries: [json])
        let sut = try XCTUnwrap(Country(from: json))
        let different = Country(value: sut).with { $0.placeCountry = "different" }

        // then
        json.description.assert(equal: "Switzerland")
        json.debugDescription.assert(equal: completeDebugDescription)

        XCTAssertEqual(sut.countryId, 323)
        XCTAssertEqual(sut.placeCountry, "Switzerland")
        XCTAssertEqual(sut.placeCountry, sut.description)
        XCTAssertTrue(sut.hasChildren)
        XCTAssertEqual(sut.children.count, 0)

        XCTAssertNotEqual(sut, different)
    }
}

private let complete = """
{
"admin_level": 2,
"is_mtp_location": 0,
"has_children": true,
"country_id": 323,
"country_name": "Switzerland"
}
"""

private let completeDebugDescription = """
< CountryJSON: Switzerland:
admin_level: 2
countryId: 323
countryName: Switzerland
hasChildren: true
is_mtp_location: 0
/CountryJSON >
"""
