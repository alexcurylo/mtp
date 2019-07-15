// @copyright Trollwerks Inc.

import CoreLocation
import UIKit

protocol NearbyCellDelegate: AnyObject {

    func dismiss()
}

final class NearbyVC: UITableViewController, ServiceProvider {

    private typealias Segues = R.segue.nearbyVC

    @IBOutlet private var backgroundView: UIView?

    private var contentState: ContentState = .loading
    private var mappables: [Mappable] = []
    private var distances: Distances = [:]
    private var queue = OperationQueue {
        $0.name = typeName
        $0.maxConcurrentOperationCount = 1
        $0.qualityOfService = .userInteractive
    }

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
        return mappables.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //swiftlint:disable:next implicitly_unwrapped_optional
        let cell: NearbyCell! = tableView.dequeueReusableCell(
            withIdentifier: R.reuseIdentifier.nearbyCell,
            for: indexPath)

        let mappable = mappables[indexPath.row]
        cell.set(mappable: mappable,
                 distance: distances[mappable.dbKey] ?? 0,
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

    typealias Model = (mappables: [Mappable], center: CLLocationCoordinate2D)

    @discardableResult func inject(model: Model) -> Self {
        if let here = loc.here,
           !loc.distances.isEmpty {
            guard model.center.distance(from: here) > 10 else {
                set(mappables: model.mappables,
                    distances: loc.distances)
                return self
            }
        }

        let update = DistancesOperation(center: model.center,
                                        mappables: model.mappables,
                                        handler: nil,
                                        trigger: false,
                                        world: data.worldMap)
        update.completionBlock = { [weak self, model, update] in
            DispatchQueue.main.async { [weak self, model, update] in
                self?.set(mappables: model.mappables,
                          distances: update.distances)
            }
        }
        queue.addOperation(update)

        tableView.set(message: contentState)
        return self
    }

    func set(mappables: [Mappable],
             distances: Distances) {
        self.distances = distances
        self.mappables = mappables.sorted {
            distances[$0.dbKey] ?? 0 < distances[$1.dbKey] ?? 0
        }
        contentState = .data
        tableView.set(message: contentState)
        tableView.reloadData()
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

    private var mappable: Mappable?
    private weak var delegate: NearbyCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(cellTapped))
        addGestureRecognizer(tap)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        mappable = nil
        delegate = nil

        placeImage?.prepareForReuse()
        distanceLabel?.text = nil
        categoryLabel?.text = nil
        nameLabel?.text = nil
        countryLabel?.text = nil
        visitorsLabel?.text = nil
    }

    func set(mappable: Mappable,
             distance: CLLocationDistance,
             delegate: NearbyCellDelegate) {
        self.mappable = mappable
        self.delegate = delegate

        placeImage?.load(image: mappable)
        distanceLabel?.text = distance.formatted
        categoryLabel?.text = mappable.checklist.category(full: false).uppercased()
        show(visited: mappable.isVisited)
        nameLabel?.text = mappable.title
        countryLabel?.text = mappable.subtitle
        visitorsLabel?.text = L.visitors(mappable.visitors.grouped)
    }
 }

private extension NearbyCell {

    @IBAction func cellTapped(_ sender: UIButton) {
        mappable?.reveal(callout: true)
    }

    @IBAction func toggleVisit(_ sender: UISwitch) {
        guard let mappable = mappable else { return }

        let isVisited = sender.isOn
        mappable.isVisited = isVisited
        show(visited: isVisited)
    }

    func show(visited: Bool) {
        visitedLabel?.text = (visited ? L.visited() : L.notVisited()).uppercased()
        visitSwitch?.isOn = visited
    }
}
