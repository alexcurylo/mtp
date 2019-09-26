// @copyright Trollwerks Inc.

import Anchorage

/// Counts information header
final class CountInfoHeader: UICollectionReusableView, ServiceProvider {

    /// Dequeueing identifier
    static let reuseIdentifier = NSStringFromClass(CountInfoHeader.self)

    private enum Layout {
        static let spacing = (rank: CGFloat(8),
                              label: CGFloat(4))
        static let insets = UIEdgeInsets(top: 0,
                                         left: 8,
                                         bottom: 0,
                                         right: 0)
        static let titleFont = Avenir.black.of(size: 18)
        static let uploadingColor = UIColor.white
        static let rankFont = (normal: Avenir.heavy.of(size: 16),
                               fraction: Avenir.medium.of(size: 15),
                               uploading: Avenir.mediumOblique.of(size: 15))
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
        $0.font = Layout.rankFont.normal
        $0.textColor = .white
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }
    private let fractionLabel = UILabel {
        $0.font = Layout.rankFont.fraction
        $0.textColor = .white
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    private let uploadImageView = UIImageView {
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.image = R.image.upload()
        $0.tintColor = Layout.uploadingColor
    }

    private let unInfoLabel = UILabel {
        $0.font = Layout.rankFont.uploading
        $0.allowsDefaultTighteningForTruncation = true
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.9
        $0.textColor = .white
        $0.text = L.unInfo()
    }
    private var completeStack: UIStackView?

    private var userObserver: Observer?
    private var requestsObserver: Observer?
    private var list: Checklist?
    private var uploading = false

    /// Procedural intializer
    ///
    /// - Parameter frame: Display frame
    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
        observe()
    }

    /// :nodoc:
    required init?(coder: NSCoder) {
        return nil
    }

    /// Handle dependency injection
    ///
    /// - Parameter list: Checklist
    func inject(list: Checklist) {
        self.list = list
        if list == .uncountries {
            completeStack?.addArrangedSubview(unInfoLabel)
        }

        update()
    }

    /// Empty display
    override func prepareForReuse() {
        super.prepareForReuse()

        list = nil
        configure(current: true)
        rankTitle.text = nil
        rankLabel.text = nil
        fractionLabel.text = nil
        unInfoLabel.removeFromSuperview()
    }
}

// MARK: - Private

private extension CountInfoHeader {

    func update() {
        guard let list = list else { return }

        display()

        for request in net.requests.compactMap({ $0 as? MTPVisitedRequest }) {
            if request.changes(list: list) {
                uploading = true
                return configure(current: false)
            }
        }
        if uploading {
            data.update(scorecard: list) { _ in }
        }
        uploading = false
        configure(current: true)
    }

    func display() {
        guard let list = list,
              let user = data.user else { return }

        let status = list.visitStatus(of: user)
        let visitedText = status.visited.grouped
        let totalText = (status.visited + status.remaining).grouped

        let rank = list.rank(of: user)
        guard rank > 0 else {
            rankTitle.text = L.myScore()
            rankLabel.text = L.scoreFraction(visitedText, totalText)
            uploadImageView.isHidden = true
            return
        }

        let rankText = rank.grouped
        rankTitle.text = L.myRanking()
        rankLabel.text = L.rankScore(rankText)
        fractionLabel.text = L.rankFraction(visitedText, totalText)
    }

    func observe() {
        guard userObserver == nil else { return }

        userObserver = data.observer(of: .user) { [weak self] _ in
            self?.update()
        }
        requestsObserver = net.observer(of: .requests) { [weak self] _ in
            self?.update()
        }
    }

    func configure(current: Bool) {
        if current {
            uploading = false
            uploadImageView.isHidden = true
            rankLabel.textColor = .white
            rankLabel.font = Layout.rankFont.normal
        } else {
            uploadImageView.isHidden = false
            rankLabel.textColor = Layout.uploadingColor
            rankLabel.font = Layout.rankFont.uploading
        }
    }

    func configure() {
        let labels = UIStackView(arrangedSubviews: [rankTitle,
                                                    rankLabel,
                                                    fractionLabel]).with {
            $0.alignment = .center
            $0.spacing = Layout.spacing.label
        }
        let infoStack = UIStackView(arrangedSubviews: [labels,
                                                       uploadImageView]).with {
            $0.spacing = Layout.spacing.rank
            $0.alignment = .center
        }

        let stack = UIStackView(arrangedSubviews: [infoStack]).with {
            $0.spacing = 2
            $0.axis = .vertical
            $0.distribution = .fillEqually
        }
        completeStack = stack

        addSubview(stack)
        stack.edgeAnchors == edgeAnchors + Layout.insets
    }
}
