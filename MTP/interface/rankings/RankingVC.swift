// @copyright Trollwerks Inc.

import Anchorage
import Parchment
import UIKit

protocol RankingVCDelegate: AnyObject {

    func didScroll(rankingVC: RankingVC)
}

final class RankingVC: UIViewController {

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

    weak var delegate: RankingVCDelegate?

    private var members: [Int] = []
    private var filterDescription: String = ""
    private var rank = 0

    var userObserver: Observer?
    var locationsObserver: Observer?

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

        observe()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    func set(members list: [Int], filter: UserFilter?) {
        members = list
        filterDescription = filter?.description ?? Localized.allLocations()
        log.todo("RankingVC header rank)")
        rank = 9_999

        collectionView.reloadData()
    }
}

extension RankingVC: UICollectionViewDelegateFlowLayout {

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
        delegate?.didScroll(rankingVC: self)
    }
}

extension RankingVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: RankingHeader.reuseIdentifier,
            for: indexPath)

        (view as? RankingHeader)?.set(rank: rank, for: filterDescription)

        return view
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return members.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RankingCell.reuseIdentifier,
            for: indexPath)

        let rank = indexPath.row + 1
        if let user = gestalt.user {
            (cell as? RankingCell)?.set(user: user, for: rank)
        }

        return cell
    }

    func observe() {
        guard userObserver == nil else { return }

        userObserver = gestalt.newUserObserver { [weak self] in
            log.todo("RankingVC update")
            self?.collectionView.reloadData()
        }
        locationsObserver = gestalt.newLocationsObserver { [weak self] in
            log.todo("RankingVC update")
            self?.collectionView.reloadData()
        }
    }
}
