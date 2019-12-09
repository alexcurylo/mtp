// @copyright Trollwerks Inc.

import Parchment

/// Paging item for checklist page holders
struct ListPagingItem: PagingItem, Hashable, Comparable {

    /// Checklist of this item
    let list: Checklist

    /// Implement Hashable
    /// - Parameter hasher: Hasher
    func hash(into hasher: inout Hasher) {
        hasher.combine(list)
    }

    /// Equality operator
    /// - Parameters:
    ///   - lhs: A thing
    ///   - rhs: Another thing
    /// - Returns: Equality
    static func == (lhs: ListPagingItem, rhs: ListPagingItem) -> Bool {
        return lhs.list == rhs.list
    }

    /// Less than operator
    /// - Parameters:
    ///   - lhs: A thing
    ///   - rhs: Another thing
    /// - Returns: Comparison
    static func < (lhs: ListPagingItem, rhs: ListPagingItem) -> Bool {
        return lhs.list.index < rhs.list.index
    }

    /// Provide paging items for Checklist cases
    static var pages: [ListPagingItem] = {
        Checklist.allCases.compactMap { list in
            ListPagingItem(list: list)
        }
    }()
}
