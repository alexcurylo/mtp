// @copyright Trollwerks Inc.

// migrated from https://github.com/alexhillc/AXPhotoViewer

//
//  AXPhotosTransitionAnimator.swift
//  AXPhotoViewer
//
//  Created by Alex Hill on 6/6/18.
//

import UIKit

/// AXPhotosTransitionAnimator
class AXPhotosTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    /// Fade transition ratio
    let fadeInOutTransitionRatio: Double = 1 / 3

    /// AXPhotosTransitionAnimatorDelegate
    weak var delegate: AXPhotosTransitionAnimatorDelegate?

    /// fadeView
    let transitionInfo: AXTransitionInfo
    /// fadeView
    var fadeView: UIView?

    /// :nodoc:
    init(transitionInfo: AXTransitionInfo) {
        self.transitionInfo = transitionInfo
    }

    // MARK: - UIViewControllerAnimatedTransitioning

    /// Transit duration
    /// - Parameter transitionContext: Context
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        self.transitionInfo.duration
    }

    /// Animate transition
    /// - Parameter transitionContext: context
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // swiftlint:disable:previous unavailable_function
        fatalError("Override in subclass.")
    }
}

/// AXPhotosTransitionAnimatorDelegate
protocol AXPhotosTransitionAnimatorDelegate: AnyObject {

    /// Completed presentation
    /// - Parameter animator: AXPhotosTransitionAnimator
    /// - Parameter transitionView: UIImageView
    func transitionAnimator(_ animator: AXPhotosTransitionAnimator,
                            didCompletePresentationWith transitionView: UIImageView)
    /// Completed dismissal
    /// - Parameter animator: AXPhotosTransitionAnimator
    /// - Parameter transitionView: UIImageView
    func transitionAnimator(_ animator: AXPhotosTransitionAnimator,
                            didCompleteDismissalWith transitionView: UIImageView)
    /// Cancelled dismissal
    /// - Parameter animator: AXPhotosTransitionAnimator
    func transitionAnimatorDidCancelDismissal(_ animator: AXPhotosTransitionAnimator)
}
