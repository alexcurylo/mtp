// @copyright Trollwerks Inc.

import UIKit

/// Display Terms of Use document and consent
final class TermsVC: UIViewController, ServiceProvider {

    private typealias Segues = R.segue.termsVC

    @IBOutlet private var agreeButton: GradientButton?

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()

        requireInjections()
    }

    /// Prepare for reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        expose()
    }

    /// Instrument and inject navigation
    ///
    /// - Parameters:
    ///   - segue: Navigation action
    ///   - sender: Action originator
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.acceptTermsOfUse.identifier,
             Segues.popTermsOfService.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
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

// MARK: - Injectable

extension TermsVC: Injectable {

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
        agreeButton.require()
    }
}
