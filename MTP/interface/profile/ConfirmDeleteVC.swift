// @copyright Trollwerks Inc.

import UIKit

/// Full screen dialog to confirm account deletion
final class ConfirmDeleteVC: UIViewController, ServiceProvider {

    private typealias Segues = R.segue.confirmDeleteVC

    // verified in requireOutlets
    @IBOutlet private var confirmButton: UIButton!
    @IBOutlet private var cancelButton: GradientButton!

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireOutlets()
        expose()
    }
}

// MARK: - Exposing

extension ConfirmDeleteVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        UIConfirmDelete.cancel.expose(item: cancelButton)
        UIConfirmDelete.confirm.expose(item: confirmButton)
    }
}

// MARK: - InterfaceBuildable

extension ConfirmDeleteVC: InterfaceBuildable {

    /// Injection enforcement for viewDidLoad
    func requireOutlets() {
        cancelButton.require()
        confirmButton.require()
    }
}
