// @copyright Trollwerks Inc.

import Realm.Dynamic
import RealmSwift

// swiftlint:disable file_length

protocol RealmSearchResultsDataSource {

    func searchViewController(_ controller: RealmSearchViewController,
                              cellForObject object: Object,
                              atIndexPath indexPath: IndexPath) -> UITableViewCell
}

protocol RealmSearchResultsDelegate: AnyObject {

    func searchViewController(_ controller: RealmSearchViewController,
                              willSelectObject anObject: Object,
                              atIndexPath indexPath: IndexPath)

    func searchViewController(_ controller: RealmSearchViewController,
                              didSelectObject anObject: Object,
                              atIndexPath indexPath: IndexPath)
}

class RealmSearchViewController: UITableViewController, RealmSearchResultsDataSource, RealmSearchResultsDelegate {

    // swiftlint:disable:next implicitly_unwrapped_optional
    var resultsDataSource: RealmSearchResultsDataSource!
    // swiftlint:disable:next implicitly_unwrapped_optional
    weak var resultsDelegate: RealmSearchResultsDelegate!

    @IBInspectable var entityName: String? {
        didSet {
            self.refreshSearchResults()
        }
    }

    @IBInspectable var searchPropertyKeyPath: String? {
        didSet {

            if self.searchPropertyKeyPath?.contains(".") == false && self.sortPropertyKey == nil {

                self.sortPropertyKey = self.searchPropertyKeyPath
            }

            self.refreshSearchResults()
        }
    }

    var basePredicate: NSPredicate? {
        didSet {
            self.refreshSearchResults()
        }
    }

    @IBInspectable var sortPropertyKey: String? {
        didSet {
            self.refreshSearchResults()
        }
    }

    @IBInspectable var sortAscending: Bool = true {
        didSet {
            self.refreshSearchResults()
        }
    }

    @IBInspectable var searchBarInTableView: Bool = true

    @IBInspectable var caseInsensitiveSearch: Bool = true {
        didSet {
            self.refreshSearchResults()
        }
    }

    @IBInspectable var useContainsSearch: Bool = false {
        didSet {
            self.refreshSearchResults()
        }
    }

    var realmConfiguration: Realm.Configuration {
        set {
            self.internalConfiguration = newValue
        }
        get {
            if let configuration = self.internalConfiguration {
                return configuration
            }

            return Realm.Configuration.defaultConfiguration
        }
    }

    var realm: Realm {
        // swiftlint:disable:next force_try
        return try! Realm(configuration: self.realmConfiguration)
    }

    var results: RLMResults<RLMObject>?

    var searchBar: UISearchBar {
        return self.searchController.searchBar
    }

    // MARK: - Public Methods

    func refreshSearchResults() {
        let searchString = self.searchController.searchBar.text

        let predicate = self.searchPredicate(searchString)

        self.updateResults(predicate)
    }

