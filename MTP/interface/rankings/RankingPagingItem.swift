// @copyright Trollwerks Inc.

import Parchment

struct RankingPagingItem: PagingItem, Hashable, Comparable {

    let page: Checklist
    let members: [Int]

    func hash(into hasher: inout Hasher) {
        hasher.combine(page)
    }

    static func == (lhs: RankingPagingItem, rhs: RankingPagingItem) -> Bool {
        return lhs.page == rhs.page
    }

    static func < (lhs: RankingPagingItem, rhs: RankingPagingItem) -> Bool {
        return lhs.page.index < rhs.page.index
    }

    static let pages = [
        RankingPagingItem(
            page: .locations,
            members: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        RankingPagingItem(
            page: .uncountries,
            members: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        RankingPagingItem(
            page: .whss,
            members: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        RankingPagingItem(
            page: .beaches,
            members: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        RankingPagingItem(
            page: .golfcourses,
            members: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        RankingPagingItem(
            page: .divesites,
            members: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        RankingPagingItem(
            page: .restaurants,
            members: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    ]
}
