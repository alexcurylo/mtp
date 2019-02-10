// @copyright Trollwerks Inc.

import Anchorage
import Parchment
import RealmSwift

protocol RankingsPageVCDelegate: AnyObject {

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
        return collectionView
    }()

    weak var delegate: RankingsPageVCDelegate?

    private var rankings: Results<RankingsPageInfo>?
    private var filter = RankingsQuery()
    private var filterDescription = ""
    private var filterRank = 0

    private var checklistsObserver: Observer?
    private var rankingsObserver: Observer?

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

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    func set(list: Checklist) {
        filter = data.lastRankingsQuery
        filter.checklistType = list
        filterDescription = filter.description

        updateRankings()
        observe()
    }
}

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

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.didScroll(rankingsPageVC: self)
    }
}

extension RankingsPageVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: RankingHeader.reuseIdentifier,
            for: indexPath)

        if let header = view as? RankingHeader {
            header.set(rank: filterRank,
                       list: filter.checklistType,
                       filter: filterDescription)
        }

        return view
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        guard let first = rankings?.first else { return 0 }
        guard first.lastPage > 1 else {
            return first.userIds.count
        }

        let paged = (first.lastPage - 1) * RankingsPageInfo.expectedUserCount
        if let last = rankings?.filter("page = lastPage").last {
            return paged + last.userIds.count
        }

        let lastPageQuery = filter.with(page: first.lastPage)
        mtp.loadRankings(query: lastPageQuery) { _ in }

        return paged
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RankingCell.reuseIdentifier,
            for: indexPath)

        if let cell = cell as? RankingCell {
            let rank = indexPath.row + 1
            cell.set(user: user(at: rank),
                     for: rank,
                     in: filter.checklistType)
        }

        return cell
    }
}

private extension RankingsPageVC {

    func observe() {
        guard checklistsObserver == nil else { return }

        checklistsObserver = data.observer(of: .checklists) { [weak self] _ in
            self?.collectionView.reloadData()
        }
        rankingsObserver = data.observer(of: .rankings) { [weak self] info in
            guard let self = self,
                  let queryValue = info[StatusKey.value.rawValue] as? RankingsQuery,
                  queryValue.queryKey == self.filter.queryKey else { return }
            self.updateRankings()
        }
    }

    func updateRankings() {
        rankings = data.get(rankings: filter)

        log.todo("RankingsPageVC rank for filter -- waiting for endpoint")
        filterRank = filter.checklistType.rank()

        collectionView.reloadData()
    }

    func user(at rank: Int) -> User {
        let pageIndex = ((rank - 1) / RankingsPageInfo.expectedUserCount) + 1
        let userIndex = (rank - 1) % RankingsPageInfo.expectedUserCount
        guard let page = rankings?.filter("page = \(pageIndex)").first else {
            let userPageQuery = filter.with(page: pageIndex)
            mtp.loadRankings(query: userPageQuery) { _ in }
            return User()
        }

        let userId = page.userIds[userIndex]
        return data.get(user: userId)
    }
}
