// @copyright Trollwerks Inc.

import UIKit

final class RankingsVC: UIViewController {

    @IBOutlet private var tabsHolder: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTabsHolder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        style.standard.apply()
        navigationController?.setNavigationBarHidden(false, animated: animated)
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
        case R.segue.rankingsVC.showFilter.identifier,
             R.segue.rankingsVC.showSearch.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

private extension RankingsVC {

    @IBAction func unwindToRankings(segue: UIStoryboardSegue) {
        log.verbose(segue.name)
    }

    func configureTabsHolder() {
    }
}
