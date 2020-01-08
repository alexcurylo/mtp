// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class ArrayTests: TestCase {

    func testTypeRefining() {
        // given
        let numbers = [ 1, 2, 3 ]
        let strings = [ "4", "5", "6" ]

        // when
        let sut: [Any] = numbers as [Any] + strings as [Any]

        // then
        XCTAssertEqual(numbers, sut.of(type: Int.self))
        XCTAssertEqual(strings, sut.of(type: String.self))
        XCTAssertEqual([], sut.of(type: UIViewController.self))
        XCTAssertEqual(numbers.firstOf(type: Int.self), 1)
        XCTAssertNil(numbers.firstOf(type: String.self))
    }

    func testInsertionIndex() {
        // given
        let sut = [ 2, 4, 6 ]

        // when
        let one = sut.insertionIndex(of: 1) { $0 < $1 }
        let four = sut.insertionIndex(of: 4) { $0 < $1 }
        let seven = sut.insertionIndex(of: 7) { $0 < $1 }

        // then
        XCTAssertEqual(0, one.index)
        XCTAssertFalse(one.alreadyExists)
        XCTAssertEqual(1, four.index)
        XCTAssertTrue(four.alreadyExists)
        XCTAssertEqual(3, seven.index)
        XCTAssertFalse(seven.alreadyExists)
    }

    func testEmptyInsertionIndex() {
        // given
        let sut: [Int] = []

        // when
        let one = sut.insertionIndex(of: 1) { $0 < $1 }

        // then
        XCTAssertEqual(0, one.index)
        XCTAssertFalse(one.alreadyExists)
    }

    func testSetExtraction() throws {
        // given
        let numbers: [AnyHashable] = [ 1, 2, 3 ]
        let strings: [AnyHashable] = [ "4", "5", "6" ]

        // when
        let sut = Set<AnyHashable>(numbers + strings)
        let sortedNumbers = sut.of(type: Int.self).sorted()
        let sortedStrings = sut.of(type: String.self).sorted()

        // then
        XCTAssertEqual(numbers, sortedNumbers)
        XCTAssertEqual(strings, sortedStrings)
    }
}
