// @copyright Trollwerks Inc.

import Anchorage
import DropDown
import Parchment

/// Root class for the Rankings tab
final class RankingsVC: UIViewController, ServiceProvider {

    private typealias Segues = R.segue.rankingsVC

    @IBOutlet private var pagesHolder: UIView?
    @IBOutlet private var searchBar: UISearchBar? {
        didSet {
            searchBar?.removeClearButton()
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
        requireInjections()

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
        switch segue.identifier {
        case Segues.showFilter.identifier:
             break
        case Segues.showUserCounts.identifier:
            if let counts = Segues.showUserCounts(segue: segue)?.destination,
               let countsModel = countsModel {
                counts.inject(model: countsModel)
            }
        case Segues.showUserProfile.identifier:
            if let profile = Segues.showUserProfile(segue: segue)?.destination,
                let profileModel = profileModel {
                profile.inject(model: profileModel)
            }
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }

    func updateFilter() {
        net.refreshRankings()
        pagingVC.reloadData()
    }
}

// MARK: - Private

private extension RankingsVC {

    @IBAction func unwindToRankings(segue: UIStoryboardSegue) {
    }

    func configurePagesHolder() {
        guard let holder = pagesHolder else { return }

        pagingVC.configure()

        addChild(pagingVC)
        holder.addSubview(pagingVC.view)
        pagingVC.view.edgeAnchors == holder.edgeAnchors
        pagingVC.didMove(toParent: self)

        pagingVC.dataSource = self
        pagingVC.delegate = self
        pagingVC.select(pagingItem: ListPagingItem.pages[0])
    }

    func configureSearchBar() {
        guard let searchBar = searchBar else { return }
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
        guard let searchBar = searchBar  else { return }

        if navigationItem.titleView == nil {
            navigationItem.titleView = searchBar
            searchBar.becomeFirstResponder()
        } else {
            searchBarCancelButtonClicked(searchBar)
        }
    }
}

// MARK: - Exposing

extension RankingsVC: Exposing {

    func expose() {
        let bar = navigationController?.navigationBar
        RankingVCs.nav.expose(item: bar)
        let items = navigationItem.rightBarButtonItems
        RankingVCs.search.expose(item: items?.first)
        RankingVCs.filter.expose(item: items?.last)
    }
}

// MARK: - PagingViewControllerDataSource

extension RankingsVC: PagingViewControllerDataSource {

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

    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>,
                                 pagingItemForIndex index: Int) -> T {
        guard let result = pages[index] as? T else {
            fatalError("ListPagingItem type failure")
        }
        return result
    }

    func numberOfViewControllers<T>(in: PagingViewController<T>) -> Int {
        return pages.count
    }
}

// MARK: - RankingsPageVCDelegate

extension RankingsVC: RankingsPageVCDelegate {

    func didScroll(rankingsPageVC: RankingsPageVC) {
        let height = pagingVC.menuHeight(for: rankingsPageVC.collectionView)
        update(menu: height)
    }

    func tapped(profile user: User) {
        profileModel = user
        performSegue(withIdentifier: Segues.showUserProfile, sender: self)
    }

    func tapped(remaining user: User, list: Checklist) {
        countsModel = (list, user, .remaining)
        performSegue(withIdentifier: Segues.showUserCounts, sender: self)
    }

    func tapped(visited user: User, list: Checklist) {
        countsModel = (list, user, .visited)
        performSegue(withIdentifier: Segues.showUserCounts, sender: self)
    }
}

// MARK: - PagingViewControllerDelegate

extension RankingsVC: PagingViewControllerDelegate {

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

    func display(names: [String]) {
        dropdown.dataSource = names
        if names.isEmpty {
            dropdown.hide()
            searchBar?.setShowsCancelButton(true, animated: true)
        } else {
            searchBar?.showsCancelButton = false
            dropdown.show()
        }
    }

    func search(query: String) {
        net.search(query: query) { [weak self] result in
            guard case let .success(results) = result,
                  let self = self else { return }

            let key = results.request.query
            let items = results.data.filter { $0.isUser }
            self.searchResults[key] = items
            if key == self.searchKey {
                self.display(names: items.map { $0.label })
            }
        }
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBarCancelButtonClicked(searchBar)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        dropdown.hide()
        searchBar.resignFirstResponder()
        navigationItem.titleView = nil
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }

    func dropdown(selected index: Int) {
        let info = searchResults[searchKey]?[index]
        if let searchBar = searchBar {
            searchBarCancelButtonClicked(searchBar)
        }

        guard let person = info else { return }
        profileModel = data.get(user: person.id) ?? User(from: person)
        performSegue(withIdentifier: Segues.showUserProfile, sender: self)
    }
}

// MARK: - Injectable

extension RankingsVC: Injectable {

    /// Injected dependencies
    typealias Model = ()

    /// Handle dependency injection
    ///
    /// - Parameter model: Dependencies
    /// - Returns: Chainable self
    @discardableResult func inject(model: Model) -> Self {
        return self
    }

    /// Enforce dependency injection
    func requireInjections() {
        pagesHolder.require()
        searchBar.require()
    }
}
