// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class PhotoTests: MTPTestCase {

    func testDecodingInfo() throws {
        // given
        let locationId = 9_999
        let realm = RealmDataController()
        let data = try unwrap(completeInfo.data(using: .utf8))
        let expectedImage = MTP.picture(uuid: "6uMTYDtfMXxLWVEj4JaTnC",
                                        size: .any).requestUrl
        let attributes = NSAttributedString.attributes(
            color: .white,
            font: Avenir.heavy.of(size: 16)
        )
        let expectedTitle = NSAttributedString(string: "Salt workers",
                                               attributes: attributes)

        // when
        let json = try JSONDecoder.mtp.decode(PhotosInfoJSON.self,
                                              from: data)
        realm.set(locationPhotos: locationId, info: json)
        let photoJson = json.data[0]
        let sut = Photo(from: photoJson)

        // then
        json.description.assert(equal: "PhotosInfoJSON (1)")
        json.debugDescription.assert(equal: completeInfoDebugDescription)
        XCTAssertEqual(json.code, 200)
        XCTAssertEqual(json.data.count, 1)

        photoJson.description.assert(equal: "PhotoJSON: 3210 profile_img")
        photoJson.debugDescription.assert(equal: completeInfoFirstDebugDescription)

        XCTAssertEqual(sut.desc, "Salt workers")
        XCTAssertEqual(sut.locationId, 554)
        XCTAssertEqual(sut.photoId, 3_210)
        XCTAssertEqual(sut.userId, 4_089)
        XCTAssertEqual(sut.uuid, "6uMTYDtfMXxLWVEj4JaTnC")
        XCTAssertEqual(sut.imageUrl, expectedImage)
        XCTAssertEqual(sut.attributedTitle, expectedTitle)
    }

    func testDecodingPageInfo() throws {
        // given
        let userId = 999_999
        let realm = RealmDataController()
        let data = try unwrap(completePageInfo.data(using: .utf8))

        // when
        let json = try JSONDecoder.mtp.decode(PhotosPageInfoJSON.self,
                                              from: data)
        realm.set(photos: 1, user: userId, info: json)
        let photoJson = json.data[0]
        let sut = Photo(from: photoJson)

        // then
        json.description.assert(equal: "PhotosPageInfoJSON: 1")
        json.debugDescription.assert(equal: completePageInfoDebugDescription)
        XCTAssertEqual(json.code, 200)
        XCTAssertEqual(json.data.count, 1)
        XCTAssertEqual(json.paging.perPage, 25)
        json.paging.description.assert(equal: "PhotosPageJSON: 1 1")
        json.paging.debugDescription.assert(equal: completePageInfoPagingDebugDescription)

        photoJson.description.assert(equal: "PhotoJSON: 66806 ")
        photoJson.debugDescription.assert(equal: completePageInfoFirstDebugDescription)

        XCTAssertTrue(sut.desc.isEmpty)
        XCTAssertEqual(sut.photoId, 66_806)
        XCTAssertEqual(sut.userId, 7_853)
        XCTAssertNil(sut.imageUrl)
        XCTAssertNil(sut.attributedTitle)
    }

    func testCompleteDecodingReply() throws {
        // given
        let data = try unwrap(completeUpload.data(using: .utf8))

        // when
        let json = try JSONDecoder.mtp.decode(PhotoReply.self,
                                              from: data)
        let sut = Photo(from: json)

        // then
        json.description.assert(equal: "photo 67211 - ybfmMqxCCnpQY2UF7ZRpL")
        json.debugDescription.assert(equal: completeUploadDebugDescription)

        XCTAssertEqual(sut.photoId, 67_211)
        XCTAssertEqual(sut.userId, 7_853)
    }

    func testIncompleteDecodingReply() throws {
        // given
        let data = try unwrap(incompleteUpload.data(using: .utf8))

        // when
        let json = try JSONDecoder.mtp.decode(PhotoReply.self,
                                              from: data)
        let sut = Photo(from: json)

        // then
        json.description.assert(equal: "photo 67211 - ybfmMqxCCnpQY2UF7ZRpL")
        json.debugDescription.assert(equal: incompleteUploadDebugDescription)

        XCTAssertEqual(sut.photoId, 67_211)
        XCTAssertEqual(sut.userId, 7_853)
    }
}

