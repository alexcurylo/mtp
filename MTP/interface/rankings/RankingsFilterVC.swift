// @copyright Trollwerks Inc.

import RealmSwift

final class RankingsFilterVC: UITableViewController, ServiceProvider {

    @IBOutlet private var saveButton: UIBarButtonItem?

    @IBOutlet private var locationStack: UIStackView?
    @IBOutlet private var locationLine: UIStackView?
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

        let backgroundView = GradientView {
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
                destination.set(list: .countries,
                                delegate: self)
            }
        case Segues.showLocation.identifier:
            if let destination = Segues.showLocation(segue: segue)?.destination {
                let country = current?.countryId
                destination.set(list: .locations(country: country),
                                delegate: self)
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
                        didSelect item: Object) {
        guard current?.update(with: item) ?? false else { return }

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
        let countryId = current?.countryId ?? 0
        let country = countryId > 0 ? data.get(country: countryId) : nil
        countryLabel?.text = country?.countryName ?? Localized.allCountries()
        guard country?.hasChildren ?? false else {
            locationLabel?.text = countryLabel?.text
            return
        }

        let locationId = current?.locationId ?? 0
        let location = locationId > 0 ? data.get(location: locationId) : nil
        locationLabel?.text = location?.locationName ?? Localized.allLocations()

        log.todo("collapses and draws on top of each other")
/*
        guard let locationLine = locationLine else { return }
        if let location = location, location.isParent {
            locationStack?.addArrangedSubview(locationLine)
        } else {
            locationStack?.removeArrangedSubview(locationLine)
        }
        tableView.reloadData()
 */
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
