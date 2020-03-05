// @copyright Trollwerks Inc.

// migrated from https://github.com/rizumita/CTFeedbackSwift

//
// Created by 和泉田 領一 on 2017/09/18.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import UIKit

/// AttachmentCellEventProtocol
protocol AttachmentCellEventProtocol {

    /// Show image
    /// - Parameter item: AttachmentItem
    func showImage(of item: AttachmentItem)
}

/// AttachmentCell
final class AttachmentCell: UITableViewCell {

    private enum Const {

        static let NoAttachedCellHeight: CGFloat = 44.0
        static let AttachedCellHeight: CGFloat = 65.0
        static let Margin: CGFloat = 15.0
    }

    private var eventHandler: AttachmentCellEventProtocol?
    private var item: AttachmentItem?

    private let attView = UIImageView()
    private var attViewHeight: NSLayoutConstraint?
    private var attViewWidth: NSLayoutConstraint?

    private let attLabel = UILabel()
    private var attLabelLeadImage: NSLayoutConstraint?
    private var attLabelLeadContentView: NSLayoutConstraint?

    private let tapImageViewGestureRecognizer = UITapGestureRecognizer()

    /// :nodoc:
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        attView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(attView)
        attView.isUserInteractionEnabled = true
        attViewHeight = attView.heightAnchor.constraint(equalToConstant: Const.NoAttachedCellHeight)
        attViewHeight?.isActive = true
        contentView.topAnchor.constraint(equalTo: attView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: attView.bottomAnchor).isActive = true
        attView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                         constant: Const.Margin).isActive = true
        attViewWidth = attView.widthAnchor.constraint(equalToConstant: 0.0)
        attViewWidth?.isActive = true
        attView.addGestureRecognizer(tapImageViewGestureRecognizer)
        tapImageViewGestureRecognizer.addTarget(self, action: #selector(attViewTapped(_:)))

        attLabel.translatesAutoresizingMaskIntoConstraints = false
        attLabel.numberOfLines = 0
        contentView.addSubview(attLabel)
        attLabel.adjustsFontSizeToFitWidth = true
        attLabelLeadImage = attLabel.leadingAnchor.constraint(equalTo: attView.trailingAnchor,
                                                              constant: Const.Margin)
        attLabelLeadContentView = attLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                                    constant: Const.Margin)
        contentView.trailingAnchor.constraint(equalTo: attLabel.trailingAnchor,
                                              constant: 0.0).isActive = true
        contentView.centerYAnchor.constraint(equalTo: attLabel.centerYAnchor).isActive = true
        attLabel.text = L.feedbackAttachImageOrVideo()

        accessoryType = .disclosureIndicator
    }

    /// :nodoc:
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

    /// attViewTapped
    /// - Parameter gestureRecognizer: UITapGestureRecognizer
    @objc func attViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let item = item, item.image != .none else { return }

        eventHandler?.showImage(of: item)
    }
}

extension AttachmentCell: CellFactoryProtocol {

    /// :nodoc:
    class func configure(_ cell: AttachmentCell,
                         with item: AttachmentItem,
                         for indexPath: IndexPath,
                         eventHandler: AttachmentCellEventProtocol) {
        cell.item = item

        cell.imageView?.image = item.image
        if let heightConstraint = cell.attViewHeight {
            heightConstraint.constant = item.attached ? Const.AttachedCellHeight : Const.NoAttachedCellHeight

            if let image = cell.imageView?.image {
                cell.attViewWidth?.constant = image.size.width * heightConstraint.constant / image.size.height
                cell.attLabelLeadContentView?.isActive = false
                cell.attLabelLeadImage?.isActive = true
            } else {
                cell.attViewWidth?.constant = 0.0
                cell.attLabelLeadImage?.isActive = false
                cell.attLabelLeadContentView?.isActive = true
            }
        }
        cell.eventHandler = eventHandler
    }
}
