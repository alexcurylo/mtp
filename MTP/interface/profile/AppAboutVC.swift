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
        expose()
    }
}

// MARK: - Exposing

extension AppAboutVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        let items = navigationItem.leftBarButtonItems
        UIAppAbout.close.expose(item: items?.first)
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
