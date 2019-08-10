// @copyright Trollwerks Inc.

import XCTest

final class RankingsUITests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testRankings() {
        launch(settings: [.loggedIn(true)])

        UIMain.bar.wait()
        UIMain.locations.assert(.selected)

        UIMain.rankings.tap()
        UIMain.rankings.wait(for: .selected)
    }
}
