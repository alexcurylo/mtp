// @copyright Trollwerks Inc.

import Anchorage

/// Notifies of header taps
protocol RankingHeaderDelegate: AnyObject {

    /// Tap notification
    /// - Parameter header: Tapped header
    func tapped(header: RankingHeader)
}

/// Header for rankings page
final class RankingHeader: UICollectionReusableView, ServiceProvider {

    /// Dequeueing identifier
    static let reuseIdentifier = NSStringFromClass(RankingHeader.self)

    private enum Layout {
        static let sizeAvatar = CGFloat(25)
        static let cornerRadius = CGFloat(4)
        static let spacing = (rank: CGFloat(8),
                              label: CGFloat(4))
        static let updatingColor = UIColor.black
        static let rankFont = (normal: Avenir.medium.of(size: 15),
                               updating: Avenir.mediumOblique.of(size: 15))
        static let insets = UIEdgeInsets(top: spacing.rank,
                                         left: 0,
                                         bottom: spacing.rank,
                                         right: 0)
        static let filterMargins = UIEdgeInsets(top: 0,
                                                left: spacing.rank,
                                                bottom: 0,
                                                right: 0)
   }

    private let avatarImageView = UIImageView {
        $0.heightAnchor == Layout.sizeAvatar
        $0.widthAnchor == Layout.sizeAvatar
        $0.cornerRadius = Layout.sizeAvatar / 2
        $0.backgroundColor = .mercury
        $0.contentMode = .scaleAspectFill
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }
    private let rankTitle = UILabel {
        $0.font = Avenir.heavy.of(size: 18)
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        $0.allowsDefaultTighteningForTruncation = true
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.9
    }
    private let rankLabel = UILabel {
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.allowsDefaultTighteningForTruncation = true
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.9
    }
    private let fractionLabel = UILabel {
        $0.font = Avenir.book.of(size: 14)
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    private let uploadImageView = UIImageView {
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.image = R.image.upload()
        $0.tintColor = Layout.updatingColor
    }
    private let rankView = UIView {
        $0.backgroundColor = .white
        $0.cornerRadius = Layout.cornerRadius
    }

    private let filterLabel = UILabel {
        $0.font = Avenir.medium.of(size: 15)
        $0.textColor = .white
        $0.allowsDefaultTighteningForTruncation = true
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.9
    }

    private var lines: UIStackView?

    private weak var delegate: RankingHeaderDelegate?

    private var list: Checklist?
    private var rank: Int?
    private var scorecardObserver: Observer?
    private var userObserver: Observer?
    private var requestsObserver: Observer?
    private var uploading = false

    /// Procedural intializer
    /// - Parameter frame: Display frame
    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
    }

    /// :nodoc:
    required init?(coder: NSCoder) { nil }

    /// Inject display data
    /// - Parameters:
    ///   - rank: Rank if any
    ///   - list: Checklist
    ///   - filter: Filter
    ///   - delegate: Delegate
    func inject(rank: Int?,
                list: Checklist,
                filter: String,
                delegate: RankingHeaderDelegate) {
        self.delegate = delegate

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

        self.list = list
        self.rank = rank
        update()
        observe()
    }

    /// Empty display
    override func prepareForReuse() {
        super.prepareForReuse()

        list = nil
        configure(current: true)
        delegate = nil
        avatarImageView.prepareForReuse()
        rankLabel.text = nil
        fractionLabel.text = nil
        filterLabel.text = nil
    }
}

// MARK: - Private

private extension RankingHeader {

    func observe() {
        guard scorecardObserver == nil else { return }

        scorecardObserver = data.observer(of: .scorecard) { [weak self] _ in
            self?.update()
        }
        userObserver = data.observer(of: .user) { [weak self] _ in
            self?.update()
        }
        requestsObserver = net.observer(of: .requests) { [weak self] _ in
            self?.update()
        }
    }

    // swiftlint:disable:next function_body_length
    func update() {
        guard let list = list,
              let user = self.data.user else { return }
        guard !user.isWaiting else {
            rankTitle.text = ""
            rankLabel.text = L.verify()
            rankLabel.textColor = Layout.updatingColor
            rankLabel.font = Layout.rankFont.updating
            fractionLabel.text = ""
            uploadImageView.isHidden = true
            return
        }
        guard user.isComplete else {
            rankTitle.text = ""
            rankLabel.text = L.complete()
            rankLabel.textColor = nil
            rankLabel.font = Layout.rankFont.updating
            fractionLabel.text = ""
            uploadImageView.isHidden = true
            return
        }

        rank = list.rank(of: user)
        let status = list.visitStatus(of: user)
        let visitedText = status.visited.grouped
        let totalText = (status.visited + status.remaining).grouped
        guard let rank = rank else {
            rankTitle.text = L.myScore()
            rankLabel.text = L.scoreFraction(visitedText, totalText)
            rankLabel.textColor = nil
            rankLabel.font = Layout.rankFont.normal
            fractionLabel.text = ""
            uploadImageView.isHidden = true
            return
        }

        let rankText = rank.grouped
        rankTitle.text = L.myRanking()
        rankLabel.text = L.rankScore(rankText)
        fractionLabel.text = L.rankFraction(visitedText, totalText)

        for request in net.requests.compactMap({ $0 as? MTPVisitedRequest }) {
            if request.changes(list: list) {
                uploading = true
                return configure(current: false)
            }
        }
        if uploading {
            data.update(rankings: list) { _ in }
        }
        uploading = false
        configure(current: true)
    }

    func configure(current: Bool) {
        if current {
            uploading = false
            uploadImageView.isHidden = true
            rankLabel.textColor = nil
            rankLabel.font = Layout.rankFont.normal
        } else {
            uploadImageView.isHidden = false
            rankLabel.textColor = Layout.updatingColor
            rankLabel.font = Layout.rankFont.updating
        }
    }

    // swiftlint:disable:next function_body_length
    func configure() {
        backgroundColor = .clear

        let labels = UIStackView(arrangedSubviews: [
            rankTitle,
            rankLabel,
            fractionLabel,
        ]).with {
            $0.alignment = .center
            $0.spacing = Layout.spacing.label
        }
        let rankLine = UIStackView(arrangedSubviews: [
            avatarImageView,
            labels,
            uploadImageView,
        ]).with {
            $0.spacing = Layout.spacing.rank
            $0.alignment = .center
        }

        rankView.addSubview(rankLine)
        rankLine.horizontalAnchors == rankView.horizontalAnchors + Layout.spacing.rank
        rankLine.centerYAnchor == rankView.centerYAnchor

        let filterTitle = UILabel {
            $0.font = Avenir.black.of(size: 18)
            $0.text = L.topTravelers()
            $0.textColor = .white
            $0.setContentHuggingPriority(.required, for: .horizontal)
        }

        let filterLine = UIStackView(arrangedSubviews: [
            filterTitle,
            filterLabel,
        ]).with {
            $0.spacing = Layout.spacing.rank
            $0.alignment = .firstBaseline
            $0.layoutMargins = Layout.filterMargins
            $0.isLayoutMarginsRelativeArrangement = true
        }

        let stack = UIStackView(arrangedSubviews: [
            rankView,
            filterLine,
        ]).with {
            $0.axis = .vertical
            $0.distribution = .fillEqually
        }
        addSubview(stack)
        stack.edgeAnchors == edgeAnchors + Layout.insets
        lines = stack

        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(tapped))
        addGestureRecognizer(tap)
    }

    @objc func tapped(_ sender: UIGestureRecognizer) {
        delegate?.tapped(header: self)
    }
}
