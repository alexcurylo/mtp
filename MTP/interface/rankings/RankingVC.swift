// @copyright Trollwerks Inc.

import Anchorage
import Parchment
import UIKit

protocol RankingVCDelegate: AnyObject {
    func didScroll(rankingVC: RankingVC)
}

final class RankingVC: UIViewController {

    private enum Layout {
        static let cellHeight = CGFloat(90)
        static let sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        static let lineSpacing = CGFloat(8)
    }

    weak var delegate: RankingVCDelegate?

    private let members: [Int]

    private let collectionViewLayout: UICollectionViewFlowLayout = create {
        $0.sectionInset = Layout.sectionInset
        $0.minimumLineSpacing = Layout.lineSpacing
    }

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    init(members: [Int],
         options: PagingOptions) {
        self.members = members
        super.init(nibName: nil, bundle: nil)

        view.addSubview(collectionView)
        collectionView.edgeAnchors == view.edgeAnchors

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            RankingCell.self,
            forCellWithReuseIdentifier: RankingCell.reuseIdentifier)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionViewLayout.invalidateLayout()
    }
}

extension RankingVC: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let insets = Layout.sectionInset.left + Layout.sectionInset.right
        return CGSize(width: collectionView.bounds.width - insets,
                      height: Layout.cellHeight)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.didScroll(rankingVC: self)
    }
}

extension RankingVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RankingCell.reuseIdentifier,
            for: indexPath) as? RankingCell else {
                fatalError("RankingCell not registered")
        }

        let rank = indexPath.row
        cell.set(member: members[rank], for: rank)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return members.count
    }
}

private class RankingCell: UICollectionViewCell {

    fileprivate static let reuseIdentifier: String = "RankingCell"

    private let titleLabel: UILabel = create {
        $0.font = Avenir.heavy.of(size: 16)
        $0.textColor = .black
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 4
        contentView.clipsToBounds = true
        contentView.addSubview(titleLabel)
        titleLabel.edgeAnchors == contentView.edgeAnchors
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(member id: Int, for rank: Int) {
        titleLabel.text = "Rank: \(rank) Member: \(id)"
    }
}
