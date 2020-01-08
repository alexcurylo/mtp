// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class PlaceInfoTests: TestCase {

    // Setting removes missing items
    func disabled_testBeachDecoding() throws {
        // given
        let realm = RealmDataController()
        let data = try XCTUnwrap(completeBeach.data(using: .utf8))

        // when
        let json = try JSONDecoder.mtp.decode(PlaceJSON.self,
                                              from: data)
        realm.set(beaches: [json])
        let sut = try XCTUnwrap(Beach(from: json, realm: realm))
        let map = try XCTUnwrap(sut.map)
        let dupe: PlaceInfo = Beach(value: sut)

        // then
        json.description.assert(equal: map.title)
        json.debugDescription.assert(equal: completeDebugDescriptionBeach)

        XCTAssertEqual(sut.placeId, 1)
        sut.description.assert(equal: map.title)
        XCTAssertNil(sut.placeParent)
        XCTAssertEqual(sut.placeSubtitle, map.subtitle)
        XCTAssertEqual(sut.placeCountryId, 0)
        XCTAssertFalse(sut.placeIsCountry)
        XCTAssertTrue(sut == dupe)

        XCTAssertEqual(sut.placeId, map.checklistId)
        XCTAssertEqual(map.checklist, .beaches)
        map.region.assert(equal: "Atlantic Ocean")
        map.country.assert(equal: "Brazil")
        map.title.assert(equal: "Baia do Sancho")
        map.subtitle.assert(equal: "Fernando de Noronha, Brazil")
        map.image.assert(equal: "3Ed2354d9SZHiWtPwAVLBc")
        map.website.assert(equal: "https://www.supercoolbeaches.com/brazil/baia-do-sancho")
        // swiftlint:disable number_separator
        XCTAssertEqual(map.latitude, -3.854125)
        XCTAssertEqual(map.longitude, -32.444118)
        XCTAssertEqual(map.visitors, 176)
    }

    // Setting removes missing items
    func disabled_testDiveSiteDecoding() throws {
        // given
        let realm = RealmDataController()
        let data = try XCTUnwrap(completeDiveSite.data(using: .utf8))

        // when
        let json = try JSONDecoder.mtp.decode(PlaceJSON.self,
                                              from: data)
        realm.set(divesites: [json])
        let sut = try XCTUnwrap(DiveSite(from: json, realm: realm))
        let map = try XCTUnwrap(sut.map)

        // then
        json.description.assert(equal: map.title)
        json.debugDescription.assert(equal: completeDebugDescriptionDiveSite)

        XCTAssertEqual(sut.placeId, 1)
        sut.description.assert(equal: map.title)

        XCTAssertEqual(sut.placeId, map.checklistId)
        XCTAssertEqual(map.checklist, .divesites)
        map.region.assert(equal: "Pacific Ocean")
        map.country.assert(equal: "Australia")
        map.title.assert(equal: "Yongala, Australia")
        map.subtitle.assert(equal: "Queensland, Australia")
        map.image.assert(equal: "")
        map.website.assert(equal: "http://www.scubatravel.co.uk/australia/")
        // swiftlint:disable number_separator
        XCTAssertEqual(map.latitude, -19.452278)
        XCTAssertEqual(map.longitude, 147.47927)
        XCTAssertEqual(map.visitors, 97)
    }

    // Setting removes missing items
    func disabled_testGolfCourseDecoding() throws {
        // given
        let realm = RealmDataController()
        let data = try XCTUnwrap(completeGolfCourse.data(using: .utf8))

        // when
        let json = try JSONDecoder.mtp.decode(PlaceJSON.self,
                                              from: data)
        realm.set(golfcourses: [json])
        let sut = try XCTUnwrap(GolfCourse(from: json, realm: realm))
        let map = try XCTUnwrap(sut.map)

        // then
        json.description.assert(equal: map.title)
        json.debugDescription.assert(equal: completeDebugDescriptionGolfCourse)

        XCTAssertEqual(sut.placeId, 1)
        sut.description.assert(equal: map.title)

        XCTAssertEqual(sut.placeId, map.checklistId)
        XCTAssertEqual(map.checklist, .golfcourses)
        map.region.assert(equal: "North America")
        map.country.assert(equal: "United States")
        map.title.assert(equal: "PINE VALLEY G.C.")
        map.subtitle.assert(equal: "New Jersey, United States")
        map.image.assert(equal: "5ENPv3Rf31ZtPJXfJ97z2a")
        map.website.assert(equal: "http://golfclubatlas.com/courses-by-country/usa/pine-valley-golf-club/")
        // swiftlint:disable number_separator
        XCTAssertEqual(map.latitude, 39.78658)
        XCTAssertEqual(map.longitude, -74.969097)
        XCTAssertEqual(map.visitors, 5)
    }

    func testInactiveDecoding() throws {
        // given
        let data = try XCTUnwrap(inactive.data(using: .utf8))
        let realm = RealmDataController()

        // when
        let json = try JSONDecoder.mtp.decode(PlaceJSON.self,
                                              from: data)
        let beach = Beach(from: json, realm: realm)
        let divesite = DiveSite(from: json, realm: realm)
        let golfcourse = GolfCourse(from: json, realm: realm)

        // then
        XCTAssertNil(beach)
        XCTAssertNil(divesite)
        XCTAssertNil(golfcourse)
    }
}

