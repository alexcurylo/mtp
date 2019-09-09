// @copyright Trollwerks Inc.

import UIKit

/// Display network status and pending operations
final class NetworkVC: UITableViewController {

    // verified in requireOutlets
    @IBOutlet private var backgroundView: UIView!

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireOutlets()

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
        return 1
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

        cell.textLabel?.text = "Operation"
        cell.detailTextLabel?.text = "Info"

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

extension NetworkVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        let items = navigationItem.leftBarButtonItems
        UIFaq.close.expose(item: items?.first)
    }
}

// MARK: - InterfaceBuildable

extension NetworkVC: InterfaceBuildable {

    /// Injection enforcement for viewDidLoad
    func requireOutlets() {
        backgroundView.require()
    }
}
