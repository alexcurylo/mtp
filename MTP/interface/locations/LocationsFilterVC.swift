// @copyright Trollwerks Inc.

import RealmSwift

/// Selection dialog for POI types to show
final class LocationsFilterVC: UITableViewController {

    private typealias Segues = R.segue.locationsFilterVC

    // verified in requireOutlets
    @IBOutlet private var closeButton: UIBarButtonItem!
    @IBOutlet private var saveButton: UIBarButtonItem!
    @IBOutlet private var locationsSwitch: UISwitch!
    @IBOutlet private var whsSwitch: UISwitch!
    @IBOutlet private var beachesSwitch: UISwitch!
    @IBOutlet private var golfCoursesSwitch: UISwitch!
    @IBOutlet private var diveSitesSwitch: UISwitch!
    @IBOutlet private var restaurantsSwitch: UISwitch!
    @IBOutlet private var hotelsSwitch: UISwitch!

    private var original = ChecklistFlags()
    private var current = ChecklistFlags()

    /// :nodoc:
    override func viewDidLoad() {
        super.viewDidLoad()
        requireOutlets()

        let backgroundView = GradientView {
            $0.set(gradient: [.dodgerBlue, .azureRadiance],
                   orientation: .topRightBottomLeft)
        }
        tableView.backgroundView = backgroundView

        configure()
    }

    /// :nodoc:
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .standard)
        expose()
    }

    /// :nodoc:
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        report(screen: "Locations Filter")
    }

    /// :nodoc:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let target = Segues.saveEdits(segue: segue)?
                              .destination {
            saveEdits(notifying: target)
        }
    }
}

// MARK: - Private

private extension LocationsFilterVC {

    @IBAction func unwindToLocations(segue: UIStoryboardSegue) { }

    func configure() {
        let filter = data.mapDisplay
        original = filter
        current = filter

        locationsSwitch.isOn = filter.locations
        whsSwitch.isOn = filter.whss
        beachesSwitch.isOn = filter.beaches
        golfCoursesSwitch.isOn = filter.golfcourses
        diveSitesSwitch.isOn = filter.divesites
        restaurantsSwitch.isOn = filter.restaurants
        hotelsSwitch.isOn = filter.hotels

        saveButton.isEnabled = false
    }

    func updateSave() {
        saveButton.isEnabled = original != current
    }

    func saveEdits(notifying controller: UIViewController?) {
        guard current != original else { return }

        data.mapDisplay = current
        if let controller = controller as? LocationsVC {
            controller.updateFilter()
        }
    }

    @IBAction func switchLocations(_ sender: UISwitch) {
        current.locations.toggle()
        updateSave()
    }

    @IBAction func switchWHS(_ sender: UISwitch) {
        current.whss.toggle()
        updateSave()
    }

    @IBAction func switchBeaches(_ sender: UISwitch) {
        current.beaches.toggle()
        updateSave()
    }

    @IBAction func switchGolfCourses(_ sender: UISwitch) {
        current.golfcourses.toggle()
        updateSave()
    }

    @IBAction func switchDiveSites(_ sender: UISwitch) {
        current.divesites.toggle()
        updateSave()
    }

    @IBAction func switchRestaurants(_ sender: UISwitch) {
        current.restaurants.toggle()
        updateSave()
    }

    @IBAction func switchHotels(_ sender: UISwitch) {
        current.hotels.toggle()
        updateSave()
    }
}

// MARK: - Exposing

extension LocationsFilterVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        UILocationsFilter.close.expose(item: closeButton)
    }
}

// MARK: - InterfaceBuildable

extension LocationsFilterVC: InterfaceBuildable {

    /// Injection enforcement for viewDidLoad
    func requireOutlets() {
        beachesSwitch.require()
        closeButton.require()
        diveSitesSwitch.require()
        golfCoursesSwitch.require()
        locationsSwitch.require()
        restaurantsSwitch.require()
        hotelsSwitch.require()
        saveButton.require()
        whsSwitch.require()
    }
}
