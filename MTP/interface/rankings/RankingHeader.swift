// @copyright Trollwerks Inc.

import Anchorage

protocol RankingHeaderDelegate: AnyObject {

    func tapped(header: RankingHeader)
}

final class RankingHeader: UICollectionReusableView, ServiceProvider {

    static let reuseIdentifier = NSStringFromClass(RankingHeader.self)

    private enum Layout {
        static let size = (avatar: CGFloat(25),
                           updating: CGFloat(15))
        static let cornerRadius = CGFloat(4)
        static let spacing = (rank: CGFloat(8),
                              label: CGFloat(4),
                              updating: CGFloat(2))
        static let updatingColor = UIColor.carnation
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
        $0.heightAnchor == Layout.size.avatar
        $0.widthAnchor == Layout.size.avatar
        $0.cornerRadius = Layout.size.avatar / 2
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
    private let updatingImageView = UIImageView {
        $0.heightAnchor == Layout.size.updating
        $0.widthAnchor == Layout.size.updating
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.image = R.image.updating()
        $0.tintColor = Layout.updatingColor
    }
    private let updatingLabel = UILabel {
        $0.font = Avenir.lightOblique.of(size: 13)
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        $0.allowsDefaultTighteningForTruncation = true
        $0.textColor = Layout.updatingColor
    }
    private var updatingStack: UIStackView?
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
    private let scheduler = Scheduler()
    private var updating = false

    private var list: Checklist = .locations
    private var rank: Int?
    private var scorecardObserver: Observer?
    private var userObserver: Observer?

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
        scheduler.fire(every: 60) { [weak self, list] in
            self?.update(timer: list)
        }
        update(rank: user)

        observe()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        configure(current: true)
        delegate = nil
        avatarImageView.prepareForReuse()
        rankLabel.text = nil
        fractionLabel.text = nil
        filterLabel.text = nil
    }
}

private extension RankingHeader {

    func observe() {
        guard scorecardObserver == nil else { return }

        scorecardObserver = data.observer(of: .scorecard) { [weak self] _ in
            guard let self = self,
                  let user = self.data.user else { return }

            self.update(rank: user)
        }

        userObserver = data.observer(of: .user) { [weak self] _ in
            guard let self = self,
                  let user = self.data.user else { return }

            self.update(rank: user)
        }
    }

    func update(rank user: UserJSON) {
        guard !user.isWaiting else {
            scheduler.stop()
            rankTitle.text = ""
            rankLabel.text = L.verify()
            rankLabel.textColor = Layout.updatingColor
            rankLabel.font = Layout.rankFont.updating
            fractionLabel.text = ""
            updatingStack?.isHidden = true
            return
        }

        guard user.isComplete else {
            scheduler.stop()
            rankTitle.text = ""
            rankLabel.text = L.complete()
            rankLabel.textColor = nil
            rankLabel.font = Layout.rankFont.updating
            fractionLabel.text = ""
            updatingStack?.isHidden = true
            return
        }

        rank = list.rank(of: user)
        let status = list.visitStatus(of: user)
        let visitedText = status.visited.grouped
        let totalText = (status.visited + status.remaining).grouped
        guard let rank = rank else {
            scheduler.stop()
            rankTitle.text = L.myScore()
            rankLabel.text = L.scoreFraction(visitedText, totalText)
            rankLabel.textColor = nil
            rankLabel.font = Layout.rankFont.normal
            fractionLabel.text = ""
            updatingStack?.isHidden = true
            return
        }

        let rankText = rank.grouped
        rankTitle.text = L.myRanking()
        rankLabel.text = L.rankScore(rankText)
        fractionLabel.text = L.rankFraction(visitedText, totalText)
    }

    func update(timer list: Checklist) {
        let status = list.rankingsStatus
        configure(current: status.isCurrent)
        guard !status.isCurrent else { return }

        updatingLabel.text = L.updateWait(status.wait)
        guard status.isPending,
            scheduler.isActive,
            !updating else { return }

        updating = true
        data.update(scorecard: list) { [weak self] updated in
            guard let self = self, self.updating else { return }

            self.updating = false
            self.configure(current: updated)
            self.data.update(rankings: list) { _ in }
        }
    }

    func configure(current: Bool) {
        if current {
            updating = false
            scheduler.stop()
            updatingStack?.isHidden = true
            rankLabel.textColor = nil
            rankLabel.font = Layout.rankFont.normal
        } else {
            updatingStack?.isHidden = false
            rankLabel.textColor = Layout.updatingColor
            rankLabel.font = Layout.rankFont.updating
        }
    }

    func configure() {
        backgroundColor = .clear

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
        let rankLine = UIStackView(arrangedSubviews: [avatarImageView,
                                                      labels,
                                                      updating]).with {
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

        let filterLine = UIStackView(arrangedSubviews: [filterTitle,
                                                        filterLabel]).with {
            $0.spacing = Layout.spacing.rank
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

        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(tapped))
        addGestureRecognizer(tap)
    }

    @objc func tapped(_ sender: UIGestureRecognizer) {
        delegate?.tapped(header: self)
    }
}
