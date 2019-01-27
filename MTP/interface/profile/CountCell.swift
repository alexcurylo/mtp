// @copyright Trollwerks Inc.

import Anchorage

final class CountCell: UICollectionViewCell {

    static let reuseIdentifier = NSStringFromClass(CountCell.self)

    func set(name: String, list: Checklist, id: Int) {
        nameLabel.text = name
        countryLabel.text = name

        let remaining = Localized.remaining(0)
        remainingButton.setTitle(remaining, for: .normal)
    }

    private enum Layout {
        static let rankSize = CGFloat(18)
        static let margin = CGFloat(8)
        static let spacing = CGSize(width: 12, height: 4)
        static let cornerRadius = CGFloat(4)
        static let overlap = CGFloat(-8)
        static let fontSize = CGFloat(15)
    }

    private let nameLabel: UILabel = create {
        $0.font = Avenir.medium.of(size: Layout.fontSize)
    }
    private let countryLabel: UILabel = create {
        $0.font = Avenir.medium.of(size: 15)
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

    override func prepareForReuse() {
        super.prepareForReuse()

        nameLabel.text = nil
        countryLabel.text = nil
        remainingButton.setTitle(nil, for: .normal)
    }
}

private extension CountCell {

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
        contentView.backgroundColor = .green
        contentView.cornerRadius = Layout.cornerRadius
        contentView.clipsToBounds = true

        let labels = UIStackView(arrangedSubviews: [nameLabel, countryLabel])
        labels.axis = .vertical

        let infos = UIStackView(arrangedSubviews: [labels])
        infos.spacing = Layout.spacing.width
        infos.alignment = .center
        contentView.addSubview(infos)
        infos.centerYAnchor == contentView.centerYAnchor
        infos.leadingAnchor == contentView.leadingAnchor + Layout.margin

        let buttons = UIStackView(arrangedSubviews: [remainingButton])
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
