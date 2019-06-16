// @copyright Trollwerks Inc.

import RealmSwift

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .standard)
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

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
        if current != original {
            data.mapDisplay = current
        }
        if let controller = controller as? LocationsVC {
            controller.updateFilter()
        } else {
            log.error("expected to return to Locations tab")
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

extension LocationsFilterVC: Injectable {

    typealias Model = ()

    @discardableResult func inject(model: Model) -> Self {
        return self
    }

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
