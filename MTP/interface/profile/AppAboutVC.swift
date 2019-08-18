// @copyright Trollwerks Inc.

import UIKit

/// Static text display of application information
final class AppAboutVC: UIViewController, ServiceProvider {

    private typealias Segues = R.segue.appAboutVC

    // verified in requireOutlets
    @IBOutlet private var aboutTextView: TopLoadingTextView!

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireOutlets()

        aboutTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
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

// MARK: - InterfaceBuildable

extension AppAboutVC: InterfaceBuildable {

    /// Injection enforcement for viewDidLoad
    func requireOutlets() {
        aboutTextView.require()
    }
}
