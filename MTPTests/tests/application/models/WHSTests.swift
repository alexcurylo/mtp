// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class WHSTests: MTPTestCase {

    func testDecodingComplete() throws {
        // given
        let realm = RealmDataController()
        let data = try unwrap(complete.data(using: .utf8))
        var parents: Set<Int> = []

        // when
        let json = try JSONDecoder.mtp.decode(WHSJSON.self,
                                              from: data)
        realm.set(whss: [json])
        let sut = try unwrap(WHS(from: json, parents: &parents, realm: realm))
        let map = try unwrap(sut.map)

        // then
        json.description.assert(equal: "\(map.title) (1)")
        json.debugDescription.assert(equal: completeDebugDescription)

        XCTAssertEqual(sut.placeId, 1)
        sut.description.assert(equal: map.title)
        XCTAssertNil(sut.parent)
        XCTAssertNil(sut.placeParent)
        XCTAssertFalse(sut.hasParent)
        XCTAssertFalse(sut.visited)

        XCTAssertEqual(sut.placeId, map.checklistId)
        XCTAssertEqual(map.checklist, .whss)
        map.region.assert(equal: "South America")
        map.country.assert(equal: "Ecuador")
        map.title.assert(equal: "Galapagos Islands")
        map.subtitle.assert(equal: "Galapagos Islands, Ecuador")
        map.image.assert(equal: "3XQOh9uvWhBRlBqchvV9xy")
        map.website.assert(equal: "https://whc.unesco.org/en/list/1")
        // swiftlint:disable number_separator
        XCTAssertEqual(map.latitude, -0.81667)
        XCTAssertEqual(map.longitude, -91)
        XCTAssertEqual(map.visitors, 1064)
    }

    func testDecodingIncomplete() throws {
        // given
        let realm = RealmDataController()
        let data = try unwrap(incomplete.data(using: .utf8))
        var parents: Set<Int> = []

        // when
        let json = try JSONDecoder.mtp.decode(WHSJSON.self,
                                              from: data)
        let sut = WHS(from: json, parents: &parents, realm: realm)

        // then
        XCTAssertNil(sut)
    }

    func testDecodingOnlyCountry() throws {
        // given
        let realm = RealmDataController()
        let data = try unwrap(switzerland.data(using: .utf8))
        var parents: Set<Int> = []

        // when
        let json = try JSONDecoder.mtp.decode(WHSJSON.self,
                                              from: data)
        let sut = try unwrap(WHS(from: json, parents: &parents, realm: realm))
        let map = try unwrap(sut.map)

        // then
        map.region.assert(equal: "unknown")
        map.country.assert(equal: "Switzerland")
        map.subtitle.assert(equal: "Switzerland")
    }

    func testDecodingChild() throws {
        // given
        let realm = RealmDataController()
        let data = try unwrap(child.data(using: .utf8))
        var parents: Set<Int> = []

        // when
        let json = try JSONDecoder.mtp.decode(WHSJSON.self,
                                              from: data)
        let sut = try unwrap(WHS(from: json, parents: &parents, realm: realm))
        let map = try unwrap(sut.map)

        // then
        XCTAssertEqual(sut.placeId, 1701)
        sut.description.assert(equal: map.title)
        XCTAssertTrue(sut.hasParent)
        XCTAssertNil(sut.parent)
    }

    func testDecodingInactive() throws {
        // given
        let realm = RealmDataController()
        let data = try unwrap(inactive.data(using: .utf8))
        var parents: Set<Int> = []

        // when
        let json = try JSONDecoder.mtp.decode(WHSJSON.self,
                                              from: data)
        let sut = WHS(from: json, parents: &parents, realm: realm)

        // then
        XCTAssertNil(sut)
    }
}

private let complete = """
{
"id": 1,
"active": "Y",
"title": "Galapagos Islands",
"location_id": 18,
"lat": -0.81667,
"long": -91,
"unesco_id": 1,
"visitors": 1064,
"rank": 1023,
"parent_id": null,
"featured_img": "3XQOh9uvWhBRlBqchvV9xy",
"location": {
"id": 18,
"location_name": "Galapagos Islands",
"country_id": 930,
"country_name": "Ecuador",
"region_id": 992,
"region_name": "South America"
}
}
"""

private let completeDebugDescription = """
< WHSJSON: Galapagos Islands (1):
active: Y
featuredImg: Optional("3XQOh9uvWhBRlBqchvV9xy")
id: 1
lat: -0.81667
location: Optional(< PlaceLocation: Ecuador (930)
countryId: 930
countryName: Ecuador
id: 18
location_name: Galapagos Islands
region_id: 992
region_name: South America
/PlaceLocation >)
locationId: Optional(18)
long: -91.0
parentId: nil
rank: 1023
title: Galapagos Islands
unescoId: 1
visitors: 1064
/WHSJSON >
"""

private let incomplete = """
{
"id": 1,
"active": "Y",
"title": "Galapagos Islands",
"lat": -0.81667,
"long": -91,
"unesco_id": 1,
"visitors": 1064,
"rank": 1023,
"parent_id": null,
"featured_img": ""
}
"""

private let switzerland = """
{
"id": 1,
"active": "Y",
"title": "Galapagos Islands",
"location_id": 323,
"lat": -0.81667,
"long": -91,
"unesco_id": 1,
"visitors": 1064,
"rank": 1023,
"parent_id": null,
"featured_img": ""
}
"""

private let child = """
{
"id": 1701,
"active": "Y",
"title": "Santa Marieda la Mayor",
"location_id": 763,
"lat": -27.55,
"long": -55.33333333,
"unesco_id": 275,
"visitors": 4,
"rank": 77,
"parent_id": 275,
"featured_img": "3xDoGVuAtHH2lP21IIJrws",
"location": {
"id": 763,
"location_name": "Misiones Province",
"country_id": 163,
"country_name": "Argentina",
"region_id": 992,
"region_name": "South America"
}
}
"""

private let inactive = """
{
"id": 1,
"active": "N",
"title": "Galapagos Islands",
"location_id": 18,
"lat": -0.81667,
"long": -91,
"unesco_id": 1,
"visitors": 1064,
"rank": 1023,
"parent_id": null,
"featured_img": "3XQOh9uvWhBRlBqchvV9xy",
"location": {
"id": 18,
"location_name": "Galapagos Islands",
"country_id": 930,
"country_name": "Ecuador",
"region_id": 992,
"region_name": "South America"
}
}
"""
