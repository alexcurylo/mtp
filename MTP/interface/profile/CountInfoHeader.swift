// @copyright Trollwerks Inc.

import Anchorage

final class CountInfoHeader: UICollectionReusableView, ServiceProvider {

    static let reuseIdentifier = NSStringFromClass(CountInfoHeader.self)

    func set(list: Checklist) {
        guard let user = data.user else { return }

        let status = list.status(of: user)
        let visitedText = status.visited.grouped
        let totalText = (status.visited + status.remaining).grouped

        let rank = list.rank(of: user)
        guard rank > 0 else {
            rankTitle.text = L.myScore()
            rankLabel.text = L.scoreFraction(visitedText, totalText)
            updatingStack?.isHidden = true
            return
        }

        let updatingTime = 0
        if updatingTime > 0 {
            updatingLabel.text = L.updating(updatingTime)
            updatingStack?.isHidden = false
            rankLabel.textColor = Layout.updatingColor
            rankLabel.font = Layout.rankFont.updating
        } else {
            updatingStack?.isHidden = true
            rankLabel.textColor = .white
            rankLabel.font = Layout.rankFont.normal
        }

        let rankText = rank.grouped
        rankTitle.text = L.myRanking()
        rankLabel.text = L.rankScore(rankText)
        fractionLabel.text = L.rankFraction(visitedText, totalText)
    }

    private enum Layout {
        static let updatingSize = CGFloat(15)
        static let spacing = (rank: CGFloat(8),
                              label: CGFloat(4),
                              updating: CGFloat(2))
        static let insets = UIEdgeInsets(top: 0,
                                         left: 8,
                                         bottom: 0,
                                         right: 0)
        static let titleFont = Avenir.black.of(size: 18)
        static let updatingColor = UIColor.white
        static let rankFont = (normal: Avenir.heavy.of(size: 16),
                               fraction: Avenir.medium.of(size: 15),
                               updating: Avenir.mediumOblique.of(size: 15))
        static let infoFont = Avenir.heavy.of(size: 15)
    }

    private let rankTitle = UILabel {
        $0.font = Layout.titleFont
        $0.textColor = .white
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        $0.allowsDefaultTighteningForTruncation = true
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.9
    }
    private let rankLabel = UILabel {
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }
    private let fractionLabel = UILabel {
        $0.font = Layout.rankFont.fraction
        $0.textColor = .white
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    private let updatingImageView = UIImageView {
        $0.heightAnchor == Layout.updatingSize
        $0.widthAnchor == Layout.updatingSize
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.image = R.image.updating()
        $0.tintColor = Layout.updatingColor
    }
    private let updatingLabel = UILabel {
        $0.font = Avenir.bookOblique.of(size: 13)
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        $0.allowsDefaultTighteningForTruncation = true
        $0.textColor = Layout.updatingColor
    }
    private var updatingStack: UIStackView?

    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        rankTitle.text = nil
        rankLabel.text = nil
    }
}

// MARK: - Private

private extension CountInfoHeader {

    func configure() {
        let labels = UIStackView(arrangedSubviews: [rankTitle,
                                                    rankLabel,
                                                    fractionLabel]).with {
            $0.alignment = .center
            $0.spacing = Layout.spacing.label
        }
        let updating = UIStackView(arrangedSubviews: [updatingImageView,
                                                      updatingLabel]).with {
            $0.alignment = .center
            $0.spacing = Layout.spacing.updating
        }
        updatingStack = updating
        let stack = UIStackView(arrangedSubviews: [labels,
                                                   updating]).with {
            $0.spacing = Layout.spacing.rank
            $0.alignment = .center
        }
        addSubview(stack)
        stack.edgeAnchors == edgeAnchors + Layout.insets
    }
}
