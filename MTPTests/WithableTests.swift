// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class WithableTests: XCTestCase {

    func testWithable() {
        let expected = UIView()
        expected.alpha = 0.42
        expected.backgroundColor = .green
        expected.tintColor = .red

        let construct = UIView {
            $0.alpha = 0.42
            $0.backgroundColor = .green
            $0.tintColor = .red
        }
        let copy = UIView().with {
            $0.alpha = 0.42
            $0.backgroundColor = .green
            $0.tintColor = .red
        }
        let nothing: UIView? = nil
        let optional = nothing.with {
            $0.alpha = 0.42
            $0.backgroundColor = .green
            $0.tintColor = .red
        }

        [construct, copy, optional].forEach { actual in
            XCTAssertEqual(expected.alpha, actual.alpha)
            XCTAssertEqual(expected.backgroundColor, actual.backgroundColor)
            XCTAssertEqual(expected.tintColor, actual.tintColor)
        }
    }
}
