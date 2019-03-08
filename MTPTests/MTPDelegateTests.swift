// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class MTPDelegateTests: XCTestCase {

    // Verify optimal unit testing delegate configuration
    func testRuntimeExistenceWithCorrectHandlers() {
        let delegate = UIApplication.shared.delegate as? MTPDelegate
        XCTAssertNotNil(delegate)

        let expected: [String] = [
            String(describing: SpyServiceHandler.self)
        ]
        let actual = delegate?.handlers.map { String(describing: type(of: $0)) } ?? []
        XCTAssertEqual(expected, actual)
    }

    func testDeploymentHandlerList() {
        let expected = [
            String(describing: ActionHandler.self),
            String(describing: LaunchHandler.self)
        ]
        let actual = MTPDelegate.runtimeHandlers(forUnitTests: false)
                                .map { String(describing: type(of: $0)) }
        XCTAssertEqual(expected, actual)
    }
}
