// @copyright Trollwerks Inc.

import Parchment

struct MyCountsPagingItem: PagingItem, Hashable, Comparable {

    let page: Checklist
    let members: [Int]

    func hash(into hasher: inout Hasher) {
        hasher.combine(page)
    }

    static func == (lhs: MyCountsPagingItem, rhs: MyCountsPagingItem) -> Bool {
        return lhs.page == rhs.page
    }

    static func < (lhs: MyCountsPagingItem, rhs: MyCountsPagingItem) -> Bool {
        return lhs.page.index < rhs.page.index
    }

    static let pages = [
        MyCountsPagingItem(
            page: .locations,
            members: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        MyCountsPagingItem(
            page: .uncountries,
            members: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        MyCountsPagingItem(
            page: .whss,
            members: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        MyCountsPagingItem(
            page: .beaches,
            members: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        MyCountsPagingItem(
            page: .golfcourses,
            members: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        MyCountsPagingItem(
            page: .divesites,
            members: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        MyCountsPagingItem(
            page: .restaurants,
            members: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    ]
}
