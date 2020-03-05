// @copyright Trollwerks Inc.

// migrated from https://github.com/alexhillc/AXPhotoViewer

//
//  AXButton.swift
//  AXPhotoViewer
//
//  Created by Alex Hill on 3/11/18.
//

import UIKit

/// AXButton
class AXButton: StateButton {

    /// :nodoc:
    init() {
        super.init(frame: .zero)

        self.controlStateAnimationTimingFunction = CAMediaTimingFunction(name: .linear)
        self.controlStateAnimationDuration = 0.1
        self.setBorderWidth(1.0, for: .normal)
        self.setBorderColor(.white, for: .normal)
        self.setAlpha(1.0, for: .normal)
        self.setAlpha(0.3, for: .highlighted)
        self.setTransformScale(1.0, for: .normal)
        self.setTransformScale(0.95, for: .highlighted)
    }

    /// :nodoc:
    required init?(coder aDecoder: NSCoder) { nil }
}
