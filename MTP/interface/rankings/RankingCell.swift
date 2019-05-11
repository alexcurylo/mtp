// @copyright Trollwerks Inc.

import Anchorage

protocol RankingCellDelegate: AnyObject {

    func tapped(visited user: User, list: Checklist)
    func tapped(remaining user: User, list: Checklist)
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
    }

    private let avatarImageView = UIImageView {
        $0.heightAnchor == Layout.avatarSize
        $0.widthAnchor == Layout.avatarSize
        $0.cornerRadius = Layout.avatarSize / 2
        $0.backgroundColor = .mercury
        $0.contentMode = .scaleAspectFill
    }
    private let rankLabel = UILabel {
        $0.font = Avenir.heavy.of(size: 10)
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

        guard user.id != 0 else {
            nameLabel.text = Localized.loading()
            avatarImageView.image = nil
            visitedButton.isHidden = true
            remainingButton.isHidden = true
            rankLabel.text = nil
            return
        }

        avatarImageView.load(image: user)

        let order = list.order(of: user)
        rankLabel.text = order > 0 ? order.grouped : Localized.deceased()

        let status = list.status(of: user)
        visitedButton.isHidden = false
        let visited = Localized.visitedCount(status.visited)
        visitedButton.setTitle(visited, for: .normal)
        remainingButton.isHidden = false
        let remaining = Localized.remainingCount(status.remaining)
        remainingButton.setTitle(remaining, for: .normal)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

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

        visitedButton.addTarget(self, action: #selector(visitedTapped), for: .touchUpInside)
        remainingButton.addTarget(self, action: #selector(remainingTapped), for: .touchUpInside)

        let badges = UIStackView(arrangedSubviews: [avatarImageView, rankLabel])
        badges.axis = .vertical
        badges.alignment = .center
        badges.spacing = Layout.overlap
        badges.setContentHuggingPriority(.required, for: .horizontal)

        let labels = UIStackView(arrangedSubviews: [nameLabel, countryLabel])
        labels.axis = .vertical
        labels.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let buttons = UIStackView(arrangedSubviews: [visitedButton, remainingButton])
        buttons.axis = .vertical
        buttons.distribution = .fillEqually
        buttons.alignment = .trailing
        buttons.spacing = Layout.spacing.height
        buttons.setContentHuggingPriority(.required, for: .horizontal)

        let infos = UIStackView(arrangedSubviews: [badges, labels, buttons])
        infos.spacing = Layout.spacing.width
        infos.alignment = .center
        infos.distribution = .fill
        contentView.addSubview(infos)
        infos.edgeAnchors == contentView.edgeAnchors + Layout.margin
    }

    @IBAction func visitedTapped(_ sender: GradientButton) {
        if let user = user,
           let list = list {
            delegate?.tapped(visited: user, list: list)
        }
    }

    @IBAction func remainingTapped(_ sender: GradientButton) {
        if let user = user,
           let list = list {
            delegate?.tapped(remaining: user, list: list)
        }
    }
}
