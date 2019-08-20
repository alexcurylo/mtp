// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class SearchResultJSONTests: XCTestCase {

    func testDescription() {
        // given
        let request = SearchResultJSON.Request(query: "query")
        let sut = SearchResultJSON(request: request, data: [])
        let expected = """
                       < SearchResultJSON: query:
                       data: []
                       /SearchResultJSON >
                       """

        // then
        sut.description.assert(equal: "SearchResultJSON: query")
        sut.debugDescription.assert(equal: expected)
    }
}
