// @copyright Trollwerks Inc.

import Anchorage

/// Display network status and pending operations
final class NetworkVC: UITableViewController {

    // verified in requireOutlets
    @IBOutlet private var backgroundView: UIView!

    private let layout = (row: CGFloat(60),
                          header: CGFloat(40))

    /// Content state to display
    var contentState: ContentState = .loading
    /// Data models
    private var models: [OfflineRequestManager.Task] = []
    private var tasksObserver: Observer?

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireOutlets()

        tableView.backgroundView = backgroundView
        tableView.tableFooterView = UIView()
        tableView.register(
            NetworkHeader.self,
            forHeaderFooterViewReuseIdentifier: NetworkHeader.reuseIdentifier
        )
        tableView.estimatedSectionHeaderHeight = layout.header
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension

        update()
        observe()
    }

    /// Prepare for reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .standard)
        expose()
    }

    /// Actions to take after reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        report(screen: "Network")
    }
}

// MARK: - UITableViewControllerDataSource

extension NetworkVC {

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
        return models.count
    }

    /// Create table header
    ///
    /// - Parameters:
    ///   - tableView: Container
    ///   - section: Index
    /// - Returns: NetworkHeader
    override func tableView(_ tableView: UITableView,
                            viewForHeaderInSection section: Int) -> UIView? {
        //swiftlint:disable:next implicitly_unwrapped_optional
        let header: NetworkHeader! = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: NetworkHeader.reuseIdentifier) as? NetworkHeader

        header.observe()

        return header
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
        let cell: UITableViewCell! = tableView.dequeueReusableCell(
            withIdentifier: R.reuseIdentifier.networkCell,
            for: indexPath)

        let model = models[indexPath.row]
        cell.textLabel?.font = Avenir.book.of(size: 17)
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = model.title
        cell.detailTextLabel?.font = Avenir.bookOblique.of(size: 15)
        cell.detailTextLabel?.lineBreakMode = .byWordWrapping
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = model.subtitle

        return cell
    }
}

// MARK: - UITableViewDelegate

extension NetworkVC {

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

    /// Provide header height
    ///
    /// - Parameters:
    ///   - tableView: Container
    ///   - section: Index
    /// - Returns: Height
    override func tableView(_ tableView: UITableView,
                            heightForHeaderInSection section: Int) -> CGFloat {
        return layout.header
    }

    /// Provide estimated header height
    ///
    /// - Parameters:
    ///   - tableView: Container
    ///   - section: Index
    /// - Returns: Height
    override func tableView(_ tableView: UITableView,
                            estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return layout.header
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

// MARK: - Private

private extension NetworkVC {

    func update() {
        self.models = net.tasks
        tableView.reloadData()

        contentState = models.isEmpty ? .empty :  .data
        tableView.set(message: contentState, color: .darkText)
    }

    func observe() {
        guard tasksObserver == nil else { return }

        tasksObserver = net.observer(of: .tasks) { [weak self] _ in
            self?.update()
        }
    }
}

// MARK: - Exposing

extension NetworkVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        let items = navigationItem.leftBarButtonItems
        UINetwork.close.expose(item: items?.first)
    }
}

// MARK: - InterfaceBuildable

extension NetworkVC: InterfaceBuildable {

    /// Injection enforcement for viewDidLoad
    func requireOutlets() {
        backgroundView.require()
    }
}

/// Header of network table
final class NetworkHeader: UITableViewHeaderFooterView, ServiceProvider {

    /// Dequeueing identifier
    static let reuseIdentifier = NSStringFromClass(NetworkHeader.self)

    private let status = UILabel {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = Avenir.blackOblique.of(size: 16)
        $0.textColor = .white
        $0.textAlignment = .center
    }

    private var isConnected = false {
        didSet { update() }
    }

    private var connectionObserver: Observer?

    /// Construct with identifier
    ///
    /// - Parameter reuseIdentifier: Identifier
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        contentView.addSubview(status)
        status.edgeAnchors == edgeAnchors
    }

    /// Unsupported coding constructor
    ///
    /// - Parameter coder: An unarchiver object.
    required init?(coder: NSCoder) {
        return nil
    }

    func observe() {
        guard connectionObserver == nil else { return }

        isConnected = net.isConnected
        connectionObserver = net.observer(of: .connection) { [weak self] info in
            guard let updated = info[StatusKey.value.rawValue] as? Bool,
                let self = self else { return }
            self.isConnected = updated
        }
    }
}

private extension NetworkHeader {

    func update() {
        status.text = isConnected ? L.connected() : L.notConnected()
        status.backgroundColor = isConnected ? .visited : .carnation
    }
}
