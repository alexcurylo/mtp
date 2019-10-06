// @copyright Trollwerks Inc.

import UIKit

/// Display successful signup message
final class WelcomeVC: UIViewController {

    private typealias Segues = R.segue.welcomeVC

    // verified in requireOutlets
    @IBOutlet private var profileButton: GradientButton!
    @IBOutlet private var laterButton: UIButton!

    /// :nodoc:
    override func viewDidLoad() {
        super.viewDidLoad()
        requireOutlets()
    }

    /// :nodoc:
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        hide(navBar: animated)
        expose()
    }

    /// :nodoc:
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        report(screen: "Welcome")
    }

    /// :nodoc:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let settings = Segues.showSettings(segue: segue)?
                                .destination {
            settings.inject(model: .editProfile)
        } else if let main = Segues.showMain(segue: segue)?
                                   .destination {
            main.inject(model: .locations)
        }
    }
}

// MARK: - Exposing

extension WelcomeVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        UIWelcome.profile.expose(item: profileButton)
        UIWelcome.later.expose(item: laterButton)
    }
}

// MARK: - InterfaceBuildable

extension WelcomeVC: InterfaceBuildable {

    /// Injection enforcement for viewDidLoad
    func requireOutlets() {
        laterButton.require()
        profileButton.require()
    }
}
