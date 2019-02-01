// @copyright Trollwerks Inc.

import Anchorage

final class RankingHeader: UICollectionReusableView {

    static let reuseIdentifier = NSStringFromClass(RankingHeader.self)

    private enum Layout {
        static let avatarSize = CGFloat(25)
        static let cornerRadius = CGFloat(4)
        static let spacing = CGFloat(8)
        static let insets = UIEdgeInsets(top: spacing,
                                         left: 0,
                                         bottom: spacing,
                                         right: 0)
        static let filterMargins = UIEdgeInsets(top: 0,
                                                left: spacing,
                                                bottom: 0,
                                                right: 0)
   }

    private let avatarImageView: UIImageView = create {
        $0.heightAnchor == Layout.avatarSize
        $0.widthAnchor == Layout.avatarSize
        $0.cornerRadius = Layout.avatarSize / 2
        $0.backgroundColor = .mercury
        $0.contentMode = .scaleAspectFill
    }
    private let rankLabel: UILabel = create {
        $0.font = Avenir.medium.of(size: 15)
    }
    private let filterLabel: UILabel = create {
        $0.font = Avenir.medium.of(size: 15)
        $0.textColor = .white
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(rank: Int, for filter: String) {
        avatarImageView.setImage(for: gestalt.user)
        rankLabel.text = rank.grouped
        filterLabel.text = filter
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        avatarImageView.image = nil
        rankLabel.text = nil
        filterLabel.text = nil
    }
}

private extension RankingHeader {

    func configure() {
        backgroundColor = .clear

        let rankTitle: UILabel = create {
            $0.font = Avenir.heavy.of(size: 18)
            $0.text = Localized.myRanking()
            $0.setContentHuggingPriority(.required, for: .horizontal)
        }

        let rankLine = UIStackView(arrangedSubviews: [avatarImageView, rankTitle, rankLabel])
        rankLine.spacing = Layout.spacing
        rankLine.alignment = .center

        let rankView: UIView = create {
            $0.backgroundColor = .white
            $0.cornerRadius = Layout.cornerRadius
        }
        rankView.addSubview(rankLine)
        rankLine.leadingAnchor == rankView.leadingAnchor + Layout.spacing
        rankLine.centerYAnchor == rankView.centerYAnchor

        let filterTitle: UILabel = create {
            $0.font = Avenir.black.of(size: 18)
            $0.text = Localized.topTravelers()
            $0.textColor = .white
            $0.setContentHuggingPriority(.required, for: .horizontal)
        }

        let filterLine = UIStackView(arrangedSubviews: [filterTitle, filterLabel])
        filterLine.spacing = Layout.spacing
        filterLine.alignment = .firstBaseline
        filterLine.layoutMargins = Layout.filterMargins
        filterLine.isLayoutMarginsRelativeArrangement = true

        let lines = UIStackView(arrangedSubviews: [rankView, filterLine])
        lines.axis = .vertical
        lines.distribution = .fillEqually
        addSubview(lines)
        lines.edgeAnchors == edgeAnchors + Layout.insets
    }
}
