// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class ViewTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testGradients() {
        XCTAssertNil(GradientOrientation(rawValue: -1))
        XCTAssertEqual(GradientOrientation(rawValue: 0), .topRightBottomLeft)
        XCTAssertEqual(GradientOrientation(rawValue: 1), .topLeftBottomRight)
        XCTAssertEqual(GradientOrientation(rawValue: 2), .horizontal)
        XCTAssertEqual(GradientOrientation(rawValue: 3), .vertical)
        XCTAssertNil(GradientOrientation(rawValue: 4))
    }
}
