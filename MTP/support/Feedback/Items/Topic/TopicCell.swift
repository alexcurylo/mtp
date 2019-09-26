// @copyright Trollwerks Inc.

// migrated from https://github.com/rizumita/CTFeedbackSwift

//
// Created by 和泉田 領一 on 2017/09/07.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import UIKit

/// TopicCell
final class TopicCell: UITableViewCell {

    /// :nodoc:
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: TopicCell.reuseIdentifier)
    }

    /// :nodoc:
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
}

extension TopicCell: CellFactoryProtocol {

    /// :nodoc:
    static func configure(_ cell: TopicCell,
                          with item: TopicItem,
                          for indexPath: IndexPath,
                          eventHandler: Any?) {
        cell.textLabel?.text = L.feedbackTopic()
        cell.detailTextLabel?.text = item.topicTitle
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
    }
}
