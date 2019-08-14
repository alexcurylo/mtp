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

        UIRankingsPaging.page(.whss).tap()
        UIRankingsPaging.page(.locations).tap()

        UIRankingsPage.visited(.locations, 0).tap()

        UIUserCountsPaging.remaining.tap()

        UIUserCounts.close.tap()

        UIRankingsPage.profile(.locations, 0).tap()

        UIUserProfile.close.tap()

        UIRankings.filter.tap()

        UIRankingsFilter.close.tap()

        UIRankings.search.tap()
        UIRankings.search.tap()
    }
}
