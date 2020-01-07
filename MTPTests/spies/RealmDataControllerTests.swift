// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class RealmDataControllerTests: TestCase {

    static let thresholds = [
        9, // .locations
        8, // .uncountries
        6, // .whss
        4, // .beaches
        5, // .golfcourses
        5, // .divesites
        7, // .restaurants
        7 // .hotels
    ]

    func testSeed() {
        // given
        let sut = RealmDataController()

        // when
        let beaches = sut.beaches
        let brands = sut.brands
        let countries = sut.countries
        let divesites = sut.divesites
        let golfcourses = sut.golfcourses
        let hotels = sut.hotels
        let locations = sut.locations
        let mappables = sut.mappables(list: nil)
        let restaurants = sut.restaurants
        let uncountries = sut.uncountries
        let whss = sut.whss
        let lists = Checklist.allCases.compactMap {
            sut.milestones(list: $0)
        }
        // RankingsPageInfo 7?
        // User 287 matching rankings uniques?

        // then
        XCTAssertEqual(beaches.count, 159)
        XCTAssertEqual(brands.count, 18)
        XCTAssertEqual(countries.count, 207)
        XCTAssertEqual(divesites.count, 99)
        XCTAssertEqual(golfcourses.count, 100)
        XCTAssertEqual(hotels.count, 1_538)
        XCTAssertEqual(locations.count, 950)
        XCTAssertEqual(mappables.count, 6_017)
        XCTAssertEqual(restaurants.count, 706)
        XCTAssertEqual(uncountries.count, 193)
        XCTAssertEqual(whss.count, 2_466)
        continueAfterFailure = false
        XCTAssertEqual(lists.count, Checklist.allCases.count)
        let thresholds = RealmDataControllerTests.thresholds
        for (index, list) in Checklist.allCases.enumerated() {
            let milestones = lists[index]
            XCTAssertEqual(list, milestones.checklist)
            XCTAssertEqual(thresholds[index], milestones.thresholds.count)
            XCTAssertFalse(milestones.milestone(count: 1).isEmpty)
            XCTAssertTrue(milestones.milestone(count: 99).isEmpty)
        }
    }
}
