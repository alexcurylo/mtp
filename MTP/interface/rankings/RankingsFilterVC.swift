// @copyright Trollwerks Inc.

import UIKit

final class RankingsFilterVC: UITableViewController, ServiceProvider {

    @IBOutlet private var saveButton: UIBarButtonItem?

    @IBOutlet private var countryLabel: UILabel?
    @IBOutlet private var locationLabel: UILabel?

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

    typealias Segues = R.segue.rankingsFilterVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        log.verbose("prepare for \(segue.name)")
        switch segue.identifier {
        case Segues.showCountry.identifier:
            if let destination = Segues.showCountry(segue: segue)?.destination {
                destination.delegate = self
                destination.basePredicate = NSPredicate(format: "countryName = locationName")
            }
        case Segues.showLocation.identifier:
            if let destination = Segues.showLocation(segue: segue)?.destination {
                destination.delegate = self
                if let parent = current?.countryId, parent > 0 {
                    destination.basePredicate = NSPredicate(format: "countryId = \(parent) AND countryId != id")
                }
            }
        case Segues.saveEdits.identifier:
            saveEdits(notifying: Segues.saveEdits(segue: segue)?.destination)
        case Segues.cancelEdits.identifier:
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

extension RankingsFilterVC: LocationSearchDelegate {

    func locationSearch(controller: RealmSearchViewController,
                        didSelect location: Location) {
        log.todo("configure location or country selection")
        current?.countryId = location.countryId
        current?.locationId = location.id
        configureLocation()
        updateSave()
    }
}

// MARK: - Private

private extension RankingsFilterVC {

    @IBAction func unwindToRankingsFilter(segue: UIStoryboardSegue) {
        log.verbose(segue.name)
    }

    func configure() {
        let filter = data.lastRankingsQuery
        original = filter
        current = filter
        saveButton?.isEnabled = false

        configureLocation()

        femaleButton?.isSelected = filter.gender == .female
        maleAndFemaleButton?.isSelected = filter.gender == .all
        maleButton?.isSelected = filter.gender == .male

        ageSlider?.value = Float(filter.ageGroup.rawValue)
        ageLabel?.text = filter.ageGroup.description

        facebookSwitch?.isOn = filter.facebookConnected
    }

    func configureLocation() {
        log.todo("configure location or country display")
        let country = data.get(location: current?.countryId)
        countryLabel?.text = country?.countryName ?? Localized.allLocations()

        let location = data.get(location: current?.locationId)
        locationLabel?.text = location?.locationName ?? Localized.allLocations()
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
