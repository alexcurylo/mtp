// @copyright Trollwerks Inc.

import Anchorage
import Parchment
import RealmSwift

// swiftlint:disable file_length

/// Notifies of scroll for menu updating
protocol RankingsPageVCDelegate: RankingCellDelegate {

    /// Scroll notification
    ///
    /// - Parameter rankingsPageVC: Scrollee
    func didScroll(rankingsPageVC: RankingsPageVC)
}

/// Displays logged in user visit counts
final class RankingsPageVC: UIViewController, ServiceProvider {

    private enum Layout {
        static let headerHeight = CGFloat(98)
        static let lineSpacing = CGFloat(8)
        static let collectionInsets = UIEdgeInsets(top: 0,
                                                   left: lineSpacing,
                                                   bottom: 0,
                                                   right: lineSpacing)

        static let cellHeight = CGFloat(90)
    }

    /// View displaying ranking cells
    let collectionView: UICollectionView = {
        let flow = UICollectionViewFlowLayout()
        flow.minimumLineSpacing = Layout.lineSpacing
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: flow)
        collectionView.backgroundColor = .clear
        collectionView.backgroundView = UIView { $0.backgroundColor = .clear }
        return collectionView
    }()

    private weak var delegate: RankingsPageVCDelegate?

    private var contentState: ContentState = .unknown
    private var loading: Set<Int> = []
    private var rankings: Results<RankingsPageInfo>?
    private var filter = RankingsQuery()
    private var filterDescription = ""
    private var filterRank: Int?
    private var blockedUsers: [Int] = []

    private var visitedObserver: Observer?
    private var rankingsObserver: Observer?
    private var scorecardObserver: Observer?
    private var blockedObserver: Observer?

    /// Construction with paging options
    ///
    /// - Parameter options: Options
    init(options: PagingOptions) {
        super.init(nibName: nil, bundle: nil)

        view.addSubview(collectionView)
        collectionView.edgeAnchors == view.edgeAnchors + Layout.collectionInsets

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            RankingCell.self,
            forCellWithReuseIdentifier: RankingCell.reuseIdentifier)
        collectionView.register(
            RankingHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: RankingHeader.reuseIdentifier)
    }

    /// Unsupported coding constructor
    ///
    /// - Parameter coder: An unarchiver object.
    required init?(coder: NSCoder) {
        return nil
    }

    /// Refresh collection view on layout
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    /// Handle dependency injection
    ///
    /// - Parameters:
    ///   - list: Checklist
    ///   - insets: Edge instets
    ///   - delegate: RankingsPageVCDelegate
    func inject(list: Checklist,
                insets: UIEdgeInsets,
                delegate: RankingsPageVCDelegate) {
        collectionView.contentInset = insets
        collectionView.scrollIndicatorInsets = insets
        self.delegate = delegate
        blockedUsers = data.blockedUsers

        let newFilter = data.lastRankingsQuery.with(list: list)
        if contentState == .unknown || filter != newFilter {
            filter = newFilter
            filterDescription = filter.description

            loading = []
            contentState = .loading
            update(rankings: false)
            observe()
        }
        expose()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension RankingsPageVC: UICollectionViewDelegateFlowLayout {

    /// Provide header size
    ///
    /// - Parameters:
    ///   - collectionView: Collection
    ///   - collectionViewLayout: Collection layout
    ///   - section: Section index
    /// - Returns: Size
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width,
                      height: Layout.headerHeight)
    }

    /// Provide cell size
    ///
    /// - Parameters:
    ///   - collectionView: Collection
    ///   - collectionViewLayout: Collection layout
    ///   - indexPath: Cell path
    /// - Returns: Size
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width,
                      height: Layout.cellHeight)
    }
}

// MARK: - UIScrollViewDelegate

extension RankingsPageVC {

    /// Scrolling notfication
    ///
    /// - Parameter scrollView: Scrollee
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.didScroll(rankingsPageVC: self)
    }
}

// MARK: - UICollectionViewDataSource

extension RankingsPageVC: UICollectionViewDataSource {

    /// Provide header
    ///
    /// - Parameters:
    ///   - collectionView: Collection
    ///   - kind: Expect header
    ///   - indexPath: Item path
    /// - Returns: RankingHeader
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        //swiftlint:disable:next implicitly_unwrapped_optional
        let header: RankingHeader! = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: RankingHeader.reuseIdentifier,
            for: indexPath) as? RankingHeader

        header.inject(rank: filterRank,
                      list: filter.checklist,
                      filter: filterDescription,
                      delegate: self)

        return header
    }

    /// Section items count
    ///
    /// - Parameters:
    ///   - collectionView: Collection
    ///   - section: Index
    /// - Returns: Item count
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return itemCount
    }

    /// Provide cell
    ///
    /// - Parameters:
    ///   - collectionView: Collection
    ///   - indexPath: Index path
    /// - Returns: RankingCell
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //swiftlint:disable:next implicitly_unwrapped_optional
        let cell: RankingCell! = collectionView.dequeueReusableCell(
            withReuseIdentifier: RankingCell.reuseIdentifier,
            for: indexPath) as? RankingCell

        let rank = indexPath.row + 1
        let shown = user(at: rank) ?? User()
        let blocked = blockedUsers.contains(shown.userId)
        cell.inject(user: blocked ? nil : shown,
                    for: rank,
                    in: filter.checklist,
                    delegate: delegate)
        expose(view: collectionView,
               path: indexPath,
               cell: cell)

        return cell
    }
}

