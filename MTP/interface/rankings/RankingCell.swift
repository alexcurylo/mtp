// @copyright Trollwerks Inc.

import Anchorage

final class RankingCell: UICollectionViewCell {

    static let reuseIdentifier = NSStringFromClass(RankingCell.self)

    private enum Layout {
        static let avatarSize = CGFloat(48)
        static let rankSize = CGFloat(18)
        static let margin = CGFloat(8)
        static let spacing = CGSize(width: 12, height: 4)
        static let cornerRadius = CGFloat(4)
        static let overlap = CGFloat(-8)
    }

    private let avatarImageView: UIImageView = create {
        $0.heightAnchor == Layout.avatarSize
        $0.widthAnchor == Layout.avatarSize
        $0.cornerRadius = Layout.avatarSize / 2
        $0.backgroundColor = .mercury
        $0.contentMode = .scaleAspectFill
    }
    private let rankLabel: UILabel = create {
        $0.font = Avenir.heavy.of(size: 10)
        $0.heightAnchor == Layout.rankSize
        $0.widthAnchor == Layout.avatarSize - Layout.margin
        $0.cornerRadius = Layout.rankSize / 2
        $0.backgroundColor = .gallery
        $0.textAlignment = .center
    }

    private let nameLabel: UILabel = create {
        $0.font = Avenir.heavy.of(size: 18)
    }
    private let countryLabel: UILabel = create {
        $0.font = Avenir.medium.of(size: 15)
    }

    private let visitedButton: GradientButton = create {
        configure(button: $0)
        $0.addTarget(self, action: #selector(tapVisited), for: .touchUpInside)
    }
    private let remainingButton: GradientButton = create {
        configure(button: $0)
        $0.addTarget(self, action: #selector(tapRemaining), for: .touchUpInside)
    }

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
             in list: Checklist) {
        rankLabel.text = rank.grouped

        avatarImageView.setImage(for: user)
        nameLabel.text = user.fullName
        countryLabel.text = user.country.countryName

        let status = list.status(of: user)
        let visited = Localized.visited(status.visited)
        visitedButton.setTitle(visited, for: .normal)
        let remaining = Localized.remaining(status.remaining)
        remainingButton.setTitle(remaining, for: .normal)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        avatarImageView.image = nil
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
    }

    func configure() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = Layout.cornerRadius
        contentView.clipsToBounds = true

        let badges = UIStackView(arrangedSubviews: [avatarImageView, rankLabel])
        badges.axis = .vertical
        badges.alignment = .center
        badges.spacing = Layout.overlap

        let labels = UIStackView(arrangedSubviews: [nameLabel, countryLabel])
        labels.axis = .vertical

        let infos = UIStackView(arrangedSubviews: [badges, labels])
        infos.spacing = Layout.spacing.width
        infos.alignment = .center
        contentView.addSubview(infos)
        infos.centerYAnchor == contentView.centerYAnchor
        infos.leadingAnchor == contentView.leadingAnchor + Layout.margin

        let buttons = UIStackView(arrangedSubviews: [visitedButton, remainingButton])
        buttons.axis = .vertical
        buttons.distribution = .fillEqually
        buttons.alignment = .trailing
        buttons.spacing = Layout.spacing.height
        contentView.addSubview(buttons)
        buttons.verticalAnchors == contentView.verticalAnchors + Layout.margin
        buttons.trailingAnchor == contentView.trailingAnchor - Layout.margin
    }

    @IBAction func tapVisited() {
        log.todo("tapVisited()")
    }

    @IBAction func tapRemaining() {
        log.todo("tapRemaining()")
    }
}
