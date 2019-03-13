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
            refreshSearchResults()
        }
    }

    @IBInspectable var searchPropertyKeyPath: String? {
        didSet {

            if searchPropertyKeyPath?.contains(".") == false && sortPropertyKey == nil {

                sortPropertyKey = searchPropertyKeyPath
            }

            refreshSearchResults()
        }
    }

    var basePredicate: NSPredicate? {
        didSet {
            refreshSearchResults()
        }
    }

    @IBInspectable var sortPropertyKey: String? {
        didSet {
            refreshSearchResults()
        }
    }

    @IBInspectable var sortAscending: Bool = true {
        didSet {
            refreshSearchResults()
        }
    }

    @IBInspectable var searchBarInTableView: Bool = false

    @IBInspectable var caseInsensitiveSearch: Bool = true {
        didSet {
            refreshSearchResults()
        }
    }

    @IBInspectable var useContainsSearch: Bool = false {
        didSet {
            refreshSearchResults()
        }
    }

    var realmConfiguration: Realm.Configuration {
        set {
            internalConfiguration = newValue
        }
        get {
            if let configuration = internalConfiguration {
                return configuration
            }

            return Realm.Configuration.defaultConfiguration
        }
    }

    var realm: Realm {
        // swiftlint:disable:next force_try
        return try! Realm(configuration: realmConfiguration)
    }

    var results: RLMResults<RLMObject>?

    var searchBar: UISearchBar {
        return searchController.searchBar
    }

    // MARK: - Public Methods

    func refreshSearchResults() {
        let searchString = searchController.searchBar.text

        let predicate = searchPredicate(searchString)

        updateResults(predicate)
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

        viewIsLoaded = true

        if searchBarInTableView {
            tableView.tableHeaderView = searchBar
            searchBar.sizeToFit()
        } else {
            if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
                searchField.backgroundColor = .white
                searchField.borderStyle = .none
                searchBar.searchTextPositionAdjustment = UIOffset(horizontal: 8, vertical: 0)
            }

            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
            searchController.hidesNavigationBarDuringPresentation = false
        }

        definesPresentationContext = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refreshSearchResults()
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
        let configuration = toRLMConfiguration(realmConfiguration)
        // swiftlint:disable:next force_try
        return try! RLMRealm(configuration: configuration)
    }

    fileprivate var isReadOnly: Bool {
        return realmConfiguration.readOnly
    }

    fileprivate func updateResults(_ predicate: NSPredicate?) {
        if let results = searchResults(entityName,
                                       inRealm: rlmRealm,
                                       predicate: predicate,
                                       sortPropertyKey: sortPropertyKey,
                                       sortAscending: sortAscending) {

            guard !isReadOnly else {
                self.results = results
                tableView.reloadData()
                return
            }

            token = results.addNotificationBlock { [weak self] results, change, error in
                if let self = self {
                    if error != nil || !self.viewIsLoaded {
                        return
                    }

                    self.results = results

                    let tableView = self.tableView

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
            let leftExpression = NSExpression(forKeyPath: searchPropertyKeyPath!)

            let rightExpression = NSExpression(forConstantValue: text)

            let operatorType: NSComparisonPredicate.Operator = useContainsSearch ? .contains : .beginsWith

            let options: NSComparisonPredicate.Options = caseInsensitiveSearch ? .caseInsensitive : []

            let filterPredicate = NSComparisonPredicate(leftExpression: leftExpression,
                                                        rightExpression: rightExpression,
                                                        modifier: NSComparisonPredicate.Modifier.direct,
                                                        type: operatorType,
                                                        options: options)

            if basePredicate != nil {

                // swiftlint:disable:next force_unwrapping
                let subs = [basePredicate!, filterPredicate]
                let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: subs)

                return compoundPredicate
            }

            return filterPredicate
        }

        return basePredicate
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
        if let results = results {
            let baseObject = results.object(at: UInt(indexPath.row)) as RLMObjectBase
            // swiftlint:disable:next force_cast
            let object = baseObject as! Object

            resultsDelegate.searchViewController(self, willSelectObject: object, atIndexPath: indexPath)

            return indexPath
        }

        return nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let results = results {
            let baseObject = results.object(at: UInt(indexPath.row)) as RLMObjectBase
            // swiftlint:disable:next force_cast
            let object = baseObject as! Object

            resultsDelegate.searchViewController(self, didSelectObject: object, atIndexPath: indexPath)
        }
    }
}

// MARK: - UITableViewControllerDataSource

extension RealmSearchViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let results = results {
            return Int(results.count)
        }

        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let results = results {
            let baseObject = results.object(at: UInt(indexPath.row)) as RLMObjectBase
            // swiftlint:disable:next force_cast
            let object = baseObject as! Object

            let cell = resultsDataSource.searchViewController(self, cellForObject: object, atIndexPath: indexPath)

            return cell
        }

        return UITableViewCell()
    }
}

// MARK: - UISearchResultsUpdating

extension RealmSearchViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        refreshSearchResults()
    }
}