private let completeBeach = """
{
"id": 1,
"country": "Brazil",
"title": "Baia do Sancho",
"lat": -3.854125,
"long": -32.444118,
"img": "http://media-cdn.tripadvisor.com/media/photo-o/07/4b/ef/1c/baia-do-sancho.jpg",
"url": "https://www.supercoolbeaches.com/brazil/baia-do-sancho",
"notes": "",
"active": "Y",
"location_id": 227,
"visitors": 176,
"rank": 128,
"featured_img": "3Ed2354d9SZHiWtPwAVLBc",
"location": {
"id": 227,
"location_name": "Fernando de Noronha",
"country_id": 165,
"country_name": "Brazil",
"region_id": 984,
"region_name": "Atlantic Ocean"
}
}
"""

private let completeDebugDescriptionBeach = """
< PlaceJSON: Baia do Sancho:
active: Y
address: nil
country: Brazil
featuredImg: Optional("3Ed2354d9SZHiWtPwAVLBc")
id: 1
lat: -3.854125
location: Fernando de Noronha, Brazil
locationId: 227
long: -32.444118
notes: Optional("")
rank: 128
title: Baia do Sancho
url: https://www.supercoolbeaches.com/brazil/baia-do-sancho
visitors: 176
/PlaceJSON >
"""

private let completeDiveSite = """
{
"id": 1,
"title": "Yongala, Australia",
"country": "Australia",
"lat": -19.452278,
"long": 147.47927,
"url": "http://www.scubatravel.co.uk/australia/",
"img": null,
"active": "Y",
"location_id": 60,
"visitors": 97,
"rank": 21,
"location": {
"id": 60,
"location_name": "Queensland",
"country_id": 917,
"country_name": "Australia",
"region_id": 991,
"region_name": "Pacific Ocean"
}
}
"""

private let completeDebugDescriptionDiveSite = """
< PlaceJSON: Yongala, Australia:
active: Y
address: nil
country: Australia
featuredImg: nil
id: 1
lat: -19.452278
location: Queensland, Australia
locationId: 60
long: 147.47927
notes: nil
rank: 21
title: Yongala, Australia
url: http://www.scubatravel.co.uk/australia/
visitors: 97
/PlaceJSON >
"""

private let completeGolfCourse = """
{
"id": 1,
"title": "PINE VALLEY G.C.",
"country": "USA",
"lat": 39.78658,
"long": -74.969097,
"img": "https://cbsphilly.files.wordpress.com/2011/05/pine-valley1.jpg%3Fw%3D620",
"url": "http://golfclubatlas.com/courses-by-country/usa/pine-valley-golf-club/",
"active": "Y",
"address": "Pine Valley, N.J., U.S.A. / 7,057 yards, Par 70",
"notes": "",
"location_id": 119,
"visitors": 5,
"rank": 21,
"featured_img": "5ENPv3Rf31ZtPJXfJ97z2a",
"count_visitors": 5,
"location": {
"id": 119,
"location_name": "New Jersey",
"country_id": 977,
"country_name": "United States",
"region_id": 990,
"region_name": "North America"
}
}
"""

private let completeDebugDescriptionGolfCourse = """
< PlaceJSON: PINE VALLEY G.C.:
active: Y
address: Optional("Pine Valley, N.J., U.S.A. / 7,057 yards, Par 70")
country: USA
featuredImg: Optional("5ENPv3Rf31ZtPJXfJ97z2a")
id: 1
lat: 39.78658
location: New Jersey, United States
locationId: 119
long: -74.969097
notes: Optional("")
rank: 21
title: PINE VALLEY G.C.
url: http://golfclubatlas.com/courses-by-country/usa/pine-valley-golf-club/
visitors: 5
/PlaceJSON >
"""

private let inactive = """
{
"id": 1,
"title": "PINE VALLEY G.C.",
"country": "USA",
"lat": 39.78658,
"long": -74.969097,
"img": "https://cbsphilly.files.wordpress.com/2011/05/pine-valley1.jpg%3Fw%3D620",
"url": "http://golfclubatlas.com/courses-by-country/usa/pine-valley-golf-club/",
"active": "N",
"address": "Pine Valley, N.J., U.S.A. / 7,057 yards, Par 70",
"notes": "",
"location_id": 119,
"visitors": 5,
"rank": 21,
"featured_img": "5ENPv3Rf31ZtPJXfJ97z2a",
"count_visitors": 5,
"location": {
"id": 119,
"location_name": "New Jersey",
"country_id": 977,
"country_name": "United States",
"region_id": 990,
"region_name": "North America"
}
}
"""
