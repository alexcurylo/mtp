// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class UNCountryTests: XCTestCase {

    func testDecodingComplete() throws {
        // given
        let realm = RealmDataController()
        let data = try unwrap(complete.data(using: .utf8))

        // when
        let json = try JSONDecoder.mtp.decode(LocationJSON.self,
                                              from: data)
        realm.set(uncountries: [json])
        let sut = try unwrap(UNCountry(from: json))

        // then
        json.description.assert(equal: "Marshall Islands")
        json.debugDescription.assert(equal: completeDebugDescription)
        XCTAssertNil(sut.placeParent)
        XCTAssertEqual(sut.placeSubtitle, "")
        XCTAssertFalse(sut.placeIsCountry)

        XCTAssertEqual(sut.placeCountry, "Marshall Islands")
        XCTAssertEqual(sut.placeCountry, sut.placeTitle)
        XCTAssertEqual(sut.placeId, 35)
        XCTAssertEqual(sut.placeCountryId, 35)
        XCTAssertEqual(sut.placeImage, "4Fpc4QFHTx3QKq8YGz70CT")
        XCTAssertEqual(sut.placeImageUrl, "4Fpc4QFHTx3QKq8YGz70CT".mtpImageUrl)
        XCTAssertEqual(sut.placeWebUrl, URL(string: "https://mtp.travel/locations/35"))
        XCTAssertNil(sut.placeLocation)
        XCTAssertEqual(sut.placeVisitors, 581)
        XCTAssertEqual(sut.placeRegion, "Pacific Ocean")
        XCTAssertEqual(sut.placeCoordinate, .zero)
   }

    func testDecodingIncomplete() throws {
        // given
        let data = try unwrap(incomplete.data(using: .utf8))

        // when
        let json = try JSONDecoder.mtp.decode(LocationJSON.self,
                                              from: data)
        let sut = try unwrap(UNCountry(from: json))

        // then
        json.description.assert(equal: "Marshall Islands")

        XCTAssertEqual(sut.placeCountry, "Marshall Islands")
        XCTAssertEqual(sut.placeId, 35)
        XCTAssertEqual(sut.placeImage, "")
        XCTAssertNil(sut.placeLocation)
        XCTAssertEqual(sut.placeVisitors, 581)
        XCTAssertEqual(sut.placeRegion, "Pacific Ocean")
    }

    func testDecodingInactive() throws {
        // given
        let data = try unwrap(inactive.data(using: .utf8))

        // when
        let json = try JSONDecoder.mtp.decode(LocationJSON.self,
                                              from: data)
        let sut = UNCountry(from: json)

        // then
        XCTAssertNil(sut)
    }
}

private let complete = """
{
"id": 35,
"weather": "global/stations/91376",
"weatherhist": "67319",
"active": "Y",
"lat": 7.131474,
"lon": 171.184478,
"distance": 400,
"zoom": 6,
"region_id": 991,
"country_id": 35,
"region_name": "Pacific Ocean",
"country_name": "Marshall Islands",
"location_name": "Marshall Islands",
"is_un": 1,
"is_mtp_location": 1,
"admin_level": 2,
"featured_img": "4Fpc4QFHTx3QKq8YGz70CT",
"airports": "MAJ",
"visitors": 581,
"rank": 288,
"visitors_un": 581,
"rank_un": 17
}
"""

private let completeDebugDescription = """
< LocationJSON: Marshall Islands:
active: Y
admin_level: 2
airports: Optional("MAJ")
countryId: Optional(35)
countryName: Marshall Islands
distance: Optional(400.0)
featuredImg: Optional("4Fpc4QFHTx3QKq8YGz70CT")
id: 35
is_mtp_location: 1
is_un: 1
lat: Optional(7.131474)
location_name: Marshall Islands
lon: Optional(171.184478)
rank: 288
rankUn: 17
region_id: 991
region_name: Pacific Ocean
visitors: 581
visitorsUn: 581
weather: Optional("global/stations/91376")
weatherhist: Optional("67319")
zoom: Optional(6)
/LocationJSON >
"""

private let incomplete = """
{
"id": 35,
"weather": "global/stations/91376",
"weatherhist": "67319",
"active": "Y",
"lat": 7.131474,
"lon": 171.184478,
"distance": 400,
"zoom": 6,
"region_id": 991,
"country_id": 35,
"region_name": "Pacific Ocean",
"country_name": "Marshall Islands",
"location_name": "Marshall Islands",
"is_un": 1,
"is_mtp_location": 1,
"admin_level": 2,
"airports": "MAJ",
"visitors": 581,
"rank": 288,
"visitors_un": 581,
"rank_un": 17
}
"""

private let inactive = """
{
"id": 35,
"weather": "global/stations/91376",
"weatherhist": "67319",
"active": "N",
"lat": 7.131474,
"lon": 171.184478,
"distance": 400,
"zoom": 6,
"region_id": 991,
"country_id": 35,
"region_name": "Pacific Ocean",
"country_name": "Marshall Islands",
"location_name": "Marshall Islands",
"is_un": 1,
"is_mtp_location": 1,
"admin_level": 2,
"featured_img": "4Fpc4QFHTx3QKq8YGz70CT",
"airports": "MAJ",
"visitors": 581,
"rank": 288,
"visitors_un": 581,
"rank_un": 17
}
"""
