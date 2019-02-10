// @copyright Trollwerks Inc.

import RealmSwift

protocol LocationSearchDelegate: AnyObject {

    func locationSearch(controller: RealmSearchViewController,
                        didSelect item: Object)
}

final class LocationSearchVC: RealmSearchViewController, ServiceProvider {

    enum List {
        case countries
        case locations(country: Int?)
    }

    private var list: List = .countries
    private weak var delegate: LocationSearchDelegate?

    func set(list: List, delegate: LocationSearchDelegate) {
        self.list = list
        self.delegate = delegate

        switch list {
        case .countries:
            searchPropertyKeyPath = "countryName"
            sortPropertyKey = "countryName"
            entityName = "Country"
            basePredicate = nil

            title = Localized.selectCountry()
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

    override func viewDidLoad() {
        super.viewDidLoad()

        let backgroundView = GradientView {
            $0.set(gradient: [.dodgerBlue, .azureRadiance],
                   orientation: .topRightBottomLeft)
        }
        tableView.backgroundView = backgroundView
        tableView.tableFooterView = UIView()

        tableView.estimatedRowHeight = 88
        tableView.rowHeight = UITableView.automaticDimension
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .standard)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        log.verbose("prepare for \(segue.name)")
        switch segue.identifier {
        case R.segue.rankingsVC.showFilter.identifier,
             R.segue.rankingsVC.showSearch.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }

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

    override func searchViewController(_ controller: RealmSearchViewController,
                                       didSelectObject anObject: Object,
                                       atIndexPath indexPath: IndexPath) {
        controller.tableView.deselectRow(at: indexPath, animated: true)

        delegate?.locationSearch(controller: self,
                                 didSelect: anObject)

        performSegue(withIdentifier: R.segue.locationSearchVC.saveSelection,
                     sender: self)
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
        case .countries:
            text = (item as? Country)?.countryName ?? Localized.unknown()
        case .locations:
            text = (item as? Location)?.locationName ?? Localized.unknown()
        }
        locationLabel?.text = text ?? Localized.unknown()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
