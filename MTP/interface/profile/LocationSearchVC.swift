// @copyright Trollwerks Inc.

import RealmSwift

protocol LocationSearchDelegate: AnyObject {

    func locationSearch(controller: RealmSearchViewController,
                        didSelect item: Object)
}

final class LocationSearchVC: RealmSearchViewController, ServiceProvider {

    private typealias Segues = R.segue.locationSearchVC

    enum List {
        case countries
        case country
        case countryOrNot
        case location(country: Int?)
        case locations(country: Int?)
    }

    private var list: List = .countries
    private var styler: Styler = .standard
    private weak var delegate: LocationSearchDelegate?

    private let backgroundView = GradientView()

    func set(list: List,
             styler: Styler,
             delegate: LocationSearchDelegate) {
        self.list = list
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

        cell.set(list: list, item: object)

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
        switch list {
        case .countries, .countryOrNot:
            searchPropertyKeyPath = "placeCountry"
            sortPropertyKey = "placeCountry"
            entityName = "Country"
            basePredicate = nil

            title = L.selectCountry()
        case .country:
            searchPropertyKeyPath = "placeCountry"
            sortPropertyKey = "placeCountry"
            entityName = "Country"
            basePredicate = NSPredicate(format: "countryId > 0")

            title = L.selectCountry()
        case let .location(country?):
            entityName = "Location"
            searchPropertyKeyPath = "placeTitle"
            sortPropertyKey = "placeTitle"
            basePredicate = NSPredicate(format: "countryId = \(country)")

            title = L.selectLocation()
        case .location:
            entityName = "Location"
            searchPropertyKeyPath = "placeTitle"
            sortPropertyKey = "placeTitle"
            basePredicate = NSPredicate(format: "countryId > 0")

            title = L.selectLocation()
        case let .locations(country?):
            entityName = "Location"
            searchPropertyKeyPath = "placeTitle"
            sortPropertyKey = "placeTitle"
            let isChild = NSPredicate(format: "countryId = \(country)")
            let isAll = NSPredicate(format: "countryId = 0")
            basePredicate = NSCompoundPredicate(
                type: .or,
                subpredicates: [isChild, isAll])

            title = L.selectLocation()
        case .locations:
            entityName = "Location"
            searchPropertyKeyPath = "placeTitle"
            sortPropertyKey = "placeTitle"

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

    func set(list: LocationSearchVC.List,
             item: Object?) {

        var countryName: String? {
            return (item as? Country)?.placeCountry
        }

        func named(orNot: String) -> String? {
            guard let country = item as? Country else { return nil }
            guard country.countryId > 0 else { return orNot }
            return country.placeCountry
        }

        let text: String?
        switch list {
        case .countries:
            text = named(orNot: L.selectCountryAll())
        case .countryOrNot:
            text = named(orNot: L.selectCountryNone())
        case .country:
            text = countryName
        case .location,
             .locations:
            text = (item as? Location)?.placeTitle
        }
        locationLabel?.text = text ?? L.unknown()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
