// @copyright Trollwerks Inc.

import Parchment

struct ListPagingItem: PagingItem, Hashable, Comparable {

    let list: Checklist

    func hash(into hasher: inout Hasher) {
        hasher.combine(list)
    }

    /// Equality operator
    ///
    /// - Parameters:
    ///   - lhs: A thing
    ///   - rhs: Another thing
    /// - Returns: Equality
    static func == (lhs: ListPagingItem, rhs: ListPagingItem) -> Bool {
        return lhs.list == rhs.list
    }

    static func < (lhs: ListPagingItem, rhs: ListPagingItem) -> Bool {
        return lhs.list.index < rhs.list.index
    }

    static var pages: [ListPagingItem] = {
        Checklist.allCases.compactMap { list in
            ListPagingItem(list: list)
        }
    }()
}
