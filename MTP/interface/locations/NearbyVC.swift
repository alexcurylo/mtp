// @copyright Trollwerks Inc.

import CoreLocation
import UIKit

protocol NearbyCellDelegate: AnyObject {

    func dismiss()
}

final class NearbyVC: UITableViewController, ServiceProvider {

    private typealias Segues = R.segue.nearbyVC

    @IBOutlet private var backgroundView: UIView?

    private var places: [PlaceAnnotation] = []

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
        log.verbose("prepare for \(segue.name)")
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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: R.reuseIdentifier.nearbyCell,
            for: indexPath) ?? NearbyCell()

        cell.set(model: places[indexPath.row],
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

    typealias Model = (center: CLLocation?,
                       annotations: [Set<PlaceAnnotation>])

    @discardableResult func inject(model: Model) -> Self {
        places = model.annotations.flatMap { Array($0) }
        if let center = model.center {
            places.forEach { $0.setDistance(from: center, trigger: false) }
        }
        places.sort { $0.distance < $1.distance }

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

    private weak var delegate: NearbyCellDelegate?
    private var place: PlaceAnnotation?

    override func awakeFromNib() {
        super.awakeFromNib()

        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(cellTapped))
        addGestureRecognizer(tap)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        delegate = nil
        place = nil
        placeImage?.prepareForReuse()
        distanceLabel?.text = nil
        categoryLabel?.text = nil
        nameLabel?.text = nil
        countryLabel?.text = nil
        visitorsLabel?.text = nil
    }

    func set(model place: PlaceAnnotation,
             delegate: NearbyCellDelegate) {
        self.delegate = delegate
        self.place = place

        placeImage?.load(image: place)
        distanceLabel?.text = place.formattedDistance
        categoryLabel?.text = place.list.category.uppercased()
        show(visited: place.isVisited)
        nameLabel?.text = place.subtitle
        countryLabel?.text = place.country
        visitorsLabel?.text = Localized.visitors(place.visitors.grouped)
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
        visitedLabel?.text = (visited ? Localized.visited() :            Localized.notVisited()).uppercased()
        visitSwitch?.isOn = visited
    }
}
