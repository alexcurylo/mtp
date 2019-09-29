// @copyright Trollwerks Inc.

// migrated from https://github.com/rizumita/CTFeedbackSwift

//
//  SystemVersionCell.swift
//  CTFeedbackSwift
//
//  Created by 和泉田 領一 on 2017/09/24.
//  Copyright © 2017 CAPH TECH. All rights reserved.
//

import UIKit

/// SystemVersionCell
final class SystemVersionCell: UITableViewCell {

    /// :nodoc:
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    /// :nodoc:
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
}

extension SystemVersionCell: CellFactoryProtocol {

    /// :nodoc:
    class func configure(_ cell: SystemVersionCell,
                         with item: SystemVersionItem,
                         for indexPath: IndexPath,
                         eventHandler: Any?) {
        cell.textLabel?.text = L.feedbackiOS()
        cell.detailTextLabel?.text = item.version
        cell.selectionStyle = .none
    }
}
