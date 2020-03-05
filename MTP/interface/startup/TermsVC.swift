// @copyright Trollwerks Inc.

import UIKit

/// Display Terms of Use document and consent
final class TermsVC: UIViewController {

    private typealias Segues = R.segue.termsVC

    // verified in requireOutlets
    @IBOutlet private var agreeButton: GradientButton!

    /// :nodoc:
    override func viewDidLoad() {
        super.viewDidLoad()

        requireOutlets()
    }

    /// :nodoc:
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        expose()
    }

    /// :nodoc:
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        report(screen: "Terms")
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
