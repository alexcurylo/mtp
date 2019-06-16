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
        let cell = tableView.dequeueReusableCell(
            withIdentifier: R.reuseIdentifier.locationSearchTableViewCell,
            for: indexPath)

        if let cell = cell {
            cell.set(list: list, item: object)
            return cell
        }
        return UITableViewCell()
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
        case .countries:
            searchPropertyKeyPath = "countryName"
            sortPropertyKey = "countryName"
            entityName = "Country"
            basePredicate = nil

            title = Localized.selectCountry()
        case .country:
            searchPropertyKeyPath = "countryName"
            sortPropertyKey = "countryName"
            entityName = "Country"
            basePredicate = NSPredicate(format: "countryId > 0")

            title = Localized.selectCountry()
        case let .location(country?):
            entityName = "Location"
            searchPropertyKeyPath = "locationName"
            sortPropertyKey = "locationName"
            basePredicate = NSPredicate(format: "countryId = \(country)")

            title = Localized.selectLocation()
        case .location:
            entityName = "Location"
            searchPropertyKeyPath = "locationName"
            sortPropertyKey = "locationName"
            basePredicate = NSPredicate(format: "countryId > 0")

            title = Localized.selectLocation()
        case let .locations(country?):
            entityName = "Location"
            searchPropertyKeyPath = "locationName"
            sortPropertyKey = "locationName"
            let isChild = NSPredicate(format: "countryId = \(country)")
            let isAll = NSPredicate(format: "countryId = 0")
            basePredicate = NSCompoundPredicate(
                type: .or,
                subpredicates: [isChild, isAll])

            title = Localized.selectLocation()
        case .locations:
            entityName = "Location"
            searchPropertyKeyPath = "locationName"
            sortPropertyKey = "locationName"

            title = Localized.selectLocation()
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
        let text: String?
        switch list {
        case .countries,
             .country:
            text = (item as? Country)?.countryName ?? Localized.unknown()
        case .location,
             .locations:
            text = (item as? Location)?.locationName ?? Localized.unknown()
        }
        locationLabel?.text = text ?? Localized.unknown()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
