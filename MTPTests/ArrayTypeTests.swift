// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class ArrayTypeTests: XCTestCase {

    func testTypeRefining() {
        let numbers = [ 1, 2, 3 ]
        let strings = [ "4", "5", "6" ]
        let mixed: [Any] = numbers as [Any] + strings as [Any]

        XCTAssertEqual(numbers, mixed.of(type: Int.self))
        XCTAssertEqual(strings, mixed.of(type: String.self))
        XCTAssertEqual([], mixed.of(type: UIViewController.self))

        XCTAssertEqual(numbers.firstOf(type: Int.self), 1)
        XCTAssertNil(numbers.firstOf(type: String.self))
    }
}
