// @copyright Trollwerks Inc.

import Anchorage
import DropDown
import Parchment

/// Root class for the Rankings tab
final class RankingsVC: UIViewController, ServiceProvider {

    private typealias Segues = R.segue.rankingsVC

    // verified in requireOutlets
    @IBOutlet private var pagesHolder: UIView!
    @IBOutlet private var searchBar: UISearchBar! {
        didSet {
            searchBar.removeClearButton()
        }
    }

    private let pagingVC = RankingsPagingVC()
    private let pages = ListPagingItem.pages

    private var countsModel: UserCountsVC.Model?
    private var profileModel: UserProfileVC.Model?

    private let dropdown = DropDown {
        $0.dismissMode = .manual
        $0.backgroundColor = .white
        $0.selectionBackgroundColor = UIColor(red: 0.649, green: 0.815, blue: 1.0, alpha: 0.2)
        $0.separatorColor = UIColor(white: 0.7, alpha: 0.8)
        $0.direction = .bottom
        $0.cellHeight = 30
        $0.setupCornerRadius(10)
        $0.shadowColor = UIColor(white: 0.6, alpha: 1)
        $0.shadowOpacity = 0.9
        $0.shadowRadius = 25
        $0.animationduration = 0.25
        $0.textColor = .darkGray
        $0.textFont = Avenir.book.of(size: 14)
    }
    private var dropdownPeople: [String] = []

    private var searchResults: [String: [SearchResultItemJSON]] = [:]
    private var searchKey: String = ""

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireOutlets()

        configurePagesHolder()
        configureSearchBar()
    }

    /// Prepare for reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .standard)
        expose()
    }

    /// Instrument and inject navigation
    ///
    /// - Parameters:
    ///   - segue: Navigation action
    ///   - sender: Action originator
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let counts = Segues.showUserCounts(segue: segue)?
                              .destination,
           let countsModel = countsModel {
            counts.inject(model: countsModel)
        } else if let profile = Segues.showUserProfile(segue: segue)?
                                      .destination,
                  let profileModel = profileModel {
            profile.inject(model: profileModel)
        }
    }

    /// Refresh rankings for changed filter
    func updateFilter() {
        net.refreshRankings()
        pagingVC.reloadData()
    }
}

// MARK: - Private

private extension RankingsVC {

    @IBAction func unwindToRankings(segue: UIStoryboardSegue) { }

    func configurePagesHolder() {
        pagingVC.configure()

        addChild(pagingVC)
        pagesHolder.addSubview(pagingVC.view)
        pagingVC.view.edgeAnchors == pagesHolder.edgeAnchors
        pagingVC.didMove(toParent: self)

        pagingVC.dataSource = self
        pagingVC.delegate = self
        pagingVC.select(pagingItem: ListPagingItem.pages[0])
    }

    func configureSearchBar() {
        dropdown.anchorView = searchBar
        dropdown.bottomOffset = CGPoint(x: 0, y: searchBar.bounds.height)
        dropdown.selectionAction = { [weak self] (index: Int, item: String) in
            self?.dropdown(selected: index)
        }
    }

    func update(menu height: CGFloat) {
        pagingVC.update(menu: height)
    }

    @IBAction func searchTapped(_ sender: UIBarButtonItem) {
        if navigationItem.titleView == nil {
            navigationItem.titleView = searchBar
            searchBar.becomeFirstResponder()
        } else {
            searchBarCancelButtonClicked(searchBar)
        }
    }

    func display(names: [String]) {
        dropdown.dataSource = names
        if names.isEmpty {
            dropdown.hide()
            searchBar.setShowsCancelButton(true, animated: true)
        } else {
            searchBar.showsCancelButton = false
            dropdown.show()
        }
    }

    func search(query: String) {
        let blocked = data.blockedUsers
        net.search(query: query) { [weak self] result in
            guard case let .success(results) = result,
                let self = self else { return }

            let key = results.request.query
            let items = results.data.filter { $0.isUser && !blocked.contains($0.id) }
            self.searchResults[key] = items
            if key == self.searchKey {
                self.display(names: items.map { $0.label })
            }
        }
    }

    func dropdown(selected index: Int) {
        let info = searchResults[searchKey]?[index]
        searchBarCancelButtonClicked(searchBar)

        guard let person = info else { return }
        profileModel = data.get(user: person.id) ?? User(from: person)
        performSegue(withIdentifier: Segues.showUserProfile, sender: self)
    }
}

// MARK: - Exposing

extension RankingsVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        let bar = navigationController?.navigationBar
        UIRankings.nav.expose(item: bar)
        let items = navigationItem.rightBarButtonItems
        UIRankings.search.expose(item: items?.first)
        UIRankings.filter.expose(item: items?.last)
    }
}

