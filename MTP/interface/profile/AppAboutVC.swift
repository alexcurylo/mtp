// @copyright Trollwerks Inc.

import UIKit

/// Static text display of application information
final class AppAboutVC: UIViewController, ServiceProvider {

    private typealias Segues = R.segue.appAboutVC

    @IBOutlet private var aboutTextView: TopLoadingTextView?

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        aboutTextView?.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
    }

    /// Prepare for reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .standard)
    }

    /// Instrument and inject navigation
    ///
    /// - Parameters:
    ///   - segue: Navigation action
    ///   - sender: Action originator
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.unwindFromAbout.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

// MARK: - Injectable

extension AppAboutVC: Injectable {

    /// Injected dependencies
    typealias Model = ()

    /// Handle dependency injection
    ///
    /// - Parameter model: Dependencies
    /// - Returns: Chainable self
    @discardableResult func inject(model: Model) -> Self {
        return self
    }

    /// Enforce dependency injection
    func requireInjections() {
        aboutTextView.require()
    }
}