private let completeInfo = """
{
"code": 200,
"data": [
{
"id": 3210,
"uuid": "6uMTYDtfMXxLWVEj4JaTnC",
"name": "profile_img",
"desc": "Salt workers",
"type": "image",
"mime": "image/jpeg",
"user_id": 4089,
"location_id": 554,
"created_at": "2018-09-06 09:49:18",
"updated_at": "2018-09-06 09:49:18",
"location": {
"id": 554,
"Location": "Thailand",
"RegionIDnew": 12,
"CountryId": 179,
"RegionName": "Asia",
"Country": "Thailand",
"weather": "global/stations/48456",
"weatherhist": "65484",
"active": "Y",
"latitude": "-13.15",
"longitude": "101.1",
"lat": 15.870032,
"lon": 100.992541,
"distance": 520,
"dateUpdated": "2018-08-02 14:48:00",
"zoom": 5,
"region_id": 983,
"country_id": 554,
"region_name": "Asia",
"country_name": "Thailand",
"location_name": "Thailand",
"is_un": 1,
"is_mtp_location": 1,
"admin_level": 2,
"featured_img": "13UZEYS9ZaX2oSsJxMTXJd",
"airports": "BKK, DMK",
"visitors": 10498,
"rank": 877,
"visitors_un": 10498,
"rank_un": 175
},
"owner": {
"id": 4089,
"first_name": "Aino",
"last_name": "Ilkkala",
"full_name": "Aino Ilkkala",
"country": null,
"location": null,
"role": 2
}
}
]
}
"""

private let completeInfoDebugDescription = """
< PhotosInfoJSON: PhotosInfoJSON (1):
code: 200
data: [\(completeInfoFirstDebugDescription)])
/PhotosInfoJSON >
"""

private let completeInfoFirstDebugDescription = """
< PhotoJSON: PhotoJSON: 3210 profile_img:
createdAt: 2018-09-06 09:49:18 +0000
desc: Optional("Salt workers")
id: 3210
location: Optional(< LocationJSON: Thailand:
active: Y
admin_level: 2
airports: Optional("BKK, DMK")
countryId: Optional(554)
countryName: Thailand
distance: Optional(520.0)
featuredImg: Optional("13UZEYS9ZaX2oSsJxMTXJd")
id: 554
is_mtp_location: 1
is_un: 1
lat: Optional(15.870032)
location_name: Thailand
lon: Optional(100.992541)
rank: 877
rankUn: 175
region_id: 983
region_name: Asia
visitors: 10498
visitorsUn: 10498
weather: Optional("global/stations/48456")
weatherhist: Optional("65484")
zoom: Optional(5)
/LocationJSON >)
locationId: Optional(554)
mime: image/jpeg
name: profile_img
type: image
updatedAt: 2018-09-06 09:49:18 +0000
userId: 4089
uuid: 6uMTYDtfMXxLWVEj4JaTnC
/PhotoJSON >
"""

private let completePageInfo = """
{
"code": 200,
"data": [
{
"id": 66806,
"uuid": "",
"name": "",
"type": "image",
"mime": "image/jpeg",
"user_id": 7853,
"created_at": "2019-07-29 13:09:34",
"updated_at": "2019-07-29 13:09:34",
"pivot": {
"user_id": 7853,
"file_id": 66806
}
}
],
"paging": {
"current_page": 1,
"per_page": 25,
"last_page": 1,
"total": 23,
"links": {}
}
}
"""

private let completePageInfoDebugDescription = """
< PhotosPageInfoJSON: PhotosPageInfoJSON: 1:
code: 200
paging: \(completePageInfoPagingDebugDescription)
data: [\(completePageInfoFirstDebugDescription)]
/PhotosPageInfoJSON >
"""

