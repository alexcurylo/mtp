// @copyright Trollwerks Inc.

import Anchorage

final class CountCell: UICollectionViewCell {

    static let reuseIdentifier = NSStringFromClass(CountCell.self)

    func set(name: String,
             list: Checklist,
             id: Int,
             isLast: Bool) {
        self.list = list
        self.id = id

        nameLabel.text = name
        visit.isOn = list.isVisited(id: id)

        if isLast {
            round(corners: [.bottomLeft, .bottomRight],
                  by: Layout.cornerRadius)
        } else {
            layer.mask = nil
        }
    }

    private enum Layout {
        static let rankSize = CGFloat(18)
        static let margin = CGFloat(8)
        static let indent = CGFloat(24)
        static let spacing = CGSize(width: 12, height: 4)
        static let cornerRadius = CGFloat(4)
        static let fontSize = CGFloat(15)
    }

    private let nameLabel: UILabel = create {
        $0.font = Avenir.medium.of(size: Layout.fontSize)
    }

    private let visit = UISwitch()

    private var list: Checklist?
    private var id: Int?

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

        list = nil
        id = nil
        nameLabel.text = nil
        visit.isOn = false
        layer.mask = nil
    }
}

private extension CountCell {

    func configure() {
        contentView.backgroundColor = .white

        let labels = UIStackView(arrangedSubviews: [nameLabel])
        labels.axis = .vertical

        let infos = UIStackView(arrangedSubviews: [labels])
        infos.spacing = Layout.spacing.width
        infos.alignment = .center
        contentView.addSubview(infos)
        infos.centerYAnchor == contentView.centerYAnchor
        infos.leadingAnchor == contentView.leadingAnchor + Layout.indent

        let buttons = UIStackView(arrangedSubviews: [visit])
        buttons.axis = .vertical
        buttons.distribution = .fillEqually
        buttons.alignment = .trailing
        buttons.spacing = Layout.spacing.height
        contentView.addSubview(buttons)
        buttons.verticalAnchors == contentView.verticalAnchors + Layout.margin
        buttons.trailingAnchor == contentView.trailingAnchor - Layout.margin

        visit.addTarget(self,
                        action: #selector(toggleVisit),
                        for: .valueChanged)
    }

    @objc func toggleVisit(_ sender: UISwitch) {
        guard let id = id else { return }

        list?.set(id: id, visited: sender.isOn)
    }
}
