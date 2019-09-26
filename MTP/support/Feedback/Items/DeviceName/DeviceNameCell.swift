// @copyright Trollwerks Inc.

// migrated from https://github.com/rizumita/CTFeedbackSwift

//
//  DeviceNameCell.swift
//  CTFeedbackSwift
//
//  Created by 和泉田 領一 on 2017/09/24.
//  Copyright © 2017 CAPH TECH. All rights reserved.
//

import UIKit

/// DeviceNameCell
final class DeviceNameCell: UITableViewCell {

    /// :nodoc:
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    /// :nodoc:
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
}

extension DeviceNameCell: CellFactoryProtocol {

    /// :nodoc:
    static let reuseIdentifier: String = "DeviceNameCell"

    /// :nodoc:
    static func configure(_ cell: DeviceNameCell,
                          with item: DeviceNameItem,
                          for indexPath: IndexPath,
                          eventHandler: Any?) {
        cell.textLabel?.text = L.feedbackDevice()
        cell.detailTextLabel?.text = item.deviceName
        cell.selectionStyle = .none
    }
}
