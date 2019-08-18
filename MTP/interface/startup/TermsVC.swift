// @copyright Trollwerks Inc.

import UIKit

/// Display Terms of Use document and consent
final class TermsVC: UIViewController, ServiceProvider {

    private typealias Segues = R.segue.termsVC

    // verified in requireOutlets
    @IBOutlet private var agreeButton: GradientButton!

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireOutlets()
    }

    /// Prepare for reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        expose()
    }
}

// MARK: - Exposing

extension TermsVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        let items = navigationItem.leftBarButtonItems
        UITerms.close.expose(item: items?.first)
        UITerms.agree.expose(item: agreeButton)
    }
}

// MARK: - InterfaceBuildable

extension TermsVC: InterfaceBuildable {

    /// Injection enforcement for viewDidLoad
    func requireOutlets() {
        agreeButton.require()
    }
}
