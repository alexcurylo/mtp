// @copyright Trollwerks Inc.

import Parchment
import UIKit

final class MyProfileTabsVC: FixedPagingViewController {

    init() {
        let storyboard = UIStoryboard(name: "About", bundle: nil)
        let about = storyboard.instantiateViewController(withIdentifier: "About")

        super.init(viewControllers: [about])
    }

    required init?(coder: NSCoder) {
        super.init(viewControllers: [])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}
