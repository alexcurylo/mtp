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
        return collectionView
    }()

    weak var delegate: RankingsPageVCDelegate?

    private var rankings: Results<RankingsPageInfo>?
    private var filter = RankingsQuery()
    private var filterDescription = ""
    private var filterRank: Int?

    private var visitedObserver: Observer?
    private var rankingsObserver: Observer?
    private var scorecardObserver: Observer?

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
                   list: filter.checklistType,
                   filter: filterDescription)

        return header
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        guard let first = rankings?.first else { return 0 }
        guard first.lastPage > 1 else {
            return first.userIds.count
        }

        let paged = (first.lastPage - 1) * RankingsPageInfo.perPage
        if let last = rankings?.filter("page = lastPage").last {
            return paged + last.userIds.count
        }

        let lastPageQuery = filter.with(page: first.lastPage)
        mtp.loadRankings(query: lastPageQuery) { _ in }

        return paged
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //swiftlint:disable:next implicitly_unwrapped_optional
        let cell: RankingCell! = collectionView.dequeueReusableCell(
            withReuseIdentifier: RankingCell.reuseIdentifier,
            for: indexPath) as? RankingCell

        let rank = indexPath.row + 1
        cell.set(user: user(at: rank) ?? User(),
                 for: rank,
                 in: filter.checklistType,
                 delegate: delegate)

        return cell
    }
}

// MARK: - Private

private extension RankingsPageVC {

    func observe() {
        guard visitedObserver == nil else { return }

        visitedObserver = data.observer(of: .visited) { [weak self] _ in
            self?.collectionView.reloadData()
        }

        rankingsObserver = data.observer(of: .rankings) { [weak self] info in
            guard let self = self,
                  let queryValue = info[StatusKey.value.rawValue] as? RankingsQuery,
                  queryValue.queryKey == self.filter.queryKey else { return }
            self.updateRankings()
        }

        scorecardObserver = data.observer(of: .scorecard) { [weak self] _ in
            self?.updateRank()
        }
    }

    func updateRankings() {
        rankings = data.get(rankings: filter)
        updateRank()
        collectionView.reloadData()
    }

    func updateRank() {
        let newRank: Int?
        if filter.isAllTravelers {
            newRank = filter.checklistType.rank()
        } else if let scorecard = data.get(scorecard: filter.checklistType,
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
        // swiftlint:disable:next first_where
        guard let page = rankings?.filter("page = \(pageIndex)").first else {
            let userPageQuery = filter.with(page: pageIndex)
            mtp.loadRankings(query: userPageQuery) { _ in }
            return User()
        }

        let userId = page.userIds[userIndex]
        return data.get(user: userId)
    }
}
