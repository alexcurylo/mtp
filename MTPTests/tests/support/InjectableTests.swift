// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class InjectableTests: TestCase {

    func testUnwrapFailure() throws {
        // given
        let testOptional: String? = nil
        let testClosure: () -> Int? = { nil }
        let expected = "failed to unwrap String at line 15 in file InjectableTests.swift"

        // then
        XCTAssertThrowsError(try unwrap(testOptional)) { error in
            let sut = error as? UnwrapError<String>
            XCTAssertEqual(sut?.errorDescription, expected)
        }
        XCTAssertThrowsError(try unwrap(testClosure())) { error in
            XCTAssertNotNil(error as? UnwrapError<Int>)
        }
    }

    func testUnwrapSuccess() {
        // given
        let testObject: AnyObject = UIView()
        let testOptional: String? = "test"
        let testClosure: () -> Int? = { 42 }

        // then
        XCTAssertNoThrow(try unwrap(testObject))
        XCTAssertNoThrow(try unwrap(testOptional))
        XCTAssertNoThrow(try unwrap(testClosure()))
    }

    func testRequire() {
        // given
        let emptyString: String? = ""
        let nilString: String? = nil

        // when
        emptyString.require()
        var reached = false
        var passed = false
        let exception = catchBadInstruction {
            reached = true
            nilString.require()
            passed = true
        }
        XCTAssertNotNil(exception)
        XCTAssertTrue(reached)
        XCTAssertFalse(passed)
    }

    func testIsNilOrEmpty() {
        // given
        let nilString: String? = nil
        let emptyString: String? = ""
        let string: String? = "test"
        // swiftlint:disable discouraged_optional_collection
        let nilArray: [Int]? = nil
        let emptyArray: [Int]? = []
        let array: [Int]? = [3]

        // then
        XCTAssertTrue(nilString.isNilOrEmpty)
        XCTAssertTrue(emptyString.isNilOrEmpty)
        XCTAssertFalse(string.isNilOrEmpty)
        XCTAssertTrue(nilArray.isNilOrEmpty)
        XCTAssertTrue(emptyArray.isNilOrEmpty)
        XCTAssertFalse(array.isNilOrEmpty)
    }
}
