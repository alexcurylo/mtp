// @copyright Trollwerks Inc.

// migrated from https://github.com/rizumita/CTFeedbackSwift

//
// Created by 和泉田 領一 on 2017/09/07.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import UIKit

/// FeedbackItemsDataSource
final class FeedbackItemsDataSource {

    private var sections: [FeedbackItemsSection] = []

    /// numberOfSections
    var numberOfSections: Int {
        return filteredSections.count
    }

    /// :nodoc:
    init(topics: [TopicProtocol],
         selected topic: TopicProtocol? = nil,
         body: String? = nil,
         hidesUserEmailCell: Bool = true,
         hidesUserPhoneCell: Bool = false,
         hidesAttachmentCell: Bool = false,
         hidesAppInfoSection: Bool = true) {
        sections.append(FeedbackItemsSection(
            title: L.feedbackUserDetail(),
            items: [UserEmailItem(isHidden: hidesUserEmailCell)])
        )

        sections.append(FeedbackItemsSection(
            items: [TopicItem(topics: topics,
                              selected: topic),
                    BodyItem(bodyText: body)])
        )

        sections.append(FeedbackItemsSection(
            title: L.feedbackAdditionalInfo(),
            items: [UserPhoneItem(isHidden: hidesUserPhoneCell),
                    AttachmentItem(isHidden: hidesAttachmentCell)])
        )

        sections.append(FeedbackItemsSection(
            title: L.feedbackDeviceInfo(),
            items: [DeviceNameItem(),
                    SystemVersionItem()])
        )

        sections.append(FeedbackItemsSection(
            title: L.feedbackAppInfo(),
            items: [AppNameItem(isHidden: hidesAppInfoSection),
                    AppVersionItem(isHidden: hidesAppInfoSection),
                    AppBuildItem(isHidden: hidesAppInfoSection)])
        )
    }

    /// Section fetcher
    /// - Parameter section: Section index
    func section(at section: Int) -> FeedbackItemsSection {
        return filteredSections[section]
    }
}

private extension FeedbackItemsDataSource {

    var filteredSections: [FeedbackItemsSection] {
        return sections.filter { section in
            section.items.contains { !$0.isHidden }
        }
    }

    subscript(indexPath: IndexPath) -> FeedbackItemProtocol {
        get { return filteredSections[indexPath.section][indexPath.item] }
        set { filteredSections[indexPath.section][indexPath.item] = newValue }
    }

    func indexPath<Item>(of type: Item.Type) -> IndexPath? {
        let filtered = filteredSections
        for section in filtered {
            guard let index = filtered.firstIndex(where: { $0 === section }),
                let subIndex = section.items.firstIndex(where: { $0 is Item })
                else { continue }
            return IndexPath(item: subIndex, section: index)
        }
        return .none
    }
}

extension FeedbackItemsDataSource: FeedbackEditingItemsRepositoryProtocol {

    /// :nodoc:
    func item<Item>(of type: Item.Type) -> Item? {
        guard let indexPath = indexPath(of: type) else { return .none }
        return self[indexPath] as? Item
    }

    /// :nodoc:
    @discardableResult func set<Item: FeedbackItemProtocol>(item: Item) -> IndexPath? {
        guard let indexPath = indexPath(of: Item.self) else { return .none }
        self[indexPath] = item
        return indexPath
    }
}

/// FeedbackItemsSection
final class FeedbackItemsSection {

    /// title
    let title: String?
    /// items
    var items: [FeedbackItemProtocol]

    /// :nodoc:
    init(title: String? = .none,
         items: [FeedbackItemProtocol] = []) {
        self.title = title
        self.items = items
    }
}

extension FeedbackItemsSection: Collection {

    /// :nodoc:
    var startIndex: Int { return items.startIndex }
    /// :nodoc:
    var endIndex: Int { return items.endIndex }

    /// :nodoc:
    subscript(position: Int) -> FeedbackItemProtocol {
        get { return items[position] }
        set { items[position] = newValue }
    }

    /// :nodoc:
    func index(after i: Int) -> Int { return items.index(after: i) }
}
