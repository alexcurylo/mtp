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
        switch rank {
        case 0:
            rankTitle.text = L.myScore()
            rankLabel.text = L.scoreFraction(visitedText, totalText)
        default:
            let rankText = rank.grouped
            rankTitle.text = L.myRanking()
            rankLabel.text = L.rankScoreFraction(rankText, visitedText, totalText)
        }
    }

    private enum Layout {
        static let spacing = CGFloat(8)
        static let insets = UIEdgeInsets(top: 0,
                                         left: 8,
                                         bottom: 0,
                                         right: 0)
        static let titleFont = Avenir.black.of(size: 18)
        static let infoFont = Avenir.heavy.of(size: 15)
    }

    private let rankTitle = UILabel {
        $0.font = Layout.titleFont
        $0.textColor = .white
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }
    private let rankLabel = UILabel {
        $0.font = Layout.infoFont
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

    override func prepareForReuse() {
        super.prepareForReuse()

        rankTitle.text = nil
        rankLabel.text = nil
    }
}

// MARK: - Private

private extension CountInfoHeader {

    func configure() {
        let stack = UIStackView(arrangedSubviews: [rankTitle,
                                                   rankLabel]).with {
            $0.spacing = Layout.spacing
            $0.alignment = .firstBaseline
        }
        addSubview(stack)
        stack.edgeAnchors == edgeAnchors + Layout.insets
    }
}
