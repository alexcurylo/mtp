// @copyright Trollwerks Inc.

import UIKit

/// Display successful signup message
final class WelcomeVC: UIViewController, ServiceProvider {

    private typealias Segues = R.segue.welcomeVC

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

        hide(navBar: animated)
    }

    /// Instrument and inject navigation
    ///
    /// - Parameters:
    ///   - segue: Navigation action
    ///   - sender: Action originator
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.showSettings.identifier:
            let settings = Segues.showSettings(segue: segue)
            settings?.destination.inject(model: .editProfile)
        case Segues.showMain.identifier:
            let main = Segues.showMain(segue: segue)
            main?.destination.inject(model: .locations)
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

extension WelcomeVC: Injectable {

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
    func requireInjections() { }
}
