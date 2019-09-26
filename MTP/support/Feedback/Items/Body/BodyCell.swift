// @copyright Trollwerks Inc.

// migrated from https://github.com/rizumita/CTFeedbackSwift

//
//  BodyCell.swift
//  CTFeedbackSwift
//
//  Created by 和泉田 領一 on 2017/09/16.
//  Copyright © 2017年 CAPH TECH. All rights reserved.
//

import UIKit

/// BodyCellEventProtocol
protocol BodyCellEventProtocol {

    /// bodyCellHeightChanged
    func bodyCellHeightChanged()
    /// bodyTextDidChange
    /// - Parameter text: Text
    func bodyTextDidChange(_ text: String?)
}

/// BodyCell
final class BodyCell: UITableViewCell {

    private var eventHandler: BodyCellEventProtocol?

    /// textView
    let textView: UITextView = {
        let result = UITextView(frame: CGRect.zero)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.isScrollEnabled = false
        result.font = .systemFont(ofSize: 14.0)
        result.backgroundColor = .clear
        return result
    }()
    private var heightConstraint: NSLayoutConstraint?

    private var height: CGFloat {
        let size = textView.sizeThatFits(CGSize(width: textView.frame.width,
                                                height: CGFloat.greatestFiniteMagnitude))
        return max(100.0, size.height)
    }

    /// :nodoc:
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        textView.delegate = self
        contentView.addSubview(textView)
        contentView.topAnchor.constraint(equalTo: textView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: textView.bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: textView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: textView.trailingAnchor).isActive = true
        heightConstraint = contentView.heightAnchor.constraint(equalToConstant: height)
        heightConstraint?.priority = .defaultHigh
        heightConstraint?.isActive = true
    }

    /// :nodoc:
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
}

extension BodyCell: UITextViewDelegate {

    /// :nodoc:
    func textViewDidChange(_ textView: UITextView) {
        heightConstraint?.constant = height
        eventHandler?.bodyCellHeightChanged()
        eventHandler?.bodyTextDidChange(textView.text)
    }
}

extension BodyCell: CellFactoryProtocol {

    /// :nodoc:
    static func configure(_ cell: BodyCell,
                          with item: BodyItem,
                          for indexPath: IndexPath,
                          eventHandler: BodyCellEventProtocol) {
        cell.textView.text = item.bodyText
        cell.selectionStyle = .none
        cell.eventHandler = eventHandler
    }
}
