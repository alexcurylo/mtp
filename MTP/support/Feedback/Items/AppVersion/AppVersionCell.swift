// @copyright Trollwerks Inc.

// migrated from https://github.com/rizumita/CTFeedbackSwift

//
//  AppVersionCell.swift
//  CTFeedbackSwift
//
//  Created by 和泉田 領一 on 2017/09/24.
//  Copyright © 2017 CAPH TECH. All rights reserved.
//

import UIKit

/// AppVersionCell
final class AppVersionCell: UITableViewCell {

    /// :nodoc:
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    /// :nodoc:
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
}

extension AppVersionCell: CellFactoryProtocol {

    /// :nodoc:
    class func configure(_ cell: AppVersionCell,
                         with item: AppVersionItem,
                         for indexPath: IndexPath,
                         eventHandler: Any?) {
        cell.textLabel?.text = L.feedbackVersion()
        cell.detailTextLabel?.text = item.version
        cell.selectionStyle = .none
    }
}
