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

        UIMain.rankings.tap()
        UIMain.rankings.wait(for: .selected)

        UIRankingsPaging.page(.uncountries).tap()
        UIRankingsPaging.page(.beaches).tap()
        UIRankingsPaging.page(.divesites).tap()
        UIRankingsPaging.page(.restaurants).tap()
        UIRankingsPaging.page(.golfcourses).tap()
        UIRankingsPaging.page(.whss).tap()
        UIRankingsPaging.page(.locations).tap()

        UIRankingsPage.visited(.locations, 0).tap()

        UIUserCountsPaging.remaining.tap()

        UIUserCounts.close.tap()

        UIRankingsPage.profile(.locations, 0).tap()

        UIUserProfile.close.tap()

        UIRankings.filter.tap()

        UIRankingsFilter.close.tap()

        UIRankings.find.tap()
        UIRankings.cancel.tap()
        UIRankings.find.tap()
        UIRankings.search.type(text: "Fred")
        UIRankings.result(0).tap()
    }
}
