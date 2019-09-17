// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class HTTPURLResponseTests: MTPTestCase {

    func testHasField() throws {
        // given
        let sut = try unwrap(HTTPURLResponseMock())

        // when
        let result = sut.find(header: HTTPURLResponseMock.key)

        // then
        result?.assert(equal: HTTPURLResponseMock.value)
    }

    func testNotHasField() throws {
        // given
        let sut = try unwrap(HTTPURLResponseMock())

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
        return [HTTPURLResponseMock.key: HTTPURLResponseMock.value]
    }

    init() {
        // swiftlint:disable:next force_try
        let url = try! unwrap(URL(string: "https://mtp.travel"))
        super.init(url: url,
                   statusCode: 200,
                   httpVersion: nil,
                   // swiftlint:disable:next force_unwrapping
                   headerFields: [:])!
    }

    // swiftlint:disable:next unavailable_function
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
