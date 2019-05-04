// @copyright Trollwerks Inc.

import Anchorage

struct CountItemModel {
    var title: String
    var subtitle: String
    var list: Checklist
    var id: Int
    var parentId: Int?
    var isVisitable: Bool
    var isLast: Bool
    var isCombined: Bool

    func description(titleFont: UIFont,
                     subtitleFont: UIFont) -> NSAttributedString {
        let description = NSMutableAttributedString(
            string: title,
            attributes: titleFont.attributes
        )
        if !subtitle.isEmpty {
            let subtitleDescription = NSAttributedString(
                string: " \(subtitle)",
                attributes: subtitleFont.attributes
            )
            description.append(subtitleDescription)
        }
        return description
    }
}

final class CountCellItem: UICollectionViewCell, ServiceProvider {

    static let reuseIdentifier = NSStringFromClass(CountCellItem.self)

    private var model: CountItemModel?

    func set(model: CountItemModel) {
        self.model = model

        let font: UIFont
        if model.list.hasChildren(id: model.id) {
            labelsIndent?.constant = Layout.parentIndent
            font = Layout.titleObliqueFont
            visit.isHidden = true
        } else {
            if model.parentId != nil {
                labelsIndent?.constant = Layout.childIndent
                font = Layout.titleMediumFont
            } else if model.isCombined {
                labelsIndent?.constant = Layout.combinedIndent
                font = Layout.titleHeavyFont
            } else {
                labelsIndent?.constant = Layout.parentIndent
                font = Layout.titleMediumFont
            }
            visit.isHidden = !model.isVisitable
            if model.isVisitable {
                visit.isOn = model.list.isVisited(id: model.id)
                visit.isEnabled = model.list != .uncountries
            }
        }
        titleLabel.attributedText = model.description(
            titleFont: font,
            subtitleFont: Layout.subtitleFont
        )

        // without this background randomly goes gray?
        visit.styleAsFilter()

        if model.isLast {
            round(corners: [.bottomLeft, .bottomRight],
                  by: Layout.cornerRadius)
        } else {
            layer.mask = nil
        }
    }

    private enum Layout {
        static let rankSize = CGFloat(18)
        static let margin = CGFloat(8)
        static let combinedIndent = CGFloat(12)
        static let parentIndent = CGFloat(16)
        static let childIndent = CGFloat(20)
        static let spacing = CGFloat(4)
        static let cornerRadius = CGFloat(4)
        static let titleHeavyFont = Avenir.heavy.of(size: 17)
        static let titleMediumFont = Avenir.medium.of(size: 16)
        static let titleObliqueFont = Avenir.oblique.of(size: 16)
        static let subtitleFont = Avenir.oblique.of(size: 14)
    }

    private let titleLabel = UILabel {
        $0.allowsDefaultTighteningForTruncation = true
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.5
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    private var labelsIndent: NSLayoutConstraint?

    private let visit = UISwitch {
        $0.styleAsFilter()
        $0.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
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

        model = nil
        titleLabel.attributedText = nil
        visit.isOn = false
        visit.isEnabled = true
        visit.isHidden = false
        layer.mask = nil
    }
}

private extension CountCellItem {

    func configure() {
        contentView.backgroundColor = .white

        let infos = UIStackView(arrangedSubviews: [titleLabel, visit])
        infos.spacing = Layout.spacing
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
        guard let id = model?.id,
              let list = model?.list else { return }

        list.set(id: id, visited: sender.isOn)

        guard let parentId = model?.parentId  else { return }

        let parentVisited = list.hasVisitedChildren(id: parentId)
        list.set(id: parentId, visited: parentVisited)
    }
}
