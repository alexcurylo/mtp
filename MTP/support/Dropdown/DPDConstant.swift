// @copyright Trollwerks Inc.

// migrated from https://github.com/AssistoLab/Dropdown

//
//  Constants.swift
//  Dropdown
//
//  Created by Kevin Hirsch on 28/07/15.
//  Copyright (c) 2015 Kevin Hirsch. All rights reserved.
//

import UIKit

/// DPDConstant
enum DPDConstant {

    /// KeyPath
	enum KeyPath {

		static let Frame = "frame"
	}

    /// ReusableIdentifier
	enum ReusableIdentifier {

		static let DropdownCell = "DropdownCell"
	}

    /// UI
	enum UI {
        // swiftlint:disable:previous type_name

		static let TextColor = UIColor.black
        static let SelectedTextColor = UIColor.black
		static let TextFont = UIFont.systemFont(ofSize: 15)
		static let BackgroundColor = UIColor(white: 0.94, alpha: 1)
		static let SelectionBackgroundColor = UIColor(white: 0.89, alpha: 1)
		static let SeparatorColor = UIColor.clear
		static let CornerRadius: CGFloat = 2
		static let RowHeight: CGFloat = 44
		static let HeightPadding: CGFloat = 20

        /// Shadow
		enum Shadow {

			static let Color = UIColor.darkGray
			static let Offset = CGSize.zero
			static let Opacity: Float = 0.4
			static let Radius: CGFloat = 8
		}
	}

    /// Animation
	enum Animation {

		static let Duration = 0.15
		static let EntranceOptions: UIView.AnimationOptions = [.allowUserInteraction, .curveEaseOut]
		static let ExitOptions: UIView.AnimationOptions = [.allowUserInteraction, .curveEaseIn]
		static let DownScaleTransform = CGAffineTransform(scaleX: 0.9, y: 0.9)
	}
}
