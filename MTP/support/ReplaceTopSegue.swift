// @copyright Trollwerks Inc.

import UIKit

/// Custom segue to replace top controller
final class ReplaceTopSegue: UIStoryboardSegue {

    /// Perform the segue
    override func perform() {
        if let nav = source.navigationController {
            var vcs = nav.viewControllers
            vcs.removeLast()
            vcs.append(destination)

            nav.setViewControllers(vcs, animated: true)
        } else {
            super.perform()
        }
    }
}

/// Custom segue to dismiss top controller
final class DismissSegue: UIStoryboardSegue {

    /// Perform the segue
    override func perform() {
        source.presentingViewController?.dismiss(animated: true)
    }
}

/// Custom segue to pop top controller
final class PopSegue: UIStoryboardSegue {

    /// Perform the segue
    override func perform() {
        source.navigationController?.popViewController(animated: true)
    }
}

/// Custom segue to switch alert controllers
final class SwitchAlertSegue: UIStoryboardSegue {

    /// Perform the segue
    override func perform() {
        if let presenter = source.presentingViewController {
            presenter.dismiss(animated: false)
            presenter.present(destination, animated: false)
        } else {
            super.perform()
        }
    }
}

/// Custom segue to preset from tab bar controller
final class TabPresentSegue: UIStoryboardSegue {

    /// Perform the segue
    override func perform() {
        if let tabBar = source.tabBarController {
            tabBar.present(destination, animated: true)
        } else {
            source.present(destination, animated: true)
        }
    }
}

/// Animator for segue fade transitioning
final class FadeInAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    /// Transition duration
    /// - Parameter transitionContext: context
    /// - Returns: 0.35 seconds
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }

    /// Perform transition
    /// - Parameter transitionContext: context
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let to = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(true)
            return
        }

        let containerView = transitionContext.containerView
        containerView.addSubview(to)
        to.alpha = 0

        let duration = transitionDuration(using: transitionContext)
        UIView.animate(
            withDuration: duration,
            animations: {
                to.alpha = 1
            },
            completion: { _ in
                let cancelled = transitionContext.transitionWasCancelled
                transitionContext.completeTransition(!cancelled)
            }
        )
    }
}

/// Animator for segue zoom transitioning
final class ZoomAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    /// Transition duration
    /// - Parameter transitionContext: context
    /// - Returns: 1 second
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }

    /// Perform transition
    /// - Parameter transitionContext: context
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let from = transitionContext.view(forKey: .from),
              let to = transitionContext.view(forKey: .to) else {
                transitionContext.completeTransition(true)
                return
        }

        to.transform = CGAffineTransform(scaleX: 0, y: 0)
        to.center = from.center

        let containerView = transitionContext.containerView
        containerView.addSubview(to)
        containerView.bringSubviewToFront(to)

        let duration = transitionDuration(using: transitionContext)
        UIView.animate(
            withDuration: duration,
            animations: {
                to.transform = .identity
            },
            completion: { _ in
                let cancelled = transitionContext.transitionWasCancelled
                transitionContext.completeTransition(!cancelled)
            }
        )
    }
}
