// @copyright Trollwerks Inc.

import UIKit

final class RankingsFilterVC: UITableViewController, ServiceProvider {

    @IBOutlet private var saveButton: UIBarButtonItem?

    @IBOutlet private var femaleButton: UIButton?
    @IBOutlet private var maleAndFemaleButton: UIButton?
    @IBOutlet private var maleButton: UIButton?

    @IBOutlet private var ageSlider: UISlider?
    @IBOutlet private var ageLabel: UILabel?

    @IBOutlet private var facebookSwitch: UISwitch?

    private var original: RankingsQuery?
    private var current: RankingsQuery?

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
        let filter = data.lastRankingsQuery
        original = filter
        current = filter
        saveButton?.isEnabled = false

        log.todo("configure filter")
        // country/state

        femaleButton?.isSelected = filter.gender == .female
        maleAndFemaleButton?.isSelected = filter.gender == .all
        maleButton?.isSelected = filter.gender == .male

        ageSlider?.value = Float(filter.ageGroup.rawValue)
        ageLabel?.text = filter.ageGroup.description

        facebookSwitch?.isOn = filter.facebookConnected
    }

    @IBAction func selectFemale(_ sender: UIButton) {
        femaleButton?.isSelected = true
        maleAndFemaleButton?.isSelected = false
        maleButton?.isSelected = false
        current?.gender = .female
        updateSave()
   }

    @IBAction func selectMale(_ sender: UIButton) {
        femaleButton?.isSelected = false
        maleAndFemaleButton?.isSelected = false
        maleButton?.isSelected = true
        current?.gender = .male
        updateSave()
    }

    @IBAction func selectMaleAndFemale(_ sender: UIButton) {
        femaleButton?.isSelected = false
        maleAndFemaleButton?.isSelected = true
        maleButton?.isSelected = false
        current?.gender = .all
        updateSave()
    }

    @IBAction func slideAge(_ sender: UISlider) {
        let ageGroup = Age(rawValue: Int(sender.value)) ?? .all
        ageLabel?.text = ageGroup.description
        current?.ageGroup = ageGroup
        updateSave()
  }

    @IBAction func switchFacebook(_ sender: UISwitch) {
        current?.facebookConnected = sender.isOn
        updateSave()
    }

    func updateSave() {
        saveButton?.isEnabled = original != current
    }

    func saveEdits(notifying controller: UIViewController?) {
        if let current = current, current != original {
            data.lastRankingsQuery = current
        }
        if let controller = controller as? RankingsVC {
            controller.updateFilter()
        } else {
            log.error("expected to return to Rankings tab")
        }
    }
}
