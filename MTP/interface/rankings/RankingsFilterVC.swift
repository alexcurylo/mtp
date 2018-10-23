// @copyright Trollwerks Inc.

import UIKit

final class RankingsFilterVC: UITableViewController {

    @IBOutlet private var saveButton: UIBarButtonItem?

    @IBOutlet private var facebookSwitch: UISwitch?

    private var original: UserFilter?
    private var current: UserFilter?

    override func viewDidLoad() {
        super.viewDidLoad()

        let backgroundView: GradientView = create {
            $0.set(gradient: [.dodgerBlue, .azureRadiance],
                   orientation: .topRightBottomLeft)
        }
        tableView.backgroundView = backgroundView

         configure()
   }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        log.verbose("prepare for \(segue.name)")
        switch segue.identifier {
        case R.segue.rankingsFilterVC.saveEdits.identifier:
            saveEdits(notifying: R.segue.rankingsFilterVC.saveEdits(segue: segue)?.destination)
        case R.segue.rankingsFilterVC.cancelEdits.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

// MARK: - UITableViewDelegate

extension RankingsFilterVC {

    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView,
                            estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Private

private extension RankingsFilterVC {

    func configure() {
        let filter = gestalt.rankingsFilter ?? UserFilter()
        original = filter
        current = filter
        saveButton?.isEnabled = false

        // country/state
        // gender
        // age

        facebookSwitch?.isOn = filter.facebook
    }

    @IBAction func switchFacebook(_ sender: UISwitch) {
        current?.facebook = sender.isOn
        updateSave()
    }

    func updateSave() {
        saveButton?.isEnabled = original != current
    }

    func saveEdits(notifying controller: UIViewController?) {
        if let current = current {
            gestalt.rankingsFilter = current == UserFilter() ? nil : current
        } else {
            gestalt.rankingsFilter = nil
        }
        if let controller = controller as? RankingsVC {
            controller.updateFilter()
        } else {
            log.error("expected to return to Rankings tab")
        }
    }

}
