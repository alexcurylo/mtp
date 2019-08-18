// @copyright Trollwerks Inc.

import RealmSwift

/// Receive notification of a Country or Location selection
protocol LocationSearchDelegate: AnyObject {

    /// Handle a location selection
    ///
    /// - Parameters:
    ///   - controller: source of selection
    ///   - item: Country or Location selected
    func locationSearch(controller: RealmSearchViewController,
                        didSelect item: Object)
}

/// Selectable list of country and location options
final class LocationSearchVC: RealmSearchViewController {

    private typealias Segues = R.segue.locationSearchVC

    /// Location selection modes
    enum Mode {
        /// Must select a country
        case country
        /// Select any or all countries
        case countryOrAll
        /// Select any or no countries
        case countryOrNone
        /// Select country or decline
        case countryOrPreferNot
        /// Must select a location
        case location(country: Int)
        /// Select any or all locations
        case locationOrAll(country: Int)
    }

    private var mode: Mode = .countryOrAll
    private var styler: Styler = .standard
    private weak var delegate: LocationSearchDelegate?

    private let backgroundView = GradientView()

    /// Handle dependency injection
    ///
    /// - Parameters:
    ///   - mode: Selection mode
    ///   - styler: Style provider
    ///   - delegate: Delegate
    func inject(mode: Mode,
                styler: Styler,
                delegate: LocationSearchDelegate) {
        self.mode = mode
        self.styler = styler
        self.delegate = delegate

        backgroundView.set(style: styler)

        configureSearch()
    }

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundView = backgroundView
        tableView.tableFooterView = UIView()

        tableView.estimatedRowHeight = 88
        tableView.rowHeight = UITableView.automaticDimension
    }

    /// Prepare for reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: styler)
        expose()
    }

    // MARK: - RealmSearchResultsDataSource

    /// Cell for Object
    ///
    /// - Parameters:
    ///   - controller: RealmSearchViewController
    ///   - object: Realm Object
    ///   - indexPath: Index path
    /// - Returns: Cell
    override func searchViewController(_ controller: RealmSearchViewController,
                                       cellForObject object: Object,
                                       atIndexPath indexPath: IndexPath) -> UITableViewCell {
        //swiftlint:disable:next implicitly_unwrapped_optional
        let cell: LocationSearchTableViewCell! = tableView.dequeueReusableCell(
            withIdentifier: R.reuseIdentifier.locationSearchTableViewCell,
            for: indexPath)

        cell.inject(mode: mode, item: object)

        return cell
    }

    // MARK: - RealmSearchResultsDelegate

    /// Did select Object
    ///
    /// - Parameters:
    ///   - controller: RealmSearchViewController
    ///   - object: Realm Object
    ///   - indexPath: Index path
    override func searchViewController(_ controller: RealmSearchViewController,
                                       didSelectObject anObject: Object,
                                       atIndexPath indexPath: IndexPath) {
        controller.tableView.deselectRow(at: indexPath, animated: true)

        delegate?.locationSearch(controller: self,
                                 didSelect: anObject)

        performSegue(withIdentifier: Segues.pop,
                     sender: self)
    }
}

// MARK: - Private

private extension LocationSearchVC {

    func configureSearch() {
        switch mode {
        case .country:
            searchPropertyKeyPath = "placeCountry"
            sortPropertyKey = "placeCountry"
            entityName = "Country"
            basePredicate = NSPredicate(format: "countryId > 0")
            title = L.selectCountry()
        case .countryOrAll,
             .countryOrNone,
             .countryOrPreferNot:
            searchPropertyKeyPath = "placeCountry"
            sortPropertyKey = "placeCountry"
            entityName = "Country"
            basePredicate = nil
            title = L.selectCountry()
        case .location(let country):
            entityName = "Location"
            searchPropertyKeyPath = "placeTitle"
            sortPropertyKey = "placeTitle"
            basePredicate = NSPredicate(format: "countryId = \(country)")
            title = L.selectLocation()
        case .locationOrAll(let country):
            entityName = "Location"
            searchPropertyKeyPath = "placeTitle"
            sortPropertyKey = "placeTitle"
            let isChild = NSPredicate(format: "countryId = \(country)")
            let isAll = NSPredicate(format: "countryId = 0")
            basePredicate = NSCompoundPredicate(
                type: .or,
                subpredicates: [isChild, isAll])
            title = L.selectLocation()
        }
    }
}

// MARK: - Exposing

extension LocationSearchVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        let items = navigationItem.leftBarButtonItems
        UILocationSearch.close.expose(item: items?.first)
    }
}

/// Display selectable item
final class LocationSearchTableViewCell: UITableViewCell {

    @IBOutlet private var locationLabel: UILabel?

    /// Configure after nib loading
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    /// Handle dependency injection
    ///
    /// - Parameters:
    ///   - mode: Selection mode
    ///   - item: Realm object to display
    func inject(mode: LocationSearchVC.Mode,
                item: Object?) {

        var countryName: String {
            return (item as? Country)?.placeCountry ?? L.unknown()
        }

        func named(orNot: String) -> String {
            switch item {
            case let country as Country:
                guard country.countryId > 0 else { return orNot }
                return country.placeCountry
            case let location as Location:
                guard location.countryId > 0 else { return orNot }
                return location.placeTitle
            default:
                return L.unknown()
            }
        }

        let name: String
        switch mode {
        case .country:
            name = countryName
        case .countryOrAll:
            name = named(orNot: L.selectCountryAll())
        case .countryOrNone:
            name = named(orNot: L.selectCountryNone())
        case .countryOrPreferNot:
            name = named(orNot: L.selectCountryPreferNot())
        case .location:
            name = named(orNot: L.unknown())
        case .locationOrAll:
            name = named(orNot: L.selectLocationAll())
        }
        locationLabel?.text = name.isEmpty ? L.unknown() : name
    }
}
