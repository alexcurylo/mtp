// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class MTPDelegateTests: XCTestCase {

    func testTestingHandlerList() throws {
        // given
        let expected: [String] = [
            String(describing: SpyServiceHandler.self)
        ]

        // when
        let delegate = try unwrap(UIApplication.shared.delegate as? MTPDelegate)
        let actual = delegate.handlers.map { String(describing: type(of: $0)) }

        // then
        XCTAssertEqual(expected, actual)
    }

    func testProductionHandlerList() {
        let expected = [
            String(describing: ServiceHandler.self),
            String(describing: LaunchHandler.self),
            String(describing: StateHandler.self),
            String(describing: ActionHandler.self),
            String(describing: NotificationsHandler.self)
        ]
        let actual = MTPDelegate.runtimeHandlers(for: .production)
                                .map { String(describing: type(of: $0)) }
        XCTAssertEqual(expected, actual)
    }
}
