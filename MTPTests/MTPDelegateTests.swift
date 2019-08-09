// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class MTPDelegateTests: XCTestCase {

    func testUnitTestingHandlerList() throws {
        // given
        let expected: [String] = [
            String(describing: ServiceHandlerSpy.self)
        ]

        // when
        let delegate = try unwrap(UIApplication.shared.delegate as? MTPDelegate)
        let actual = delegate.handlers.map { String(describing: type(of: $0)) }

        // then
        XCTAssertEqual(expected, actual)
    }

    func testProductionHandlerList() {
        // given
        let expected = [
            String(describing: ServiceHandler.self),
            String(describing: LaunchHandler.self),
            String(describing: StateHandler.self),
            String(describing: ActionHandler.self),
            String(describing: NotificationsHandler.self),
            String(describing: LocationHandler.self)
        ]

        // when
        let actual = MTPDelegate.runtimeHandlers(for: .production)
                                .map { String(describing: type(of: $0)) }

        // then
        XCTAssertEqual(expected, actual)
    }

    func testUITestingHandlerList() {
        // given
        let expected = [
            String(describing: ServiceHandlerStub.self),
            String(describing: LaunchHandler.self),
            String(describing: StateHandler.self),
            String(describing: ActionHandler.self),
            String(describing: NotificationsHandler.self),
            String(describing: LocationHandler.self)
        ]

        // when
        let actual = MTPDelegate.runtimeHandlers(for: .uiTesting)
                                .map { String(describing: type(of: $0)) }

        // then
       XCTAssertEqual(expected, actual)
    }
}
