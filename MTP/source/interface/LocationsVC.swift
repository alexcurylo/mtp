// @copyright Trollwerks Inc.

import UIKit

final class LocationsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        log.warning("INFO: \(type(of: self)) applicationDidReceiveMemoryWarning")
        super.didReceiveMemoryWarning()
    }
}