// MARK: - PagingViewControllerDataSource

extension RankingsVC: PagingViewControllerDataSource {

    /// Create page by index
    ///
    /// - Parameters:
    ///   - pagingViewController: Page holder
    ///   - index: Index
    /// - Returns: View controller
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>,
                                 viewControllerForIndex index: Int) -> UIViewController {
        let viewController = RankingsPageVC(options: pagingViewController.options)

        let insets = UIEdgeInsets(top: RankingsPagingVC.Layout.menuHeight,
                                  left: 0,
                                  bottom: 0,
                                  right: 0)
        viewController.inject(list: pages[index].list,
                              insets: insets,
                              delegate: self)

        return viewController
    }

    /// Provide Parchment with typed page
    ///
    /// - Parameters:
    ///   - pagingViewController: Page holder
    ///   - index: Index
    /// - Returns: Typed view controller
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>,
                                 pagingItemForIndex index: Int) -> T {
        guard let result = pages[index] as? T else {
            fatalError("ListPagingItem type failure")
        }
        return result
    }

    /// Provide Parchment with page count
    ///
    /// - Parameter in: Page holder
    /// - Returns: Page count
    func numberOfViewControllers<T>(in: PagingViewController<T>) -> Int {
        return pages.count
    }
}

// MARK: - RankingsPageVCDelegate

extension RankingsVC: RankingsPageVCDelegate {

    /// Scroll notification
    ///
    /// - Parameter rankingsPageVC: Scrollee
    func didScroll(rankingsPageVC: RankingsPageVC) {
        let height = pagingVC.menuHeight(for: rankingsPageVC.collectionView)
        update(menu: height)
    }

    /// Profile tapped
    ///
    /// - Parameter user: User to display
    func tapped(profile user: User) {
        profileModel = user
        performSegue(withIdentifier: Segues.showUserProfile, sender: self)
    }

    /// Remaining tapped
    ///
    /// - Parameters:
    ///   - user: User to display
    ///   - list: List to display
    func tapped(remaining user: User, list: Checklist) {
        countsModel = (list, user, .remaining)
        performSegue(withIdentifier: Segues.showUserCounts, sender: self)
    }

    /// Visited tapped
    ///
    /// - Parameters:
    ///   - user: User to display
    ///   - list: List to display
    func tapped(visited user: User, list: Checklist) {
        countsModel = (list, user, .visited)
        performSegue(withIdentifier: Segues.showUserCounts, sender: self)
    }
}

// MARK: - PagingViewControllerDelegate

extension RankingsVC: PagingViewControllerDelegate {

    /// Handle page change progress
    ///
    /// - Parameters:
    ///   - pagingViewController: Page holder
    ///   - currentPagingItem: Current typed page item
    ///   - upcomingPagingItem: Next typed page item
    ///   - startingViewController: Start view controller
    ///   - destinationViewController: Finish view controller
    ///   - progress: Float
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>,
                                 isScrollingFromItem currentPagingItem: T,
                                 toItem upcomingPagingItem: T?,
                                 startingViewController: UIViewController,
                                 destinationViewController: UIViewController?,
                                 progress: CGFloat) {
        guard let destinationViewController = destinationViewController as? RankingsPageVC else { return }
        guard let startingViewController = startingViewController as? RankingsPageVC else { return }

        let from = pagingVC.menuHeight(for: startingViewController.collectionView)
        let to = pagingVC.menuHeight(for: destinationViewController.collectionView)
        let height = ((to - from) * abs(progress)) + from
        update(menu: height)
    }
}

// MARK: - UISearchBarDelegate

extension RankingsVC: UISearchBarDelegate {

    /// Changed search text notification
    ///
    /// - Parameters:
    ///   - searchBar: Searcher
    ///   - searchText: Contents
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {
        searchKey = searchText
        if searchKey.isEmpty {
            dropdownPeople = []
        } else {
            if let items = searchResults[searchKey] {
                display(names: items.map { $0.label })
            } else {
                search(query: searchText)
            }
        }
    }

    /// Begin search editing
    ///
    /// - Parameter searchBar: Searcher
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    /// Handle search button click
    ///
    /// - Parameter searchBar: Searcher
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBarCancelButtonClicked(searchBar)
    }

    /// Handle cancel button click
    ///
    /// - Parameter searchBar: Searcher
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        dropdown.hide()
        searchBar.resignFirstResponder()
        navigationItem.titleView = nil
    }

    /// Search ended notification
    ///
    /// - Parameter searchBar: Searcher
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
}

// MARK: - InterfaceBuildable

extension RankingsVC: InterfaceBuildable {

    /// Injection enforcement for viewDidLoad
    func requireOutlets() {
        pagesHolder.require()
        searchBar.require()
    }
}
