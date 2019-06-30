// @copyright Trollwerks Inc.

import Anchorage

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
    private let rankTitle = UILabel {
        $0.font = Avenir.heavy.of(size: 18)
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }
    private let rankLabel = UILabel {
        $0.font = Avenir.medium.of(size: 15)
    }
    private let rankView = UIView {
        $0.backgroundColor = .white
        $0.cornerRadius = Layout.cornerRadius
    }

    private let filterLabel = UILabel {
        $0.font = Avenir.medium.of(size: 15)
        $0.textColor = .white
    }

    private var lines: UIStackView?

    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(rank: Int?,
             list: Checklist,
             filter: String) {
        filterLabel.text = filter

        guard let user = data.user else {
            lines?.removeArrangedSubview(rankView)
            rankView.removeFromSuperview()
            return
        }
        if rankView.superview == nil {
            lines?.insertArrangedSubview(rankView, at: 0)
        }

        avatarImageView.load(image: user)

        let status = list.status(of: user)
        let visitedText = status.visited.grouped
        let totalText = (status.visited + status.remaining).grouped
        if let rank = rank {
            let rankText = rank.grouped
            rankTitle.text = L.myRanking()
            rankLabel.text = L.rankScoreFraction(rankText, visitedText, totalText)
        } else {
            rankTitle.text = L.myScore()
            rankLabel.text = L.scoreFraction(visitedText, totalText)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        avatarImageView.prepareForReuse()
        rankLabel.text = nil
        filterLabel.text = nil
    }
}

private extension RankingHeader {

    func configure() {
        backgroundColor = .clear

        let rankLine = UIStackView(arrangedSubviews: [avatarImageView,
                                                      rankTitle,
                                                      rankLabel]).with {
            $0.spacing = Layout.spacing
            $0.alignment = .center
        }

        rankView.addSubview(rankLine)
        rankLine.leadingAnchor == rankView.leadingAnchor + Layout.spacing
        rankLine.centerYAnchor == rankView.centerYAnchor

        let filterTitle = UILabel {
            $0.font = Avenir.black.of(size: 18)
            $0.text = L.topTravelers()
            $0.textColor = .white
            $0.setContentHuggingPriority(.required, for: .horizontal)
        }

        let filterLine = UIStackView(arrangedSubviews: [filterTitle,
                                                        filterLabel]).with {
            $0.spacing = Layout.spacing
            $0.alignment = .firstBaseline
            $0.layoutMargins = Layout.filterMargins
            $0.isLayoutMarginsRelativeArrangement = true
        }

        let stack = UIStackView(arrangedSubviews: [rankView,
                                                   filterLine]).with {
            $0.axis = .vertical
            $0.distribution = .fillEqually
        }
        addSubview(stack)
        stack.edgeAnchors == edgeAnchors + Layout.insets
        lines = stack
    }
}
