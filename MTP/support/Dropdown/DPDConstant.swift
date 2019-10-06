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

        /// frame
		static let Frame = "frame"
	}

    /// ReusableIdentifier
	enum ReusableIdentifier {

        /// DropdownCell
		static let DropdownCell = "DropdownCell"
	}

    /// UI
	enum UI {
        // swiftlint:disable:previous type_name

        /// TextColor
        static let TextColor = UIColor.black
        /// SelectedTextColor
        static let SelectedTextColor = UIColor.black
        /// TextFont
        static let TextFont = UIFont.systemFont(ofSize: 15)
        /// BackgroundColor
        static let BackgroundColor = UIColor(white: 0.94, alpha: 1)
        /// SelectionBackgroundColor
        static let SelectionBackgroundColor = UIColor(white: 0.89, alpha: 1)
        /// SeparatorColor
        static let SeparatorColor = UIColor.clear
        /// CornerRadius
        static let CornerRadius: CGFloat = 2
        /// RowHeight
        static let RowHeight: CGFloat = 44
        /// HeightPadding
		static let HeightPadding: CGFloat = 20

        /// Shadow
		enum Shadow {

            /// Color
            static let Color = UIColor.darkGray
            /// Offset
            static let Offset = CGSize.zero
            /// Opacity
            static let Opacity: Float = 0.4
            /// Radius
			static let Radius: CGFloat = 8
		}
	}

    /// Animation
	enum Animation {

        /// Duration
        static let Duration = 0.15
        /// EntranceOptions
        static let EntranceOptions: UIView.AnimationOptions = [.allowUserInteraction, .curveEaseOut]
        /// ExitOptions
        static let ExitOptions: UIView.AnimationOptions = [.allowUserInteraction, .curveEaseIn]
        /// DownScaleTransform
		static let DownScaleTransform = CGAffineTransform(scaleX: 0.9, y: 0.9)
	}
}
