// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class StringTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testHiddenName() {
        XCTAssertEqual("", "".hiddenName)
        XCTAssertEqual("test", "test".hiddenName)
        XCTAssertEqual("@test.com", "@test.com".hiddenName)
        XCTAssertEqual("a@test.com", "a@test.com".hiddenName)
        XCTAssertEqual("ab@.test.com", "ab@.test.com".hiddenName)
        XCTAssertEqual("a*c@test.com", "abc@test.com".hiddenName)
        XCTAssertEqual("w******r@test.com", "whatever@test.com".hiddenName)
        XCTAssertEqual("w******r@test@wrong.com", "whatever@test@wrong.com".hiddenName)
    }
}
