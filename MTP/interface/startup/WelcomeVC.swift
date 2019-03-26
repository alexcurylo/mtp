// @copyright Trollwerks Inc.

import UIKit

final class WelcomeVC: UIViewController, ServiceProvider {

    private typealias Segues = R.segue.welcomeVC

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        hide(navBar: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        log.verbose("prepare for \(segue.name)")
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

    typealias Model = ()

    func inject(model: Model) {
    }

    func requireInjections() {
    }
}
