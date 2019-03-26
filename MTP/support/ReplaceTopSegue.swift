// @copyright Trollwerks Inc.

import UIKit

final class ReplaceTopSegue: UIStoryboardSegue {

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

final class DismissSegue: UIStoryboardSegue {

    override func perform() {
        source.presentingViewController?.dismiss(animated: true)
    }
}

final class PopSegue: UIStoryboardSegue {

    override func perform() {
        source.navigationController?.popViewController(animated: true)
    }
}

final class SwitchAlertSegue: UIStoryboardSegue {

    override func perform() {
        if let presenter = source.presentingViewController {
            presenter.dismiss(animated: false)
            presenter.present(destination, animated: false)
        } else {
            super.perform()
        }
    }
}

final class TabPresentSegue: UIStoryboardSegue {

    override func perform() {
        source.tabBarController?.present(destination, animated: true)
    }
}

final class FadeInAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }

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

final class ZoomAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }

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
