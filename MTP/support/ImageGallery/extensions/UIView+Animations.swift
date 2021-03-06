// @copyright Trollwerks Inc.

// migrated from https://github.com/alexhillc/AXPhotoViewer

//
//  UIView+Animations.swift
//  AXPhotoViewer
//
//  Created by Alex Hill on 6/11/17.
//  Copyright © 2017 Alex Hill. All rights reserved.
//

import UIKit

extension UIView {

    /// Animate corner radii
    /// - Parameter duration: Duration
    /// - Parameter value: Value
    /// - Parameter views: UIView list
    /// - Parameter completion: Completion handler
    class func animateCornerRadii(withDuration duration: TimeInterval,
                                  to value: CGFloat,
                                  views: [UIView],
                                  completion: ((Bool) -> Void)? = nil) {
        assert(!views.isEmpty, "Must call `animateCornerRadii:duration:value:views:completion:` with at least 1 view.")

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?(true)
        }

        for view in views {
            view.layer.masksToBounds = true

            let animation = CABasicAnimation(keyPath: #keyPath(CALayer.cornerRadius))
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            animation.fromValue = view.layer.cornerRadius
            animation.toValue = value
            animation.duration = duration

            view.layer.add(animation, forKey: "CornerRadiusAnim")
            view.layer.cornerRadius = value
        }

        CATransaction.commit()
    }
}
