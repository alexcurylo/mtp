// @copyright Trollwerks Inc.

import RealmSwift

/// Selection dialog for POI types to show
final class LocationsFilterVC: UITableViewController, ServiceProvider {

    private typealias Segues = R.segue.locationsFilterVC

    @IBOutlet private var saveButton: UIBarButtonItem?
    @IBOutlet private var locationsSwitch: UISwitch?
    @IBOutlet private var whsSwitch: UISwitch?
    @IBOutlet private var beachesSwitch: UISwitch?
    @IBOutlet private var golfCoursesSwitch: UISwitch?
    @IBOutlet private var diveSitesSwitch: UISwitch?
    @IBOutlet private var restaurantsSwitch: UISwitch?

    private var original = ChecklistFlags()
    private var current = ChecklistFlags()

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        let backgroundView = GradientView {
            $0.set(gradient: [.dodgerBlue, .azureRadiance],
                   orientation: .topRightBottomLeft)
        }
        tableView.backgroundView = backgroundView

        configure()
    }

    /// Prepare for reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .standard)
    }

    /// Instrument and inject navigation
    ///
    /// - Parameters:
    ///   - segue: Navigation action
    ///   - sender: Action originator
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.saveEdits.identifier:
            saveEdits(notifying: Segues.saveEdits(segue: segue)?.destination)
        case Segues.cancelEdits.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

// MARK: - Private

private extension LocationsFilterVC {

    @IBAction func unwindToLocations(segue: UIStoryboardSegue) {
    }

    func configure() {
        let filter = data.mapDisplay
        original = filter
        current = filter

        locationsSwitch?.isOn = filter.locations
        whsSwitch?.isOn = filter.whss
        beachesSwitch?.isOn = filter.beaches
        golfCoursesSwitch?.isOn = filter.golfcourses
        diveSitesSwitch?.isOn = filter.divesites
        restaurantsSwitch?.isOn = filter.restaurants

        saveButton?.isEnabled = false
    }

    func updateSave() {
        saveButton?.isEnabled = original != current
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
}

// MARK: - Injectable

extension LocationsFilterVC: Injectable {

    /// Injected dependencies
    typealias Model = ()

    /// Handle dependency injection
    ///
    /// - Parameter model: Dependencies
    /// - Returns: Chainable self
    @discardableResult func inject(model: Model) -> Self {
        return self
    }

    /// Enforce dependency injection
    func requireInjections() {
        saveButton.require()
        locationsSwitch.require()
        whsSwitch.require()
        beachesSwitch.require()
        golfCoursesSwitch.require()
        diveSitesSwitch.require()
        restaurantsSwitch.require()
    }
}
