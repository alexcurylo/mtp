// @copyright Trollwerks Inc.

import Anchorage

protocol RankingCellDelegate: AnyObject {

    func tapped(profile user: User)
    func tapped(remaining user: User, list: Checklist)
    func tapped(visited user: User, list: Checklist)
}

final class RankingCell: UICollectionViewCell, ServiceProvider {

    static let reuseIdentifier = NSStringFromClass(RankingCell.self)

    private enum Layout {
        static let avatarSize = CGFloat(48)
        static let rankSize = CGFloat(18)
        static let buttonHeight = CGFloat(35)
        static let margin = CGFloat(8)
        static let spacing = CGSize(width: 8, height: 4)
        static let cornerRadius = CGFloat(4)
        static let overlap = CGFloat(-8)
        static let updatingColor = UIColor.carnation
        static let rankFont = (normal: Avenir.heavy.of(size: 10),
                               updating: Avenir.heavyOblique.of(size: 10))
    }

    private let avatarImageView = UIImageView {
        $0.heightAnchor == Layout.avatarSize
        $0.widthAnchor == Layout.avatarSize
        $0.cornerRadius = Layout.avatarSize / 2
        $0.backgroundColor = .mercury
        $0.contentMode = .scaleAspectFill
    }
    private let rankLabel = UILabel {
        $0.font = Layout.rankFont.normal
        $0.heightAnchor == Layout.rankSize
        $0.widthAnchor == Layout.avatarSize - Layout.margin
        $0.cornerRadius = Layout.rankSize / 2
        $0.backgroundColor = .gallery
        $0.textAlignment = .center
    }

    let nameLabel = UILabel {
        $0.font = Avenir.heavy.of(size: 18)
        $0.numberOfLines = 2
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        $0.isUserInteractionEnabled = true
    }
    private let countryLabel = UILabel {
        $0.font = Avenir.medium.of(size: 15)
        $0.numberOfLines = 1
        $0.minimumScaleFactor = 0.6
        $0.adjustsFontSizeToFitWidth = true
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }

    let visitedButton = GradientButton(type: .system).with {
        configure(button: $0)
    }
    let remainingButton = GradientButton(type: .system).with {
        configure(button: $0)
    }

    private var user: User?
    private var list: Checklist?
    private weak var delegate: RankingCellDelegate?
    private let scheduler = Scheduler()
    private var updating = false

    /// Procedural intializer
    ///
    /// - Parameter frame: Display frame
    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(user: User,
             for rank: Int,
             in list: Checklist,
             delegate: RankingCellDelegate?) {
        self.user = user
        self.list = list
        self.delegate = delegate

        nameLabel.text = user.fullName
        countryLabel.text = user.locationName

        guard user.userId != 0 else {
            nameLabel.text = L.loading()
            avatarImageView.image = nil
            visitedButton.isHidden = true
            remainingButton.isHidden = true
            rankLabel.text = nil
            return
        }

        avatarImageView.load(image: user)

        let order = list.order(of: user)
        rankLabel.text = order > 0 ? order.grouped : L.deceased()

        let status = list.visitStatus(of: user)
        visitedButton.isHidden = false
        let visited = L.visitedCount(status.visited)
        visitedButton.setTitle(visited, for: .normal)
        remainingButton.isHidden = false
        let remaining = L.remainingCount(status.remaining)
        remainingButton.setTitle(remaining, for: .normal)

        if user.isSelf {
            scheduler.fire(every: 60) { [weak self, list] in
                self?.update(timer: list)
            }
        } else {
            configure(current: true)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        configure(current: true)
        user = nil
        list = nil
        delegate = nil
        avatarImageView.prepareForReuse()
        rankLabel.text = nil
        nameLabel.text = nil
        countryLabel.text = nil
        visitedButton.setTitle(nil, for: .normal)
        remainingButton.setTitle(nil, for: .normal)
   }
}

private extension RankingCell {

    func update(timer list: Checklist) {
        let status = list.rankingsStatus
        configure(current: status.isCurrent)
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
            rankLabel.textColor = nil
            rankLabel.font = Layout.rankFont.normal
        } else {
            rankLabel.textColor = Layout.updatingColor
            rankLabel.font = Layout.rankFont.updating
        }
    }

    class func configure(button: GradientButton) {
        button.orientation = GradientOrientation.horizontal.rawValue
        button.startColor = .dodgerBlue
        button.endColor = .azureRadiance
        button.cornerRadius = Layout.cornerRadius
        button.contentEdgeInsets = UIEdgeInsets(
            top: 0,
            left: Layout.margin,
            bottom: 0,
            right: Layout.margin)
        button.titleLabel?.font = Avenir.heavy.of(size: 14)
        button.setTitleColor(.white, for: .normal)
        button.heightAnchor == Layout.buttonHeight
   }

    func configure() {
        contentView.backgroundColor = .white
        contentView.cornerRadius = Layout.cornerRadius

        let tap = UITapGestureRecognizer(target: self, action: #selector(profileTapped))
        nameLabel.addGestureRecognizer(tap)
        remainingButton.addTarget(self, action: #selector(remainingTapped), for: .touchUpInside)
        visitedButton.addTarget(self, action: #selector(visitedTapped), for: .touchUpInside)

        let badges = UIStackView(arrangedSubviews: [avatarImageView,
                                                    rankLabel]).with {
            $0.axis = .vertical
            $0.alignment = .center
            $0.spacing = Layout.overlap
            $0.setContentHuggingPriority(.required, for: .horizontal)
        }

        let labels = UIStackView(arrangedSubviews: [nameLabel,
                                                    countryLabel]).with {
            $0.axis = .vertical
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        }

        let buttons = UIStackView(arrangedSubviews: [visitedButton,
                                                     remainingButton]).with {
            $0.axis = .vertical
            $0.distribution = .fillEqually
            $0.alignment = .trailing
            $0.spacing = Layout.spacing.height
            $0.setContentHuggingPriority(.required, for: .horizontal)
        }

        let infos = UIStackView(arrangedSubviews: [badges,
                                                   labels,
                                                   buttons]).with {
            $0.spacing = Layout.spacing.width
            $0.alignment = .center
            $0.distribution = .fill
        }
        contentView.addSubview(infos)
        infos.edgeAnchors == contentView.edgeAnchors + Layout.margin
    }

    @IBAction func profileTapped(_ sender: UIGestureRecognizer) {
        if let user = user {
            delegate?.tapped(profile: user)
        }
    }

    @IBAction func remainingTapped(_ sender: GradientButton) {
        if let user = user,
            let list = list {
            delegate?.tapped(remaining: user, list: list)
        }
    }

    @IBAction func visitedTapped(_ sender: GradientButton) {
        if let user = user,
           let list = list {
            delegate?.tapped(visited: user, list: list)
        }
    }
}
