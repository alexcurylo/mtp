// @copyright Trollwerks Inc.

import UIKit

final class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        log.warning("INFO: \(type(of: self)) applicationDidReceiveMemoryWarning")
        super.didReceiveMemoryWarning()
    }
}
