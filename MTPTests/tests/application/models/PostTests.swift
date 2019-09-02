// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class PostTests: XCTestCase {

    func testDecodingPosts() throws {
        // given
        let realm = RealmDataController()
        let data = try unwrap(complete.data(using: .utf8))

        // when
        let json = try JSONDecoder.mtp.decode(PostsJSON.self,
                                              from: data)
        realm.set(posts: json.data)
        let postJson = json.data[0]
        let sut = try unwrap(Post(from: postJson))

        // then
        json.description.assert(equal: "PostsJSON (1)")
        json.debugDescription.assert(equal: completeDebugDescription)
        XCTAssertEqual(json.code, 200)
        XCTAssertEqual(json.data.count, 1)

        postJson.description.assert(equal: "PostJSON: 9999, 7053")
        postJson.debugDescription.assert(equal: completeFirstDebugDescription)

        XCTAssertEqual(sut.locationId, 9_999)
        XCTAssertEqual(sut.postId, 7_053)
        XCTAssertEqual(sut.userId, 42_628)
    }

    func testIncompleteDecodingReply() throws {
        // given
        let data = try unwrap(incomplete.data(using: .utf8))

        // when
        let json = try JSONDecoder.mtp.decode(PostJSON.self,
                                              from: data)
        let sut = Post(from: json)

        // then
        XCTAssertNil(sut)
    }
}

private let complete = """
{
"code": 200,
"data": [
{
"id": 7053,
"location_id": 9999,
"user_id": 42628,
"post": "Traveled to Phuket and Bangcok december 2017",
"created_at": "2019-05-11 23:03:27",
"updated_at": "2019-05-11 23:03:27",
"status": "A",
"location": {
"id": 554,
"location_name": "Thailand",
"region_id": 983,
"region_name": "Asia",
"country_id": 554,
"country_name": "Thailand"
},
"owner": {
"id": 42628,
"first_name": "Annaliese",
"last_name": "Park",
"full_name": "Annaliese Park",
"country": null,
"location": null,
"role": 2
}
}
]
}
"""

private let completeDebugDescription = """
< PostsJSON: PostsJSON (1):
code: 200
paging: nil
data: [\(completeFirstDebugDescription)]
/PostsJSON >
"""

private let completeFirstDebugDescription = """
< PostJSON: PostJSON: 9999, 7053:
createdAt: 2019-05-11 23:03:27 +0000
id: 7053
location: Thailand (554)
locationId: 9999
post: Optional("Traveled to Phuket and Bangcok december 2017")
status: A
updatedAt: 2019-05-11 23:03:27 +0000
owner: Optional(MTP.OwnerJSON(firstName: "Annaliese", fullName: "Annaliese Park", id: 42628, lastName: "Park", role: 2))
userId: 42628
/PostJSON >
"""

private let incomplete = """
{
"id": 7053,
"location_id": 9999,
"user_id": 42628,
"post": "Traveled to Phuket and Bangcok december 2017",
"created_at": "2019-05-11 23:03:27",
"updated_at": "2019-05-11 23:03:27",
"status": "D",
"location": {
"id": 554,
"location_name": "Thailand",
"region_id": 983,
"region_name": "Asia",
"country_id": 554,
"country_name": "Thailand"
}
}
"""