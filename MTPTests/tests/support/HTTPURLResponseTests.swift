// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class HTTPURLResponseTests: TestCase {

    func testHasField() throws {
        // given
        let sut = try XCTUnwrap(HTTPURLResponseMock())

        // when
        let result = sut.find(header: HTTPURLResponseMock.key)

        // then
        result?.assert(equal: HTTPURLResponseMock.value)
    }

    func testNotHasField() throws {
        // given
        let sut = try XCTUnwrap(HTTPURLResponseMock())

        // when
        let result = sut.find(header: "not-here")

        // then
        XCTAssertNil(result)
    }
}

private class HTTPURLResponseMock: HTTPURLResponse {

    static let key = "key"
    static let value = "value"

    override var allHeaderFields: [AnyHashable: Any] {
        [HTTPURLResponseMock.key: HTTPURLResponseMock.value]
    }

    init() {
        // swiftlint:disable:next force_try
        let url = try! unwrap(URL(string: "https://mtp.travel"))
        // swiftlint:disable:next empty_line_after_super
        super.init(url: url,
                   statusCode: 200,
                   httpVersion: nil,
                   // swiftlint:disable:next force_unwrapping
                   headerFields: [:])!
    }

    required init?(coder aDecoder: NSCoder) { nil }
}
