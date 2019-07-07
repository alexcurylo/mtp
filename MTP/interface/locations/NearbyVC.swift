// @copyright Trollwerks Inc.

import CoreLocation
import UIKit

protocol NearbyCellDelegate: AnyObject {

    func dismiss()
}

final class NearbyVC: UITableViewController, ServiceProvider {

    private typealias Segues = R.segue.nearbyVC

    @IBOutlet private var backgroundView: UIView?

    private var places: [MapInfo] = []
    private var distances: Distances = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        tableView.backgroundView = backgroundView
        tableView.tableFooterView = UIView()

        tableView.estimatedRowHeight = UITableView.automaticDimension
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
        switch segue.identifier {
        case Segues.unwindFromNearby.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

// MARK: - UITableViewControllerDataSource

extension NearbyVC {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //swiftlint:disable:next implicitly_unwrapped_optional
        let cell: NearbyCell! = tableView.dequeueReusableCell(
            withIdentifier: R.reuseIdentifier.nearbyCell,
            for: indexPath)

        let place = places[indexPath.row]
        cell.set(place: place,
                 distance: distances[place.dbKey] ?? 0,
                 delegate: self)

        return cell
    }
}

// MARK: - UITableViewDelegate

extension NearbyVC {

    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView,
                            estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Injectable

extension NearbyVC: Injectable {

    typealias Model = (places: Set<MapInfo>, distances: Distances)

    @discardableResult func inject(model: Model) -> Self {
        distances = model.distances
        places = Array(model.places).sorted {
            distances[$0.dbKey] ?? 0 < distances[$1.dbKey] ?? 0
        }

        return self
    }

    func requireInjections() {
        backgroundView.require()
    }
}

// MARK: - NearbyCellDelegate

extension NearbyVC: NearbyCellDelegate {

    func dismiss() {
        performSegue(withIdentifier: Segues.unwindFromNearby,
                     sender: self)
    }
}

final class NearbyCell: UITableViewCell {

    @IBOutlet private var placeImage: UIImageView?
    @IBOutlet private var distanceLabel: UILabel?

    @IBOutlet private var categoryLabel: UILabel?
    @IBOutlet private var visitedLabel: UILabel?
    @IBOutlet private var visitSwitch: UISwitch? {
        didSet {
            visitSwitch?.styleAsFilter()
            visitSwitch?.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        }
    }
    @IBOutlet private var nameLabel: UILabel?
    @IBOutlet private var countryLabel: UILabel?
    @IBOutlet private var visitorsLabel: UILabel?

    private var place: MapInfo?
    private weak var delegate: NearbyCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(cellTapped))
        addGestureRecognizer(tap)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        place = nil
        delegate = nil

        placeImage?.prepareForReuse()
        distanceLabel?.text = nil
        categoryLabel?.text = nil
        nameLabel?.text = nil
        countryLabel?.text = nil
        visitorsLabel?.text = nil
    }

    func set(place: MapInfo,
             distance: CLLocationDistance,
             delegate: NearbyCellDelegate) {
        self.place = place
        self.delegate = delegate

        placeImage?.load(image: place)
        distanceLabel?.text = distance.formatted
        categoryLabel?.text = place.checklist.category(full: false).uppercased()
        show(visited: place.isVisited)
        nameLabel?.text = place.subtitle
        countryLabel?.text = place.country
        visitorsLabel?.text = L.visitors(place.visitors.grouped)
    }
 }

private extension NearbyCell {

    @IBAction func cellTapped(_ sender: UIButton) {
        place?.reveal(callout: true)
    }

    @IBAction func toggleVisit(_ sender: UISwitch) {
        guard let place = place else { return }

        let isVisited = sender.isOn
        place.isVisited = isVisited
        show(visited: isVisited)
    }

    func show(visited: Bool) {
        visitedLabel?.text = (visited ? L.visited() : L.notVisited()).uppercased()
        visitSwitch?.isOn = visited
    }
}