    // MARK: - Initialization

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        resultsDataSource = self
        resultsDelegate = self
    }

    override init(style: UITableView.Style) {
        super.init(style: style)

        resultsDataSource = self
        resultsDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        resultsDataSource = self
        resultsDelegate = self
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewIsLoaded = true

        if self.searchBarInTableView {
            self.tableView.tableHeaderView = self.searchBar

            self.searchBar.sizeToFit()
        } else {
            self.searchController.hidesNavigationBarDuringPresentation = false
        }

        self.definesPresentationContext = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.refreshSearchResults()
    }

    // MARK: - RealmSearchResultsDataSource

    func searchViewController(_ controller: RealmSearchViewController,
                              cellForObject object: Object,
                              atIndexPath indexPath: IndexPath) -> UITableViewCell {

        print("You need to implement searchViewController(controller:,cellForObject object:,atIndexPath indexPath:)")

        return UITableViewCell()
    }

    // MARK: - RealmSearchResultsDelegate

    func searchViewController(_ controller: RealmSearchViewController,
                              didSelectObject anObject: Object,
                              atIndexPath indexPath: IndexPath) {
        // Subclasses to redeclare
    }

    func searchViewController(_ controller: RealmSearchViewController,
                              willSelectObject anObject: Object,
                              atIndexPath indexPath: IndexPath) {
        // Subclasses to redeclare
    }

    // MARK: - Private

    fileprivate var viewIsLoaded: Bool = false

    fileprivate var internalConfiguration: Realm.Configuration?

    fileprivate var token: RLMNotificationToken?

    fileprivate lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.dimsBackgroundDuringPresentation = false

        return controller
    }()

    fileprivate var rlmRealm: RLMRealm {
        let configuration = self.toRLMConfiguration(self.realmConfiguration)
        // swiftlint:disable:next force_try
        return try! RLMRealm(configuration: configuration)
    }

    fileprivate var isReadOnly: Bool {
        return self.realmConfiguration.readOnly
    }

    fileprivate func updateResults(_ predicate: NSPredicate?) {
        if let results = self.searchResults(self.entityName,
                                            inRealm: self.rlmRealm,
                                            predicate: predicate,
                                            sortPropertyKey: self.sortPropertyKey,
                                            sortAscending: self.sortAscending) {

            guard !isReadOnly else {
                self.results = results
                self.tableView.reloadData()
                return
            }

            self.token = results.addNotificationBlock { [weak self] results, change, error in
                if let weakSelf = self {
                    if error != nil || !weakSelf.viewIsLoaded {
                        return
                    }

                    weakSelf.results = results

                    let tableView = weakSelf.tableView

                    // Initial run of the query will pass nil for the change information
                    if change == nil {
                        tableView?.reloadData()
                        return
                    }

                    // Query results have changed, so apply them to the UITableView
                    else if let aChange = change {
                        tableView?.beginUpdates()
                        tableView?.deleteRows(at: aChange.deletions(inSection: 0), with: .automatic)
                        tableView?.insertRows(at: aChange.insertions(inSection: 0), with: .automatic)
                        tableView?.reloadRows(at: aChange.modifications(inSection: 0), with: .automatic)
                        tableView?.endUpdates()
                    }
                }
            }
        }
    }

    fileprivate func searchPredicate(_ text: String?) -> NSPredicate? {
        if let text = text, !text.isEmpty {

            // swiftlint:disable:next force_unwrapping
            let leftExpression = NSExpression(forKeyPath: self.searchPropertyKeyPath!)

            let rightExpression = NSExpression(forConstantValue: text)

            let operatorType: NSComparisonPredicate.Operator = self.useContainsSearch ? .contains : .beginsWith

            let options: NSComparisonPredicate.Options = self.caseInsensitiveSearch ? .caseInsensitive : []

            let filterPredicate = NSComparisonPredicate(leftExpression: leftExpression,
                                                        rightExpression: rightExpression,
                                                        modifier: NSComparisonPredicate.Modifier.direct,
                                                        type: operatorType,
                                                        options: options)

            if self.basePredicate != nil {

                // swiftlint:disable:next force_unwrapping
                let subs = [self.basePredicate!, filterPredicate]
                let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: subs)

                return compoundPredicate
            }

            return filterPredicate
        }

        return self.basePredicate
    }

    fileprivate func searchResults(_ entityName: String?,
                                   inRealm realm: RLMRealm?,
                                   predicate: NSPredicate?,
                                   sortPropertyKey: String?,
                                   sortAscending: Bool) -> RLMResults<RLMObject>? {

        if entityName != nil && realm != nil {

            // swiftlint:disable:next force_unwrapping
            var results = realm?.allObjects(entityName!)

            if predicate != nil {
                // swiftlint:disable:next force_unwrapping
                results = realm?.objects(entityName!, with: predicate!)
            }

            if sortPropertyKey != nil {

                // swiftlint:disable:next force_unwrapping
                let sort = RLMSortDescriptor(keyPath: sortPropertyKey!, ascending: sortAscending)

                results = results?.sortedResults(using: [sort])
            }

            return results
        }

        return nil
    }

    fileprivate func toRLMConfiguration(_ configuration: Realm.Configuration) -> RLMRealmConfiguration {
        let rlmConfiguration = RLMRealmConfiguration()

        if configuration.fileURL != nil {
            rlmConfiguration.fileURL = configuration.fileURL
        }

        if configuration.inMemoryIdentifier != nil {
            rlmConfiguration.inMemoryIdentifier = configuration.inMemoryIdentifier
        }

        rlmConfiguration.encryptionKey = configuration.encryptionKey
        rlmConfiguration.readOnly = configuration.readOnly
        rlmConfiguration.schemaVersion = configuration.schemaVersion
        return rlmConfiguration
    }

    fileprivate func runOnMainThread(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async { () -> Void in
                block()
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension RealmSearchViewController {

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let results = self.results {
            let baseObject = results.object(at: UInt(indexPath.row)) as RLMObjectBase
            // swiftlint:disable:next force_cast
            let object = baseObject as! Object

            self.resultsDelegate.searchViewController(self, willSelectObject: object, atIndexPath: indexPath)

            return indexPath
        }

        return nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let results = self.results {
            let baseObject = results.object(at: UInt(indexPath.row)) as RLMObjectBase
            // swiftlint:disable:next force_cast
            let object = baseObject as! Object

            self.resultsDelegate.searchViewController(self, didSelectObject: object, atIndexPath: indexPath)
        }
    }
}

// MARK: - UITableViewControllerDataSource

extension RealmSearchViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let results = self.results {
            return Int(results.count)
        }

        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let results = self.results {
            let baseObject = results.object(at: UInt(indexPath.row)) as RLMObjectBase
            // swiftlint:disable:next force_cast
            let object = baseObject as! Object

            let cell = self.resultsDataSource.searchViewController(self, cellForObject: object, atIndexPath: indexPath)

            return cell
        }

        return UITableViewCell()
    }
}

// MARK: - UISearchResultsUpdating

extension RealmSearchViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        self.refreshSearchResults()
    }
}
