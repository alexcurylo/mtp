// @copyright Trollwerks Inc.

import Parchment

struct MyCountsPagingItem: PagingItem, Hashable, Comparable {

    let list: Checklist

    func hash(into hasher: inout Hasher) {
        hasher.combine(list)
    }

    static func == (lhs: MyCountsPagingItem, rhs: MyCountsPagingItem) -> Bool {
        return lhs.list == rhs.list
    }

    static func < (lhs: MyCountsPagingItem, rhs: MyCountsPagingItem) -> Bool {
        return lhs.list.index < rhs.list.index
    }
}
