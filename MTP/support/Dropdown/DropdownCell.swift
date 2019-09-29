// @copyright Trollwerks Inc.

// migrated from https://github.com/AssistoLab/Dropdown

//
//  DropdownCellTableViewCell.swift
//  Dropdown
//
//  Created by Kevin Hirsch on 28/07/15.
//  Copyright (c) 2015 Kevin Hirsch. All rights reserved.
//

import UIKit

/// DropdownCell
final class DropdownCell: UITableViewCell {

	/// optionLabel
	@IBOutlet var optionLabel: UILabel!
    // swiftlint:disable:previous private_outlet

    /// selectedBackgroundColor
    var selectedBackgroundColor: UIColor?
    /// highlightTextColor
    var highlightTextColor: UIColor?
    /// normalTextColor
    var normalTextColor: UIColor?
}

// MARK: - UI

extension DropdownCell {

    /// :nodoc:
	override func awakeFromNib() {
		super.awakeFromNib()

		backgroundColor = .clear
	}

    /// :nodoc:
	override var isSelected: Bool {
		willSet {
			setSelected(newValue, animated: false)
		}
	}

    /// :nodoc:
	override var isHighlighted: Bool {
		willSet {
			setSelected(newValue, animated: false)
		}
	}

    /// :nodoc:
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		setSelected(highlighted, animated: animated)
	}

    /// :nodoc:
	override func setSelected(_ selected: Bool, animated: Bool) {
		let executeSelection: () -> Void = { [weak self] in
			guard let `self` = self else { return }

			if let selectedBackgroundColor = self.selectedBackgroundColor {
				if selected {
					self.backgroundColor = selectedBackgroundColor
                    self.optionLabel.textColor = self.highlightTextColor
				} else {
					self.backgroundColor = .clear
                    self.optionLabel.textColor = self.normalTextColor
				}
			}
		}

		if animated {
            UIView.animate(withDuration: 0.3,
                           animations: {
                               executeSelection()
                           },
                           completion: nil)
		} else {
			executeSelection()
		}

		accessibilityTraits = selected ? .selected : .none
	}
}
