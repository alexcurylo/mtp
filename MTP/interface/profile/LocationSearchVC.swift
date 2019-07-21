// @copyright Trollwerks Inc.

import RealmSwift

protocol LocationSearchDelegate: AnyObject {

    func locationSearch(controller: RealmSearchViewController,
                        didSelect item: Object)
}

final class LocationSearchVC: RealmSearchViewController, ServiceProvider {

    private typealias Segues = R.segue.locationSearchVC

    enum Search {
        case country
        case countryOrAll
        case countryOrNone
        case location(country: Int)
        case locationOrAll(country: Int)
    }

    private var search: Search = .countryOrAll
    private var styler: Styler = .standard
    private weak var delegate: LocationSearchDelegate?

    private let backgroundView = GradientView()

    func set(search: Search,
             styler: Styler,
             delegate: LocationSearchDelegate) {
        self.search = search
        self.styler = styler
        self.delegate = delegate

        backgroundView.set(style: styler)

        configureSearch()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        tableView.backgroundView = backgroundView
        tableView.tableFooterView = UIView()

        tableView.estimatedRowHeight = 88
        tableView.rowHeight = UITableView.automaticDimension
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: styler)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.pop.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }

    // MARK: - RealmSearchResultsDataSource

    override func searchViewController(_ controller: RealmSearchViewController,
                                       cellForObject object: Object,
                                       atIndexPath indexPath: IndexPath) -> UITableViewCell {
        //swiftlint:disable:next implicitly_unwrapped_optional
        let cell: LocationSearchTableViewCell! = tableView.dequeueReusableCell(
            withIdentifier: R.reuseIdentifier.locationSearchTableViewCell,
            for: indexPath)

        cell.set(search: search, item: object)

        return cell
    }

    // MARK: - RealmSearchResultsDelegate

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

private extension LocationSearchVC {

    func configureSearch() {
        switch search {
        case .country:
            searchPropertyKeyPath = "placeCountry"
            sortPropertyKey = "placeCountry"
            entityName = "Country"
            basePredicate = NSPredicate(format: "countryId > 0")
            title = L.selectCountry()
        case .countryOrAll, .countryOrNone:
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

extension LocationSearchVC: Injectable {

    typealias Model = ()

    @discardableResult func inject(model: Model) -> Self {
        return self
    }

    func requireInjections() {
    }
}

final class LocationSearchTableViewCell: UITableViewCell {

    @IBOutlet private var locationLabel: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func set(search: LocationSearchVC.Search,
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
        switch search {
        case .country:
            name = countryName
        case .countryOrAll:
            name = named(orNot: L.selectCountryAll())
        case .countryOrNone:
            name = named(orNot: L.selectCountryNone())
        case .location:
            name = named(orNot: L.unknown())
        case .locationOrAll:
            name = named(orNot: L.selectLocationAll())
        }
        locationLabel?.text = name.isEmpty ? L.unknown() : name
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
