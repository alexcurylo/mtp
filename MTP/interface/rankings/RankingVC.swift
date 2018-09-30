// @copyright Trollwerks Inc.

import Anchorage
import Parchment
import UIKit

protocol RankingVCDelegate: AnyObject {
    func didScroll(rankingVC: RankingVC)
}

final class RankingVC: UIViewController {

    weak var delegate: RankingVCDelegate?

    private let members: [Int]

    private let collectionViewLayout: UICollectionViewFlowLayout = create {
        $0.sectionInset = UIEdgeInsets(top: 18, left: 0, bottom: 18, right: 0)
        $0.minimumLineSpacing = 15
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
        return CGSize(
            width: collectionView.bounds.width - 36,
            height: 220)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.didScroll(rankingVC: self)
    }
}

extension RankingVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RankingCell.reuseIdentifier,
            // swiftlint:disable:next force_cast
            for: indexPath) as! RankingCell

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