private let completePageInfoPagingDebugDescription = """
< PhotosPageJSON: PhotosPageJSON: 1 1:
currentPage: 1
lastPage: 1
perPage: 25
total: 23
/PhotosPageJSON >
"""

private let completePageInfoFirstDebugDescription = """
< PhotoJSON: PhotoJSON: 66806 :
createdAt: 2019-07-29 13:09:34 +0000
desc: nil
id: 66806
location: nil
locationId: nil
mime: image/jpeg
name: empty
type: image
updatedAt: 2019-07-29 13:09:34 +0000
userId: 7853
uuid: empty
/PhotoJSON >
"""

private let completeUpload = """
{
"name":"test",
"uuid":"ybfmMqxCCnpQY2UF7ZRpL",
"mime":"image/jpeg",
"type":"image",
"user_id":7853,
"uploaded":1,
"url":"/api/files/preview?uuid=ybfmMqxCCnpQY2UF7ZRpL",
"location":{
"id":554,
"Location":"Thailand",
"RegionIDnew":12,
"CountryId":179,
"RegionName":"Asia",
"Country":"Thailand",
"weather":"global/stations/48456",
"weatherhist":"65484",
"active":"Y",
"latitude":"-13.15",
"longitude":"101.1",
"lat":15.870032,
"lon":100.992541,
"distance":520,
"dateUpdated":"2018-08-02 14:48:00",
"zoom":5,
"region_id":983,
"country_id":554,
"region_name":"Asia",
"country_name":"Thailand",
"location_name":"Thailand",
"is_un":1,
"is_mtp_location":1,
"admin_level":2,
"featured_img":"13UZEYS9ZaX2oSsJxMTXJd",
"airports":"BKK, DMK",
"visitors":10548,
"rank":877,
"visitors_un":10548,
"rank_un":175
},
"location_id":554,
"desc":"The Golden Buddha in Bangkok is very golden",
"id":67211
}
"""

let completeUploadDebugDescription = """
< PhotoReply: photo 67211 - ybfmMqxCCnpQY2UF7ZRpL:
desc: Optional("The Golden Buddha in Bangkok is very golden")
id: 67211
location: Optional(< LocationJSON: Thailand:
active: Y
admin_level: 2
airports: Optional("BKK, DMK")
countryId: Optional(554)
countryName: Thailand
distance: Optional(520.0)
featuredImg: Optional("13UZEYS9ZaX2oSsJxMTXJd")
id: 554
is_mtp_location: 1
is_un: 1
lat: Optional(15.870032)
location_name: Thailand
lon: Optional(100.992541)
rank: 877
rankUn: 175
region_id: 983
region_name: Asia
visitors: 10548
visitorsUn: 10548
weather: Optional("global/stations/48456")
weatherhist: Optional("65484")
zoom: Optional(5)
/LocationJSON >)
locationId: Optional(MTP.UncertainValue<Swift.Int, Swift.String>(tValue: Optional(554), uValue: nil))
mime: image/jpeg
name: test
type: image
uploaded: 1
url: /api/files/preview?uuid=ybfmMqxCCnpQY2UF7ZRpL
userId: 7853
uuid: ybfmMqxCCnpQY2UF7ZRpL
/PhotoReply >
"""

private let incompleteUpload = """
{
"name":"",
"uuid":"ybfmMqxCCnpQY2UF7ZRpL",
"mime":"image/jpeg",
"type":"image",
"user_id":7853,
"uploaded":1,
"url":"/api/files/preview?uuid=ybfmMqxCCnpQY2UF7ZRpL",
"id":67211
}
"""

let incompleteUploadDebugDescription = """
< PhotoReply: photo 67211 - ybfmMqxCCnpQY2UF7ZRpL:
desc: nil
id: 67211
location: nil
locationId: nil
mime: image/jpeg
name: empty
type: image
uploaded: 1
url: /api/files/preview?uuid=ybfmMqxCCnpQY2UF7ZRpL
userId: 7853
uuid: ybfmMqxCCnpQY2UF7ZRpL
/PhotoReply >
"""
