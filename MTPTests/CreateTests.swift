// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class CreateTests: XCTestCase {

    func testCreate() {
        let expected: UIView = {
            let expected = UIView()
            expected.alpha = 0.42
            expected.backgroundColor = .green
            expected.tintColor = .red
            return expected
        }()

        let named: UIView = create { named in
            named.alpha = 0.42
            named.backgroundColor = .green
            named.tintColor = .red
        }
        let anonymous: UIView = create {
            $0.alpha = 0.42
            $0.backgroundColor = .green
            $0.tintColor = .red
        }
        let function: UIView = create(then: configure)

        [named, anonymous, function].forEach { actual in
            XCTAssertEqual(expected.alpha, actual.alpha)
            XCTAssertEqual(expected.backgroundColor, actual.backgroundColor)
            XCTAssertEqual(expected.tintColor, actual.tintColor)
        }
    }
}

private extension CreateTests {

    func configure(view: UIView) {
        view.alpha = 0.42
        view.backgroundColor = .green
        view.tintColor = .red
    }
}
