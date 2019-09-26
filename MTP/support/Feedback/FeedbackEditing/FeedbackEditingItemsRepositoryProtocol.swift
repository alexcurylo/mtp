// @copyright Trollwerks Inc.

// migrated from https://github.com/rizumita/CTFeedbackSwift

//
// Created by 和泉田 領一 on 2017/09/09.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

/// FeedbackEditingItemsRepositoryProtocol
protocol FeedbackEditingItemsRepositoryProtocol {

    /// Item of type
    /// - Parameter type: type
    func item<Item>(of type: Item.Type) -> Item?

    /// Set item
    /// - Parameter item: item
    @discardableResult func set<Item: FeedbackItemProtocol>(item: Item) -> IndexPath?
}