// MARK: - RankingHeaderDelegate

extension RankingsPageVC: RankingHeaderDelegate {

    /// Tap notification
    ///
    /// - Parameter header: Tapped header
    func tapped(header: RankingHeader) {
        guard let index = myIndex else { return }

        let path = IndexPath(row: index, section: 0)
        collectionView.scrollToItem(at: path,
                                    at: .centeredVertically,
                                    animated: true)
    }
}

// MARK: - Private

private extension RankingsPageVC {

    var itemCount: Int {
        guard let first = firstPage else {
            load(page: 1)
            return 0
        }

        if first.expired {
            load(page: 1)
        }
        guard first.lastPage > 1 else {
            return first.userIds.count
        }

        let paged = (first.lastPage - 1) * RankingsPageInfo.perPage
        if let last = lastPage {
            if last.expired {
                load(page: first.lastPage)
            }
            return paged + last.userIds.count
        }

        load(page: first.lastPage)
        return paged
    }

    var firstPage: RankingsPageInfo? {
        return page(at: 1)
    }

    var lastPage: RankingsPageInfo? {
        return rankings?.filter("page = lastPage").last
    }

    func page(at index: Int) -> RankingsPageInfo? {
        // swiftlint:disable:next first_where
        return rankings?.filter("page = \(index)").first
    }

    func load(page: Int) {
        guard !loading.contains(page) else { return }

        loading.insert(page)
        let query = filter.with(page: page)
        net.loadRankings(query: query) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                self.loading.remove(page)
                switch result {
                case .success,
                     .failure(NetworkError.notModified):
                    self.data.update(stamp: self.page(at: page))
                default:
                    self.update(rankings: true)
                }
            }
        }
    }

    var myIndex: Int? {
        #if RAW_INDEX_PROVIDED
        guard filterRank != nil,
              let rankings = rankings,
              let first = rankings.first,
              let userId = data.user?.id else { return nil }

        var pagedCount = 0
        for pageIndex in 1...first.lastPage {
            //swiftlint:disable:next last_where
            if let page = rankings.filter("page = \(pageIndex)").last {
                if let pageIndex = page.userIds.index(of: userId) {
                    return pagedCount + pageIndex - 1
                }
            }
            pagedCount += RankingsPageInfo.perPage
         }
        #else
        // Getting a user cell index on demand is currently impractical
        return nil
        #endif
    }

    func observe() {
        guard visitedObserver == nil else { return }

        visitedObserver = data.observer(of: .visited) { [weak self] _ in
            self?.collectionView.reloadData()
        }

        rankingsObserver = data.observer(of: .rankings) { [weak self] info in
            guard let self = self,
                  let queryValue = info[StatusKey.value.rawValue] as? RankingsQuery,
                  queryValue.queryKey == self.filter.queryKey else { return }
            self.update(rankings: false)
        }

        scorecardObserver = data.observer(of: .scorecard) { [weak self] _ in
            self?.updateRank()
        }

        blockedObserver = data.observer(of: .blockedUsers) { [weak self] _ in
            guard let self = self else { return }
            self.blockedUsers = self.data.blockedUsers
            self.collectionView.reloadData()
        }
    }

    func update(rankings error: Bool) {
        rankings = data.get(rankings: filter)
        if rankings?.first != nil {
            contentState = itemCount > 0 ? .data : .empty
        } else {
            contentState = error ? .error : .loading
        }
        updateRank()
        collectionView.set(message: contentState)
        collectionView.reloadData()
    }

    func updateRank() {
        let newRank: Int?
        if filter.isAllTravelers {
            newRank = filter.checklist.rank()
        } else if let scorecard = data.get(scorecard: filter.checklist,
                                           user: data.user?.id) {
            newRank = scorecard.rank(filter: filter)
        } else {
            newRank = nil
        }

        if newRank != filterRank {
            filterRank = newRank
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }

    func user(at rank: Int) -> User? {
        let pageIndex = ((rank - 1) / RankingsPageInfo.perPage) + 1
        let userIndex = (rank - 1) % RankingsPageInfo.perPage
        guard let page = page(at: pageIndex) else {
            load(page: pageIndex)
            return User()
        }

        if page.expired {
            load(page: pageIndex)
        }
        let userId = page.userIds[userIndex]
        return data.get(user: userId)
    }
}

// MARK: - Exposing

extension RankingsPageVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        let list = ChecklistIndex(list: filter.checklist)
        UIRankingsPage.ranks(list).expose(item: collectionView)
    }
}

// MARK: - CollectionCellExposing

extension RankingsPageVC: CollectionCellExposing {

    /// Expose cell to UI tests
    ///
    /// - Parameters:
    ///   - view: Collection
    ///   - path: Index path
    ///   - cell: Cell
    func expose(view: UICollectionView,
                path: IndexPath,
                cell: UICollectionViewCell) {
        if let cell = cell as? RankingCell {
            let list = ChecklistIndex(list: filter.checklist)
            cell.expose(list: list, item: path.item)
        }
    }
}
