// @copyright Trollwerks Inc.

import Parchment

struct RankingsPagingItem: PagingItem, Hashable, Comparable {

    let page: Checklist
    let members: [Int]

    func hash(into hasher: inout Hasher) {
        hasher.combine(page)
    }

    static func == (lhs: RankingsPagingItem, rhs: RankingsPagingItem) -> Bool {
        return lhs.page == rhs.page
    }

    static func < (lhs: RankingsPagingItem, rhs: RankingsPagingItem) -> Bool {
        return lhs.page.index < rhs.page.index
    }

    static let pages = [
        RankingsPagingItem(
            page: .locations,
            members: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        RankingsPagingItem(
            page: .uncountries,
            members: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        RankingsPagingItem(
            page: .whss,
            members: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        RankingsPagingItem(
            page: .beaches,
            members: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        RankingsPagingItem(
            page: .golfcourses,
            members: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        RankingsPagingItem(
            page: .divesites,
            members: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        RankingsPagingItem(
            page: .restaurants,
            members: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    ]
}
