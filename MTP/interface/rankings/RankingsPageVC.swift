// @copyright Trollwerks Inc.

import Anchorage
import Parchment
import RealmSwift

protocol RankingsPageVCDelegate: RankingCellDelegate {

    func didScroll(rankingsPageVC: RankingsPageVC)
}

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

    /// Unavailable coding constructor
    ///
    /// - Parameter coder: An unarchiver object.
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

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

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width,
                      height: Layout.headerHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width,
                      height: Layout.cellHeight)
    }
}

// MARK: - UIScrollViewDelegate

extension RankingsPageVC {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.didScroll(rankingsPageVC: self)
    }
}

// MARK: - UICollectionViewDataSource

extension RankingsPageVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        //swiftlint:disable:next implicitly_unwrapped_optional
        let header: RankingHeader! = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: RankingHeader.reuseIdentifier,
            for: indexPath) as? RankingHeader

        header.set(rank: filterRank,
                   list: filter.checklist,
                   filter: filterDescription,
                   delegate: self)

        return header
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return itemCount
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //swiftlint:disable:next implicitly_unwrapped_optional
        let cell: RankingCell! = collectionView.dequeueReusableCell(
            withReuseIdentifier: RankingCell.reuseIdentifier,
            for: indexPath) as? RankingCell

        let rank = indexPath.row + 1
        let shown = user(at: rank) ?? User()
        let blocked = blockedUsers.contains(shown.userId)
        cell.set(user: blocked ? nil : shown,
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

        blockedObserver = data.observer(of: .scorecard) { [weak self] _ in
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
        RankingVCs.ranks(list).expose(item: collectionView)
    }
}

// MARK: - CollectionCellExposing

extension RankingsPageVC: CollectionCellExposing {

    func expose(view: UICollectionView,
                path: IndexPath,
                cell: UICollectionViewCell) {
        guard let cell = cell as? RankingCell else { return }

        let list = ChecklistIndex(list: filter.checklist)
        let profile = cell.nameLabel
        RankingVCs.profile(list, path.item).expose(item: profile)
        let remaining = cell.remainingButton
        RankingVCs.remaining(list, path.item).expose(item: remaining)
        let visited = cell.visitedButton
        RankingVCs.visited(list, path.item).expose(item: visited)
    }
}
