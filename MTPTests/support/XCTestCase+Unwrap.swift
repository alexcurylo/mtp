// @copyright Trollwerks Inc.

import XCTest

extension XCTestCase {

    struct UnwrapError<T>: LocalizedError {

        let file: StaticString
        let line: UInt
        var errorDescription: String? {
            return "failed to unwrap \(T.self) at line \(line) in file \(file)."
        }
    }

    func unwrap<T>(_ optional: @autoclosure () -> T?,
                   file: StaticString = #file,
                   line: UInt = #line) throws -> T {
        guard let value = optional() else {
            throw UnwrapError<T>(file: file, line: line)
        }
        return value
    }
}

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
