// @copyright Trollwerks Inc.

import Foundation
import Parchment

enum RankingPage: Int {
    case allMTPLocations
    case unCountries
    case whs
    case beaches
    case golfCourses
    case diveSites
    case restaurants

    var title: String {
        switch self {
        case .allMTPLocations:
            return Localized.allMTPLocations()
        case .unCountries:
            return Localized.unCountries()
        case .whs:
            return Localized.whSites()
        case .beaches:
            return Localized.beaches()
        case .golfCourses:
            return Localized.golfCourses()
        case .diveSites:
            return Localized.diveSites()
        case .restaurants:
            return Localized.restaurants()
        }
    }

    var image: UIImage? {
        switch self {
        case .allMTPLocations:
            return R.image.listMTP()
        case .unCountries:
            return R.image.listUN()
        case .whs:
            return R.image.listWHS()
        case .beaches:
            return R.image.listBeaches()
        case .golfCourses:
            return R.image.listGolf()
        case .diveSites:
            return R.image.listDive()
        case .restaurants:
            return R.image.listRestaurants()
        }
    }
}

struct RankingPagingItem: PagingItem, Hashable, Comparable {

    let page: RankingPage
    let members: [Int]

    var hashValue: Int {
        return page.hashValue
    }

    static func == (lhs: RankingPagingItem, rhs: RankingPagingItem) -> Bool {
        return lhs.page == rhs.page
    }

    static func < (lhs: RankingPagingItem, rhs: RankingPagingItem) -> Bool {
        return lhs.page.rawValue < rhs.page.rawValue
    }

    static let pages = [
        RankingPagingItem(
            page: .allMTPLocations,
            members: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        RankingPagingItem(
            page: .unCountries,
            members: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        RankingPagingItem(
            page: .whs,
            members: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        RankingPagingItem(
            page: .beaches,
            members: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        RankingPagingItem(
            page: .golfCourses,
            members: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        RankingPagingItem(
            page: .diveSites,
            members: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        RankingPagingItem(
            page: .restaurants,
            members: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    ]
}
