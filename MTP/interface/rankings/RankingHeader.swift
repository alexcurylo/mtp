// @copyright Trollwerks Inc.

import Anchorage
import Nuke

final class RankingHeader: UICollectionReusableView, ServiceProvider {

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

    private let avatarImageView = UIImageView {
        $0.heightAnchor == Layout.avatarSize
        $0.widthAnchor == Layout.avatarSize
        $0.cornerRadius = Layout.avatarSize / 2
        $0.backgroundColor = .mercury
        $0.contentMode = .scaleAspectFill
    }
    private let rankLabel = UILabel {
        $0.font = Avenir.medium.of(size: 15)
    }
    private let filterLabel = UILabel {
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

    func set(rank: Int,
             list: Checklist,
             filter: String) {
        filterLabel.text = filter

        if let user = data.user {
            let status = list.status(of: user)
            let total = (status.visited + status.remaining).grouped
            rankLabel.text = "\(rank.grouped) (\(status.visited.grouped)/\(total))"
            avatarImageView.set(thumbnail: user)
        } else {
            rankLabel.text = rank.grouped
            avatarImageView.image = nil
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        Nuke.cancelRequest(for: avatarImageView)
        avatarImageView.image = nil
        rankLabel.text = nil
        filterLabel.text = nil
    }
}

private extension RankingHeader {

    func configure() {
        backgroundColor = .clear

        let rankTitle = UILabel {
            $0.font = Avenir.heavy.of(size: 18)
            $0.text = Localized.myRanking()
            $0.setContentHuggingPriority(.required, for: .horizontal)
        }

        let rankLine = UIStackView(arrangedSubviews: [avatarImageView, rankTitle, rankLabel])
        rankLine.spacing = Layout.spacing
        rankLine.alignment = .center

        let rankView = UIView {
            $0.backgroundColor = .white
            $0.cornerRadius = Layout.cornerRadius
        }
        rankView.addSubview(rankLine)
        rankLine.leadingAnchor == rankView.leadingAnchor + Layout.spacing
        rankLine.centerYAnchor == rankView.centerYAnchor

        let filterTitle = UILabel {
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
