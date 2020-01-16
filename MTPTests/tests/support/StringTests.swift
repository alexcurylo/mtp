// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class StringTests: TestCase {

    func testFile() {
        // given
        let path = "some/long/path/file.txt"
        let file = "file.pdf"
        let empty = ""

        // then
        XCTAssertEqual("file.txt", path.file)
        XCTAssertEqual("file.pdf", file.file)
        XCTAssertEqual("", empty.file)
    }

    func testError() {
        // given
        let error: LocalizedError = "test error"

        // then
        XCTAssertEqual("test error", error.errorDescription)
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

    func testNamable() throws {
        // given
        let expected = "Array<String>"
        let sut = ["test"]

        // when
        let classType = [String].typeName
        let instanceType = sut.typeName

        // then
        classType.assert(equal: expected)
        instanceType.assert(equal: expected)
    }

    func testTrimmed() {
        // given
        [
            ("plain", "plain"),
            (" front and back ", "front and back"),
            ("     ", ""),
            ("✅start", "✅start"),
            ("end™️", "end™️"),
            ("🔔both💤", "🔔both💤")
        ].forEach { text, result in
            // when
            let sut = NSMutableAttributedString(string: text)
            let expected = NSMutableAttributedString(string: result)
            let actual = sut.trimmed

            // then
            XCTAssertEqual(actual, expected)
        }
    }
}
