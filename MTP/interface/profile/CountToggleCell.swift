// @copyright Trollwerks Inc.

import Anchorage

final class CountToggleCell: UICollectionViewCell, ServiceProvider {

    static let reuseIdentifier = NSStringFromClass(CountToggleCell.self)

    // swiftlint:disable:next function_parameter_count
    func set(title: String,
             subtitle: String,
             list: Checklist,
             id: Int,
             parentId: Int?,
             visitable: Bool,
             isLast: Bool) {
        self.list = list
        self.id = id
        self.parentId = parentId

        titleLabel.text = title
        subtitleLabel.text = subtitle

        if list.hasChildren(id: id) {
            labelsIndent?.constant = Layout.parentIndent
            titleLabel.font = Avenir.oblique.of(size: Layout.titleSize)
            visit.isHidden = true
        } else {
            if parentId != nil {
                labelsIndent?.constant = Layout.childIndent
            } else {
                labelsIndent?.constant = Layout.parentIndent
            }
            titleLabel.font = Avenir.medium.of(size: Layout.titleSize)
            visit.isHidden = !visitable
            if visitable {
                visit.isOn = list.isVisited(id: id)
                visit.isEnabled = list != .uncountries
            }
        }
        // without this background randomly goes gray?
        visit.styleAsFilter()

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
        static let parentIndent = CGFloat(24)
        static let childIndent = CGFloat(32)
        static let spacing = CGSize(width: 12, height: 4)
        static let cornerRadius = CGFloat(4)
        static let titleSize = CGFloat(16)
        static let subtitleSize = CGFloat(14)
    }

    private let titleLabel = UILabel {
        $0.font = Avenir.medium.of(size: Layout.titleSize)
    }
    private let subtitleLabel = UILabel {
        $0.font = Avenir.oblique.of(size: Layout.subtitleSize)
    }
    private var labelsIndent: NSLayoutConstraint?

    private let visit = UISwitch {
        $0.styleAsFilter()
    }

    private var list: Checklist?
    private var id: Int?
    private var parentId: Int?

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
        parentId = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        visit.isOn = false
        visit.isEnabled = true
        visit.isHidden = false
        layer.mask = nil
    }
}

private extension CountToggleCell {

    func configure() {
        contentView.backgroundColor = .white

        let labels = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labels.axis = .vertical

        let infos = UIStackView(arrangedSubviews: [labels, visit])
        infos.spacing = Layout.spacing.width
        infos.alignment = .center
        contentView.addSubview(infos)
        infos.centerYAnchor == contentView.centerYAnchor
        labelsIndent = infos.leadingAnchor == contentView.leadingAnchor + Layout.parentIndent
        infos.trailingAnchor == contentView.trailingAnchor - Layout.margin
        visit.addTarget(self,
                        action: #selector(toggleVisit),
                        for: .valueChanged)
    }

    @objc func toggleVisit(_ sender: UISwitch) {
        guard let id = id, let list = list else { return }

        list.set(id: id, visited: sender.isOn)

        guard let parentId = parentId  else { return }

        let parentVisited = list.hasVisitedChildren(id: parentId)
        list.set(id: parentId, visited: parentVisited)
    }
}
