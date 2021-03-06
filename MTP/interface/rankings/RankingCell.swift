// @copyright Trollwerks Inc.

import Anchorage

/// Actions triggered by ranking cell
protocol RankingCellDelegate: AnyObject {

    /// Profile tapped
    /// - Parameter user: User to display
    func tapped(profile user: User)
    /// Remaining tapped
    /// - Parameters:
    ///   - user: User to display
    ///   - list: List to display
    func tapped(remaining user: User, list: Checklist)
    /// Visited tapped
    /// - Parameters:
    ///   - user: User to display
    ///   - list: List to display
    func tapped(visited user: User, list: Checklist)
}

/// Display an entry in ranking list
final class RankingCell: UICollectionViewCell, ServiceProvider {

    /// Dequeueing identifier
    static let reuseIdentifier = NSStringFromClass(RankingCell.self)

    private enum Layout {
        static let avatarSize = CGFloat(48)
        static let rankSize = CGFloat(18)
        static let buttonHeight = CGFloat(35)
        static let margin = CGFloat(8)
        static let spacing = CGSize(width: 8, height: 4)
        static let cornerRadius = CGFloat(4)
        static let overlap = CGFloat(-8)
        static let rankFont = Avenir.heavy.of(size: 10)
    }

    private let avatarImageView = UIImageView {
        $0.heightAnchor == Layout.avatarSize
        $0.widthAnchor == Layout.avatarSize
        $0.cornerRadius = Layout.avatarSize / 2
        $0.backgroundColor = .mercury
        $0.contentMode = .scaleAspectFill
    }
    private let rankLabel = UILabel {
        $0.font = Layout.rankFont
        $0.heightAnchor == Layout.rankSize
        $0.widthAnchor == Layout.avatarSize - Layout.margin
        $0.cornerRadius = Layout.rankSize / 2
        $0.backgroundColor = .gallery
        $0.textAlignment = .center
    }

    private let nameLabel = UILabel {
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

    private let visitedButton = GradientButton(type: .system).with {
        configure(button: $0)
    }
    private let remainingButton = GradientButton(type: .system).with {
        configure(button: $0)
    }

    private var user: User?
    private var list: Checklist?
    private weak var delegate: RankingCellDelegate?

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
    ///   - user: User if available
    ///   - rank: Rank
    ///   - list: Checklist
    ///   - delegate: Delegate
    func inject(user: User?,
                for rank: Int,
                in list: Checklist,
                delegate: RankingCellDelegate?) {
        self.user = user
        self.list = list
        self.delegate = delegate

        guard let user = user else {
            nameLabel.text = L.blocked()
            avatarImageView.image = nil
            visitedButton.isHidden = true
            remainingButton.isHidden = true
            rankLabel.text = nil
            return
        }
        guard user.userId != 0 else {
            nameLabel.text = L.loading()
            avatarImageView.image = nil
            visitedButton.isHidden = true
            remainingButton.isHidden = true
            rankLabel.text = nil
            return
        }

        nameLabel.text = user.fullName
        countryLabel.text = user.locationName
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

        configure()
    }

    /// Expose cell to UI tests
    /// - Parameters:
    ///   - list: ChecklistIndex
    ///   - item: Index
    func expose(list: ChecklistIndex,
                item: Int) {
        UIRankingsPage.profile(list, item).expose(item: nameLabel)
        UIRankingsPage.remaining(list, item).expose(item: remainingButton)
        UIRankingsPage.visited(list, item).expose(item: visitedButton)
    }

    /// Empty display
    override func prepareForReuse() {
        super.prepareForReuse()

        configure()
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

// MARK: - Private

private extension RankingCell {

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

        let badges = UIStackView(arrangedSubviews: [
            avatarImageView,
            rankLabel,
        ]).with {
            $0.axis = .vertical
            $0.alignment = .center
            $0.spacing = Layout.overlap
            $0.setContentHuggingPriority(.required, for: .horizontal)
        }

        let labels = UIStackView(arrangedSubviews: [
            nameLabel,
            countryLabel,
        ]).with {
            $0.axis = .vertical
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        }

        let buttons = UIStackView(arrangedSubviews: [
            visitedButton,
            remainingButton,
        ]).with {
            $0.axis = .vertical
            $0.distribution = .fillEqually
            $0.alignment = .trailing
            $0.spacing = Layout.spacing.height
            $0.setContentHuggingPriority(.required, for: .horizontal)
        }

        let infos = UIStackView(arrangedSubviews: [
            badges,
            labels,
            buttons,
        ]).with {
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
