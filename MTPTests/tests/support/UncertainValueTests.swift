// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class UncertainValueTests: XCTestCase {

    func testUncertainIntValue() {
        // given
        let sut: UncertainValue<Int, String>?

        // when
        sut = UncertainValue(with: 3)

        // then
        XCTAssertEqual(sut?.tValue, 3)
        XCTAssertNil(sut?.uValue)
        XCTAssertEqual(sut?.intValue, 3)
        XCTAssertEqual(sut?.doubleValue, 3)
    }

    func testUncertainDoubleValue() {
        // given
        let sut: UncertainValue<Double, [Int]>?

        // when
        sut = UncertainValue(with: 3.33)

        // then
        XCTAssertEqual(sut?.tValue, 3.33)
        XCTAssertNil(sut?.uValue)
        XCTAssertNil(sut?.intValue)
        XCTAssertEqual(sut?.doubleValue, 3.33)
    }

    func testUncertainStringValue() {
        // given
        let sut: UncertainValue<Int, String>?

        // when
        sut = UncertainValue(with: "33")

        // then
        XCTAssertNil(sut?.tValue)
        XCTAssertEqual(sut?.uValue, "33")
        XCTAssertEqual(sut?.intValue, 33)
        XCTAssertEqual(sut?.doubleValue, 33)
    }

    func testUncertainArrayValue() {
        // given
        let sut: UncertainValue<[Int], [String]>?

        // when
        sut = UncertainValue(with: ["A"])

        // then
        XCTAssertNil(sut?.tValue)
        XCTAssertEqual(sut?.uValue, ["A"])
        XCTAssertNil(sut?.intValue)
        XCTAssertNil(sut?.doubleValue)
    }

    func testUncertainIntCoding() throws {
        // given
        struct SUT: Codable {
            let value: UncertainValue<Int, String>
        }
        let fixture = Data(#"{"value":3}"#.utf8)

        // when
        let sut = try JSONDecoder().decode(SUT.self,
                                           from: fixture)
        let encoded = try JSONEncoder().encode(sut)

        // then
        XCTAssertEqual(sut.value.tValue, 3)
        XCTAssertNil(sut.value.uValue)
        XCTAssertEqual(sut.value.intValue, 3)
        XCTAssertEqual(sut.value.doubleValue, 3)
        XCTAssertEqual(fixture, encoded)
    }

    func testUncertainStringCoding() throws {
        // given
        struct SUT: Codable {
            let value: UncertainValue<Int, String>
        }
        let fixture = Data(#"{"value":"33"}"#.utf8)

        // when
        let sut = try JSONDecoder().decode(SUT.self,
                                           from: fixture)
        let encoded = try JSONEncoder().encode(sut)

        // then
        XCTAssertNil(sut.value.tValue)
        XCTAssertEqual(sut.value.uValue, "33")
        XCTAssertEqual(sut.value.intValue, 33)
        XCTAssertEqual(sut.value.doubleValue, 33)
        XCTAssertEqual(fixture, encoded)
    }

    func testUncertainDecodingWrong() throws {
        // given
        struct SUT: Codable {
            let value: UncertainValue<Int, String>
        }
        let fixture = Data(#"{"value":["not":"valid"]}"#.utf8)

        // when
        let sut = try? JSONDecoder().decode(SUT.self,
                                            from: fixture)

        // then
        XCTAssertNil(sut)
    }

    func testUncertainDecodingNull() throws {
        // given
        struct SUT: Codable {
            let value: UncertainValue<Int, String>
        }
        let fixture = Data(#"{"value":null}"#.utf8)

        // when
        let sut = try JSONDecoder().decode(SUT.self,
                                           from: fixture)

        // then
        XCTAssertNil(sut.value.tValue)
        XCTAssertNil(sut.value.uValue)
    }

    func testJSONNullCoding() throws {
        // given
        struct SUT: Codable {
            let value: JSONNull
        }
        let fixture = Data(#"{"value":null}"#.utf8)

        // when
        let sut = try JSONDecoder().decode(SUT.self,
                                           from: fixture)
        let encoded = try JSONEncoder().encode(sut)

        // then
        XCTAssertNotNil(sut)
        XCTAssertEqual(fixture, encoded)
    }

    func testJSONNullDecodingFail() throws {
        // given
        struct SUT: Codable {
            let value: JSONNull
        }
        let fixture = Data(#"{"value":"not null"}"#.utf8)

        // when
        let sut = try? JSONDecoder().decode(SUT.self,
                                            from: fixture)

        // then
        XCTAssertNil(sut)
    }
}
