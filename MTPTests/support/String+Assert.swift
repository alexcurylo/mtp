// @copyright Trollwerks Inc.

import XCTest

/// - Parameters:
///   - expected: expression producing String?
///   - actual: expression producing String?
func XCTAssertContainsString(_ container: @autoclosure () -> Any?,
                             _ content: @autoclosure () -> Any?) {
    let container = container() as? String ?? ""
    let content = content() as? String ?? ""
    let output = "container “\(container)” did not contain “\(content)”"
    XCTAssertTrue(container.contains(content), output)
}

/// - Parameters:
///   - expected: expression producing String?
///   - actual: expression producing String?
func XCTAssertEqualStrings(_ expected: @autoclosure () -> Any?,
                           _ actual: @autoclosure () -> Any?) {
    let expected = expected() as? String ?? ""
    let actual = actual() as? String ?? ""
    let output = "expected “\(expected)” but got “\(actual)”"
    XCTAssertEqual(expected, actual, output)
}

/// - Parameters:
///   - expected: expression producing String?
///   - actual: expression producing String?
func XCTAssertNotEqualStrings(_ expected: @autoclosure () -> Any?,
                              _ actual: @autoclosure () -> Any?) {
    let expected = expected() as? String ?? ""
    let actual = actual() as? String ?? ""
    let output = "unexpectedly identical: “\(expected)”"
    XCTAssertNotEqual(expected, actual, output)
}

extension String {

    enum State {
        case empty
        case notEmpty
    }

    func assert(_ state: State) {
        switch state {
        case .empty:
            XCTAssertEqualStrings("", self)
        case .notEmpty:
            XCTAssertNotEqualStrings("", self)
        }
    }

    func assert(contains content: @autoclosure () -> Any?) {
        XCTAssertContainsString(self, content)
    }

    func assert(equal: @autoclosure () -> Any?) {
        XCTAssertEqualStrings(self, equal)
    }

    func assert(notEqual: @autoclosure () -> Any?) {
        XCTAssertNotEqualStrings(self, notEqual)
    }
}
