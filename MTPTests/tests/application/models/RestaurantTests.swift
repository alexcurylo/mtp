// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class RestaurantTests: MTPTestCase {

    func testDecodingComplete() throws {
        // given
        let realm = RealmDataController()
        let data = try XCTUnwrap(complete.data(using: .utf8))

        // when
        let json = try JSONDecoder.mtp.decode(RestaurantJSON.self,
                                              from: data)
        realm.set(restaurants: [json])
        let sut = try XCTUnwrap(Restaurant(from: json, realm: realm))
        let map = try XCTUnwrap(sut.map)

        // then
        json.description.assert(equal: map.title)
        json.debugDescription.assert(equal: completeDebugDescription)

        XCTAssertEqual(sut.placeId, 1)
        sut.description.assert(equal: map.title)

        XCTAssertEqual(sut.placeId, map.checklistId)
        XCTAssertEqual(map.checklist, .restaurants)
        map.region.assert(equal: "Europe")
        map.country.assert(equal: "Spain")
        map.title.assert(equal: "Akelare")
        map.subtitle.assert(equal: "Euskadi (Basque Country), Spain")
        map.image.assert(equal: "6tOez5EOtH18mZfwtlKNoC")
        map.website.assert(equal: "https://akelarre.net/en/")
        // swiftlint:disable number_separator
        XCTAssertEqual(map.latitude, 43.307133)
        XCTAssertEqual(map.longitude, -2.043636)
        XCTAssertEqual(map.visitors, 2)
    }

    func testDecodingIncomplete() throws {
        // given
        let realm = RealmDataController()
        let data = try XCTUnwrap(incomplete.data(using: .utf8))

        // when
        let json = try JSONDecoder.mtp.decode(RestaurantJSON.self,
                                              from: data)
        let sut = try XCTUnwrap(Restaurant(from: json, realm: realm))
        let map = try XCTUnwrap(sut.map)

        // then
        XCTAssertEqual(sut.placeId, 1)
        XCTAssertEqual(sut.placeId, map.checklistId)
        XCTAssertEqual(map.checklist, .restaurants)
        map.region.assert(equal: "Europe")
        map.country.assert(equal: "Spain")
        map.title.assert(equal: "Akelare")
        map.subtitle.assert(equal: "Euskadi (Basque Country), Spain")
        map.image.assert(.empty)
        map.website.assert(equal: "https://akelarre.net/en/")
        // swiftlint:disable number_separator
        XCTAssertEqual(map.latitude, 43.307133)
        XCTAssertEqual(map.longitude, -2.043636)
        XCTAssertEqual(map.visitors, 2)
    }

    func testDecodingInactive() throws {
        // given
        let realm = RealmDataController()
        let data = try XCTUnwrap(inactive.data(using: .utf8))

        // when
        let json = try JSONDecoder.mtp.decode(RestaurantJSON.self,
                                              from: data)
        let sut = Restaurant(from: json, realm: realm)

        // then
        XCTAssertNil(sut)
    }
}

private let complete = """
{
"id": 1,
"restid": 1,
"external_id": "2y16lav",
"stars": 3,
"title": "Akelare",
"country": null,
"lat": 43.307133,
"long": -2.043636,
"address": "paseo del Padre Orcolaga 56",
"url": "https://akelarre.net/en/",
"img": "",
"active": "Y",
"location_id": 262,
"is_top100": 0,
"rank_top100": null,
"visitors": 2,
"rank": 365,
"featured_img": "6tOez5EOtH18mZfwtlKNoC",
"location": {
"id": 262,
"location_name": "Euskadi (Basque Country)",
"country_id": 965,
"country_name": "Spain",
"region_id": 987,
"region_name": "Europe"
}
}
"""

private let completeDebugDescription = """
< RestaurantJSON: Akelare:
active: Y
address: Optional("paseo del Padre Orcolaga 56")
country: nil
externalId: 2y16lav
featuredImg: Optional("6tOez5EOtH18mZfwtlKNoC")
id: 1
isTop100: 0
lat: 43.307133
location: Optional(< PlaceLocation: Euskadi (Basque Country), Spain
countryId: 965
countryName: Spain
id: 262
location_name: Euskadi (Basque Country)
region_id: 987
region_name: Europe
/PlaceLocation >)
locationId: 262
long: -2.043636
rank: 365
rankTop100: nil
restid: 1
stars: 3
title: Akelare
url: https://akelarre.net/en/
visitors: 2
/RestaurantJSON >
"""

private let incomplete = """
{
"id": 1,
"restid": 1,
"external_id": "2y16lav",
"stars": 3,
"title": "Akelare",
"country": null,
"lat": 43.307133,
"long": -2.043636,
"address": "paseo del Padre Orcolaga 56",
"url": "https://akelarre.net/en/",
"img": "",
"active": "Y",
"location_id": 262,
"is_top100": 0,
"rank_top100": null,
"visitors": 2,
"rank": 365,
}
"""

private let inactive = """
{
"id": 1,
"restid": 1,
"external_id": "2y16lav",
"stars": 3,
"title": "Akelare",
"country": null,
"lat": 43.307133,
"long": -2.043636,
"address": "paseo del Padre Orcolaga 56",
"url": "https://akelarre.net/en/",
"img": "",
"active": "N",
"location_id": 262,
"is_top100": 0,
"rank_top100": null,
"visitors": 2,
"rank": 365,
"featured_img": "6tOez5EOtH18mZfwtlKNoC",
"location": {
"id": 262,
"location_name": "Euskadi (Basque Country)",
"country_id": 965,
"country_name": "Spain",
"region_id": 987,
"region_name": "Europe"
}
}
"""
