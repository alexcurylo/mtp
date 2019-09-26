// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class SearchResultJSONTests: MTPTestCase {

    func testDecodingResults() throws {
        // given
        let data = try unwrap(completeResults.data(using: .utf8))

        // when
        let json = try JSONDecoder.mtp.decode(SearchResultJSON.self,
                                              from: data)
        let itemJson = json.data[0]
        let sut = User(from: itemJson)

        // then
        json.description.assert(equal: "SearchResultJSON: Fred")
        json.debugDescription.assert(equal: completeResultsDebugDescription)
        XCTAssertEqual(json.request.query, "Fred")
        XCTAssertEqual(json.data.count, 1)
        XCTAssertTrue(itemJson.isUser)
        XCTAssertFalse(itemJson.isLocation)

        itemJson.description.assert(equal: "SearchResultItemJSON 707")
        itemJson.debugDescription.assert(equal: completeResultsFirstDebugDescription)

        XCTAssertEqual(sut.fullName, "Alfredo Chen")
        XCTAssertEqual(sut.userId, 707)
    }
}

private let completeResults = """
{
"request": {
"query": "Fred"
},
"data": [
{
"id": 707,
"first_name": "Alfredo",
"last_name": "Chen",
"type": "users",
"label": "Alfredo Chen",
"link": "/users/707",
"full_name": "Alfredo Chen",
"country": null,
"location": null,
"role": 2
}
]
}
"""

private let completeResultsDebugDescription = """
< SearchResultJSON: Fred:
data: [\(completeResultsFirstDebugDescription)]
/SearchResultJSON >
"""

private let completeResultsFirstDebugDescription = """
< SearchResultItemJSON: SearchResultItemJSON 707:
country: nil
firstName: Optional("Alfredo")
fullName: Optional("Alfredo Chen")
id: 707
label: Alfredo Chen
lastName: Optional("Chen")
link: /users/707
location: nil
locationName: nil
role: Optional(2)
type: users
/SearchResultItemJSON >
"""
