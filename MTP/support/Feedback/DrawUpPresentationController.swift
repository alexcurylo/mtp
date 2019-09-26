// @copyright Trollwerks Inc.

// migrated from https://github.com/rizumita/CTFeedbackSwift

//
// Created by 和泉田 領一 on 2017/09/17.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import UIKit

/// DrawUpPresentationController
final class DrawUpPresentationController: UIPresentationController {

    private var overlayView: UIView?

     private func createOverlayView(withFrame frame: CGRect) -> UIView {
        let view = UIView(frame: frame)
        let gestureRecognizer = UITapGestureRecognizer(target: self,
                                                       action: #selector(overlayTouched(_:)))
        view.addGestureRecognizer(gestureRecognizer)
        view.backgroundColor = .black
        view.alpha = 0.0
        return view
    }

    /// :nodoc:
    override func presentationTransitionWillBegin() {
        guard let containerView = self.containerView else { return }
        let overlay = createOverlayView(withFrame: containerView.bounds)
        containerView.insertSubview(overlay, at: 0)
        overlayView = overlay
        if let transit = presentedViewController.transitionCoordinator {
            transit.animate(alongsideTransition: { [weak overlay] _ in overlay?.alpha = 0.5 },
                            completion: nil)
        }
    }

    /// :nodoc:
    override func dismissalTransitionWillBegin() {
        if let transit = presentedViewController.transitionCoordinator {
            transit.animate(alongsideTransition: { [weak overlayView]  _ in overlayView?.alpha = 0.0 },
                            completion: nil)
        }
    }

    /// :nodoc:
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        guard completed else { return }
        overlayView?.removeFromSuperview()
        overlayView = nil
    }

    /// :nodoc:
    override func size(forChildContentContainer container: UIContentContainer,
                       withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width, height: parentSize.height / 2.0)
    }

    /// :nodoc:
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerBounds = containerView?.bounds else { return CGRect.zero }
        var result = CGRect.zero
        result.size = size(forChildContentContainer: presentedViewController,
                           withParentContainerSize: containerBounds.size)
        result.origin.y = containerBounds.height - result.height
        return result
    }

    /// :nodoc:
    override func containerViewWillLayoutSubviews() {
        guard let containerBounds = containerView?.bounds else { return }
        overlayView?.frame = containerBounds
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    @objc private func overlayTouched(_ sender: Any) { presentedViewController.dismiss(animated: true) }
}
