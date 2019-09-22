// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class FaqJSONTests: MTPTestCase {

    func testDescription() {
        // given
        let sut = FaqJSON(id: 0,
                          title: "title",
                          category: 0,
                          status: "placeholder",
                          slug: "placeholder",
                          content: "content",
                          featuredImg: "placeholder",
                          createdAt: "placeholder",
                          updatedAt: "placeholder",
                          headerImg: "placeholder")
        let expected = """
                       < Faq: Faq:
                       title: title)
                       content: content
                       /FaqJSON >
                       """

        // then
        sut.description.assert(equal: "Faq")
        sut.debugDescription.assert(equal: expected)
    }
}
