// @copyright Trollwerks Inc.

import CoreLocation
import UIKit

private protocol NearbyCellDelegate: AnyObject {

    func dismiss()
}

/// Lists POI by distance from map center
final class NearbyVC: UITableViewController, ServiceProvider {

    private typealias Segues = R.segue.nearbyVC

    // verified in requireOutlets
    @IBOutlet private var closeButtonItem: UIBarButtonItem!
    @IBOutlet private var backgroundView: UIView!

    private var contentState: ContentState = .loading
    private var mappables: [Mappable] = []
    private var distances: Distances = [:]
    private var queue = OperationQueue {
        $0.name = typeName
        $0.maxConcurrentOperationCount = 1
        $0.qualityOfService = .userInteractive
    }

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireOutlets()
        requireInjection()

        tableView.backgroundView = backgroundView
        tableView.tableFooterView = UIView()

        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
    }

    /// Prepare for reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .standard)
        expose()
    }
}

// MARK: - Private

private extension NearbyVC {

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
}

// MARK: - UITableViewControllerDataSource

extension NearbyVC {

    /// Number of sections
    ///
    /// - Parameter tableView: UITableView
    /// - Returns: Number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    /// Number of rows in section
    ///
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - section: Section
    /// - Returns: Number of rows in section
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return mappables.count
    }

    /// Create table cell
    ///
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - indexPath: Index Path
    /// - Returns: UITableViewCell
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //swiftlint:disable:next implicitly_unwrapped_optional
        let cell: NearbyCell! = tableView.dequeueReusableCell(
            withIdentifier: R.reuseIdentifier.nearbyCell,
            for: indexPath)

        let mappable = mappables[indexPath.row]
        cell.inject(mappable: mappable,
                    distance: distances[mappable.dbKey] ?? 0,
                    delegate: self)
        expose(view: tableView,
               path: indexPath,
               cell: cell)

        return cell
    }
}

// MARK: - UITableViewDelegate

extension NearbyVC {

    /// Provide row height
    ///
    /// - Parameters:
    ///   - tableView: Table
    ///   - indexPath: Index path
    /// - Returns: Height
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    /// Provide estimated row height
    ///
    /// - Parameters:
    ///   - tableView: Table
    ///   - indexPath: Index path
    /// - Returns: Height
    override func tableView(_ tableView: UITableView,
                            estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Exposing

extension NearbyVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        UINearby.close.expose(item: closeButtonItem)
        UINearby.places.expose(item: tableView)
    }
}

// MARK: - TableCellExposing

extension NearbyVC: TableCellExposing {

    /// Expose cell to UI tests
    ///
    /// - Parameters:
    ///   - view: Collection
    ///   - path: Index path
    ///   - cell: Cell
    func expose(view: UITableView,
                path: IndexPath,
                cell: UITableViewCell) {
        UINearby.place(path.row).expose(item: cell)
    }
}

// MARK: - InterfaceBuildable

extension NearbyVC: InterfaceBuildable {

    /// Injection enforcement for viewDidLoad
    func requireOutlets() {
        backgroundView.require()
        closeButtonItem.require()
    }
}

// MARK: - Injectable

extension NearbyVC: Injectable {

    /// Injected dependencies
    typealias Model = (mappables: [Mappable], center: CLLocationCoordinate2D)

    /// Handle dependency injection
    ///
    /// - Parameter model: Dependencies
    func inject(model: Model) {
        let center: CLLocationCoordinate2D
        if UIApplication.isUITesting {
            // "Thailand" first
            // https://www.google.co.th/maps/@,101.6532421,9.14z
            // swiftlint:disable number_separator
            center = CLLocationCoordinate2D(
                latitude: 15.6865673,
                longitude: 101.6532421
            )
        } else {
            if let here = loc.here,
               !loc.distances.isEmpty {
                guard model.center.distance(from: here) > 10 else {
                    set(mappables: model.mappables,
                        distances: loc.distances)
                    return
                }
            }
            center = model.center
        }

        let update = DistancesOperation(center: center,
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
    }

    /// Enforce dependency injection
    func requireInjection() { }
}

// MARK: - NearbyCellDelegate

extension NearbyVC: NearbyCellDelegate {

    fileprivate func dismiss() {
        performSegue(withIdentifier: Segues.unwindFromNearby,
                     sender: self)
    }
}

/// Item in Nearby controller
final class NearbyCell: UITableViewCell, ServiceProvider {

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

    /// Configure after nib loading
    override func awakeFromNib() {
        super.awakeFromNib()

        let doubleTap = UITapGestureRecognizer(target: self,
                                               action: #selector(cellDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(cellTapped))
        addGestureRecognizer(tap)
        tap.require(toFail: doubleTap)
   }

    /// Empty display
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

    fileprivate func inject(mappable: Mappable,
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

// MARK: - Private

private extension NearbyCell {

    @IBAction func cellTapped(_ sender: UIButton) {
        mappable?.reveal(callout: true)
    }

    @IBAction func cellDoubleTapped(_ sender: UIButton) {
        mappable?.show()
    }

    @IBAction func toggleVisit(_ sender: UISwitch) {
        guard let mappable = mappable else { return }

        let visited = sender.isOn
        note.set(item: mappable.item,
                 visited: visited,
                 congratulate: false) { [weak sender] result in
            if case .failure = result {
                sender?.isOn = !visited
            }
        }
    }

    func show(visited: Bool) {
        visitedLabel?.text = (visited ? L.visited() : L.notVisited()).uppercased()
        visitSwitch?.isOn = visited
    }
}
