// @copyright Trollwerks Inc.

import Anchorage

class RankingCell: UICollectionViewCell {

    static let reuseIdentifier: String = "RankingCell"

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
