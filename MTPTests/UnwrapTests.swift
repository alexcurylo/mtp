// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class UnwrapTests: XCTestCase {

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

    func testUnwrapFailure() {
        // given
        let testOptional: String? = nil
        let testClosure: () -> Int? = { nil }

        // then
        XCTAssertThrowsError(try unwrap(testOptional)) { error in
            XCTAssertNotNil(error as? UnwrapError<String>)
        }
        XCTAssertThrowsError(try unwrap(testClosure())) { error in
            XCTAssertNotNil(error as? UnwrapError<Int>)
        }
    }
}
