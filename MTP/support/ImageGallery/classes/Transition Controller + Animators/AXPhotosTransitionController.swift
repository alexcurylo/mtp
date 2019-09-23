// @copyright Trollwerks Inc.

// migrated from https://github.com/alexhillc/AXPhotoViewer

//
//  AXPhotosTransitionController.swift
//  AXPhotoViewer
//
//  Created by Alex Hill on 6/4/17.
//  Copyright © 2017 Alex Hill. All rights reserved.
//

import UIKit

/// AXPhotosTransitionController
class AXPhotosTransitionController: NSObject,
                                    UIViewControllerTransitioningDelegate,
                                    AXPhotosTransitionAnimatorDelegate {

    fileprivate static let supportedModalPresentationStyles: [UIModalPresentationStyle] =  [.fullScreen,
                                                                                            .currentContext,
                                                                                            .custom,
                                                                                            .overFullScreen,
                                                                                            .overCurrentContext]

    weak var delegate: AXPhotosTransitionControllerDelegate?

    /// Custom animator for presentation.
    fileprivate var presentationAnimator: AXPhotosPresentationAnimator?

    /// Custom animator for dismissal.
    fileprivate var dismissalAnimator: AXPhotosDismissalAnimator?

    /// If this flag is `true`, the transition controller will use gestures to dismiss viewController interactively,
    /// otherwise dismissal will be immediate.
    var forceInteractiveDismissal = false

    /// The transition configuration passed in at initialization.
    /// The controller uses this object to apply customization to the transition.
    let transitionInfo: AXTransitionInfo

    fileprivate var supportsContextualPresentation: Bool {
        return self.transitionInfo.startingView != nil
    }

    fileprivate var supportsContextualDismissal: Bool {
        return self.transitionInfo.endingView != nil
    }

    fileprivate var supportsInteractiveDismissal: Bool {
        return self.transitionInfo.interactiveDismissalEnabled
    }

    /// :nodoc:
    init(transitionInfo: AXTransitionInfo) {
        self.transitionInfo = transitionInfo
        super.init()
    }

    // MARK: - UIViewControllerTransitioningDelegate

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        var photosViewController: AXPhotosViewController
        if let dismissed = dismissed as? AXPhotosViewController {
            photosViewController = dismissed
        // swiftlint:disable:next line_length
        } else if let child = dismissed.children.first(where: { $0 is AXPhotosViewController }) as? AXPhotosViewController {
            photosViewController = child
        } else {
            assertionFailure("Could not find AXPhotosViewController in container's children.")
            return nil
        }

        guard let photo = photosViewController.dataSource.photo(at: photosViewController.currentPhotoIndex) else {
            return nil
        }

        // resolve transitionInfo's endingView
        transitionInfo.resolveEndingViewClosure?(photo, photosViewController.currentPhotoIndex)

        if !type(of: self).supportedModalPresentationStyles.contains(photosViewController.modalPresentationStyle) {
            return nil
        }

        if !supportsContextualDismissal && !supportsInteractiveDismissal {
            return nil
        }

        dismissalAnimator = dismissalAnimator ?? AXPhotosDismissalAnimator(transitionInfo: transitionInfo)
        dismissalAnimator?.delegate = self

        return dismissalAnimator
    }

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        var photosViewController: AXPhotosViewController
        if let presented = presented as? AXPhotosViewController {
            photosViewController = presented
            // swiftlint:disable:next line_length
        } else if let child = presented.children.first(where: { $0 is AXPhotosViewController }) as? AXPhotosViewController {
            photosViewController = child
        } else {
            assertionFailure("Could not find AXPhotosViewController in container's children.")
            return nil
        }

        if !type(of: self).supportedModalPresentationStyles.contains(photosViewController.modalPresentationStyle) {
            return nil
        }

        if !self.supportsContextualPresentation {
            return nil
        }

        self.presentationAnimator = AXPhotosPresentationAnimator(transitionInfo: self.transitionInfo)
        self.presentationAnimator?.delegate = self

        return self.presentationAnimator
    }

    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        if !supportsInteractiveDismissal || !forceInteractiveDismissal {
            return nil
        }

        dismissalAnimator = dismissalAnimator ?? AXPhotosDismissalAnimator(transitionInfo: transitionInfo)
        dismissalAnimator?.delegate = self

        return dismissalAnimator
    }

    // MARK: - Interaction handling

    func didPanWithGestureRecognizer(_ sender: UIPanGestureRecognizer,
                                     in viewController: UIViewController) {
        self.dismissalAnimator?.didPanWithGestureRecognizer(sender, in: viewController)
    }

    // MARK: - AXPhotosTransitionAnimatorDelegate

    func transitionAnimator(_ animator: AXPhotosTransitionAnimator,
                            didCompletePresentationWith transitionView: UIImageView) {
        self.delegate?.transitionController(self, didCompletePresentationWith: transitionView)
        self.presentationAnimator = nil
    }

    func transitionAnimator(_ animator: AXPhotosTransitionAnimator,
                            didCompleteDismissalWith transitionView: UIImageView) {
        self.delegate?.transitionController(self, didCompleteDismissalWith: transitionView)
        self.dismissalAnimator = nil
    }

    func transitionAnimatorDidCancelDismissal(_ animator: AXPhotosTransitionAnimator) {
        self.delegate?.transitionControllerDidCancelDismissal(self)
        self.dismissalAnimator = nil
    }
}

protocol AXPhotosTransitionControllerDelegate: AnyObject {

    func transitionController(_ transitionController: AXPhotosTransitionController,
                              didCompletePresentationWith transitionView: UIImageView)
    func transitionController(_ transitionController: AXPhotosTransitionController,
                              didCompleteDismissalWith transitionView: UIImageView)
    func transitionControllerDidCancelDismissal(_ transitionController: AXPhotosTransitionController)
}
