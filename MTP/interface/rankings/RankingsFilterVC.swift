// @copyright Trollwerks Inc.

import RealmSwift

/// Handles selection of rankings criteria
final class RankingsFilterVC: UITableViewController {

    private typealias Segues = R.segue.rankingsFilterVC

    // verified in requireOutlets
    @IBOutlet private var closeButton: UIBarButtonItem!
    @IBOutlet private var saveButton: UIBarButtonItem!
    @IBOutlet private var locationStack: UIStackView!
    @IBOutlet private var locationLine: UIStackView!
    @IBOutlet private var countryLabel: UILabel!
    @IBOutlet private var locationLabel: UILabel!
    @IBOutlet private var femaleButton: UIButton!
    @IBOutlet private var maleAndFemaleButton: UIButton!
    @IBOutlet private var maleButton: UIButton!
    @IBOutlet private var ageSlider: UISlider!
    @IBOutlet private var ageLabel: UILabel!
    @IBOutlet private var facebookSwitch: UISwitch!

    private var original: RankingsQuery?
    private var current: RankingsQuery?

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireOutlets()

        let backgroundView = GradientView {
            $0.set(gradient: [.dodgerBlue, .azureRadiance],
                   orientation: .topRightBottomLeft)
        }
        tableView.backgroundView = backgroundView

        configure()
        expose()
   }

    /// Actions to take after reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        report(screen: "Rankings Filter")
    }

    /// Instrument and inject navigation
    ///
    /// - Parameters:
    ///   - segue: Navigation action
    ///   - sender: Action originator
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let target = Segues.showCountry(segue: segue)?
                              .destination
                              .topViewController as? LocationSearchVC {
            target.inject(mode: .countryOrAll,
                          styler: .standard,
                          delegate: self)
        } else if let target = Segues.showLocation(segue: segue)?
                                     .destination
                                     .topViewController as? LocationSearchVC,
                  let countryId = current?.countryId {
            target.inject(mode: .locationOrAll(country: countryId),
                          styler: .standard,
                          delegate: self)
        } else if let target = Segues.saveEdits(segue: segue)?
                                     .destination {
            saveEdits(notifying: target)
        }
    }
}

// MARK: - UITableViewDelegate

extension RankingsFilterVC {

    /// :nodoc:
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    /// :nodoc:
    override func tableView(_ tableView: UITableView,
                            estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension RankingsFilterVC: LocationSearchDelegate {

    /// Handle a location selection
    ///
    /// - Parameters:
    ///   - controller: source of selection
    ///   - item: Country or Location selected
    func locationSearch(controller: RealmSearchViewController,
                        didSelect item: Object) {
        guard current?.update(with: item) ?? false else { return }

        configureLocation()
        updateSave()
    }
}

// MARK: - Private

private extension RankingsFilterVC {

    func configure() {
        let filter = data.lastRankingsQuery
        original = filter
        current = filter
        saveButton.isEnabled = false

        configureLocation()

        femaleButton.centerImageAndLabel(gap: 8, imageOnTop: true)
        femaleButton.set(tintedSelection: filter.gender == .female)
        maleAndFemaleButton.centerImageAndLabel(gap: 8, imageOnTop: true)
        maleAndFemaleButton.set(tintedSelection: filter.gender == .all)
        maleButton.centerImageAndLabel(gap: 8, imageOnTop: true)
        maleButton.set(tintedSelection: filter.gender == .male)

        ageSlider.value = Float(filter.ageGroup.rawValue)
        ageLabel.text = filter.ageGroup.description

        facebookSwitch.isOn = filter.facebookConnected
    }

    func configureLocation() {
        let countryId = current?.countryId ?? 0
        let country = countryId > 0 ? data.get(country: countryId) : nil
        countryLabel.text = country?.placeCountry ?? L.allCountries()

        let locationId = current?.locationId ?? 0
        let location = locationId > 0 ? data.get(location: locationId) : nil

        if let country = country, country.hasChildren {
            locationLabel.text = location?.placeTitle ?? L.allLocations()

            locationStack.addArrangedSubview(locationLine)
        } else {
            locationLabel.text = countryLabel.text

            locationStack.removeArrangedSubview(locationLine)
            locationLine.removeFromSuperview()
        }
        tableView.reloadData()
   }

    @IBAction func selectFemale(_ sender: UIButton) {
        femaleButton.set(tintedSelection: true)
        maleAndFemaleButton.set(tintedSelection: false)
        maleButton.set(tintedSelection: false)
        current?.gender = .female
        updateSave()
   }

    @IBAction func selectMale(_ sender: UIButton) {
        femaleButton.set(tintedSelection: false)
        maleAndFemaleButton.set(tintedSelection: false)
        maleButton.set(tintedSelection: true)
        current?.gender = .male
        updateSave()
    }

    @IBAction func selectMaleAndFemale(_ sender: UIButton) {
        femaleButton.set(tintedSelection: false)
        maleAndFemaleButton.set(tintedSelection: true)
        maleButton.set(tintedSelection: false)
        current?.gender = .all
        updateSave()
    }

    @IBAction func slideAge(_ sender: UISlider) {
        let newValue = sender.value.rounded()
        sender.setValue(newValue, animated: false)
        let ageGroup = Age(rawValue: Int(newValue)) ?? .all
        ageLabel.text = ageGroup.description
        current?.ageGroup = ageGroup
        updateSave()
  }

    @IBAction func switchFacebook(_ sender: UISwitch) {
        current?.facebookConnected = sender.isOn
        updateSave()
    }

    func updateSave() {
        saveButton.isEnabled = original != current
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

// MARK: - Exposing

extension RankingsFilterVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        UIRankingsFilter.close.expose(item: closeButton)
    }
}

// MARK: - InterfaceBuildable

extension RankingsFilterVC: InterfaceBuildable {

    /// Injection enforcement for viewDidLoad
    func requireOutlets() {
        ageLabel.require()
        ageSlider.require()
        closeButton.require()
        countryLabel.require()
        facebookSwitch.require()
        femaleButton.require()
        locationLabel.require()
        locationLine.require()
        locationStack.require()
        maleAndFemaleButton.require()
        maleButton.require()
        saveButton.require()
    }
}
