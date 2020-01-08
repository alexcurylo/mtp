// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class RankingsPageInfoTests: TestCase {

    func testDecodingComplete() throws {
        // given
        let realm = RealmDataController()
        let data = try XCTUnwrap(complete.data(using: .utf8))
        let query = RankingsQuery().with(page: 99_999)

        // when
        let info = try JSONDecoder.mtp.decode(RankingsPageInfoJSON.self,
                                              from: data)
        realm.set(rankings: query, info: info)
        let page = info.users
        let sut = RankingsPageInfo(query: query, info: info)
        sut.stamp()
        let userJson = try XCTUnwrap(page.data[0])
        let user = User(from: userJson, with: nil)

        // then
        info.description.assert(equal: "RankingsPageInfoJSON: 50 649")
        info.debugDescription.assert(equal: infoDebugDescription)

        page.description.assert(equal: "RankingsPageJSON: 1 505")
        page.debugDescription.assert(equal: pageDebugDescription)

        userJson.description.assert(equal: "RankedUserJSON: 1 Fred Flintstone")
        userJson.debugDescription.assert(equal: userDebugDescription)

        XCTAssertFalse(sut.expired)
        user.fullName.assert(equal: "Fred Flintstone")
    }
}

private let complete = """
{
"max_score": 891,
"end_rank": 50,
"end_score": 649,
"users": {
"current_page": 1,
"data": [
{
"id": 3218,
"first_name": "Fred",
"last_name": "Flintstone",
"birthday": "1937-06-04",
"gender": "M",
"picture": "3V9ixGSBAMBnZ2dee8vhcM",
"current_rank": 1,
"full_name": "Fred Flintstone" ,
"country": null,
"role": 2
}
],
"first_page_url": "/rankings/?page=1",
"from": 1,
"last_page": 505,
"last_page_url": "/rankings/?page=505",
"next_page_url": "/rankings/?page=2",
"path": "/rankings/",
"per_page": 50,
"prev_page_url": null,
"to": 50,
"total": 25249
}
}
"""

private let infoDebugDescription = """
< RankingsPageInfoJSON: RankingsPageInfoJSON: 50 649:
endRank: 50
endScore: 649
maxScore: 891
users: \(pageDebugDescription)
/RankingsPageInfoJSON >
"""

private let pageDebugDescription = """
< RankingsPageJSON: RankingsPageJSON: 1 505:
currentPage: 1
data: [\(userDebugDescription)]
firstPageUrl: /rankings/?page=1
from: Optional(1)
lastPage: 505
lastPageUrl: /rankings/?page=505
nextPageUrl: Optional("/rankings/?page=2")
path: /rankings/
perPage: 50
prevPageUrl: nil
to: Optional(50)
total: 25249
/RankingsPageJSON >
"""

private let userDebugDescription = """
< RankedUserJSON: RankedUserJSON: 1 Fred Flintstone:
birthday: Optional(1937-06-04 00:00:00 +0000)
country: nil
currentRank: 1
first_name: Fred
full_name: Fred Flintstone
gender: M
id: 3218
last_name: Flintstone
location: nil
location_id: nil
picture: Optional("3V9ixGSBAMBnZ2dee8vhcM")
rankBeaches: nil
rankDivesites: nil
rankGolfcourses: nil
rankHotels: nil
rankLocations: nil
rankRestaurants: nil
rankUncountries: nil
rankWhss: nil
scoreBeaches: nil
scoreDivesites: nil
scoreGolfcourses: nil
scoreHotels: nil
scoreLocations: nil
scoreRestaurants: nil
scoreUncountries: nil
scoreWhss: nil
/RankedUserJSON >
"""
