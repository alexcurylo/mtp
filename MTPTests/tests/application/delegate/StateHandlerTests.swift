// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class StateHandlerTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        super.tearDown()
    }

    func testTransitions() throws {
        // given
        let app = UIApplication.shared
        app.applicationIconBadgeNumber = 5
        let sut = StateHandler()

        // when
        sut.applicationWillEnterForeground(app)
        sut.applicationDidBecomeActive(app)
        sut.applicationWillResignActive(app)
        sut.applicationDidEnterBackground(app)
        sut.applicationWillTerminate(app)

        // then
        XCTAssertEqual(app.applicationIconBadgeNumber, 0)
        // check everything refreshed too
    }
}
