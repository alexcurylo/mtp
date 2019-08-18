// @copyright Trollwerks Inc.

import Anchorage

/// Display model for count group
struct CountItemModel {

    /// Title
    let title: String
    /// Subtitle
    let subtitle: String
    /// Checklist
    let list: Checklist
    /// Item ID
    let id: Int
    /// Parent ID if any
    let parentId: Int?
    /// Whether to show visit state
    let isVisitable: Bool
    /// Whether to round corners
    let isLast: Bool
    /// Whether is a combined header and content of one
    let isCombined: Bool
    /// IndexPath for exposing
    let path: IndexPath

    fileprivate func description(titleFont: UIFont,
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

/// Counts single item
final class CountCellItem: UICollectionViewCell, ServiceProvider {

    /// Dequeueing identifier
    static let reuseIdentifier = NSStringFromClass(CountCellItem.self)

    /// Corener radius for items and groups
    static let cellCornerRadius = CGFloat(4)

    private var model: CountItemModel?

    /// Handle dependency injection
    ///
    /// - Parameter model: Data model
    func inject(model: CountItemModel) {
        self.model = model

        let font: UIFont
        if model.list.hasChildren(id: model.id) {
            labelsIndent?.constant = Layout.parentIndent
            font = Layout.titleBookFont
            visit.isHidden = true
        } else {
            if model.parentId != nil {
                labelsIndent?.constant = Layout.childIndent
                font = Layout.childFont
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

        let rounded: ViewCorners = model.isLast ? .bottom(radius: CountCellItem.cellCornerRadius)
                                                : .square
        round(corners: rounded)

        UICountsPage.item(model.path.section, model.path.row).expose(item: self)
        UICountsPage.toggle(model.path.section, model.path.row).expose(item: visit)
    }

    private enum Layout {
        static let rankSize = CGFloat(18)
        static let margin = CGFloat(8)
        static let combinedIndent = CGFloat(12)
        static let parentIndent = CGFloat(16)
        static let childIndent = CGFloat(24)
        static let spacing = CGFloat(4)
        static let titleHeavyFont = Avenir.heavy.of(size: 17)
        static let titleMediumFont = Avenir.medium.of(size: 16)
        static let titleBookFont = Avenir.book.of(size: 16)
        static let childFont = Avenir.oblique.of(size: 15)
        static let subtitleFont = Avenir.oblique.of(size: 14)
    }

    private let titleLabel = UILabel {
        $0.allowsDefaultTighteningForTruncation = true
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.9
        $0.lineBreakMode = .byTruncatingMiddle
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    private var labelsIndent: NSLayoutConstraint?

    private let visit = UISwitch {
        $0.styleAsFilter()
        $0.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
    }

    /// Procedural intializer
    ///
    /// - Parameter frame: Display frame
    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
    }

    /// Unsupported coding constructor
    ///
    /// - Parameter coder: An unarchiver object.
    required init?(coder: NSCoder) {
        return nil
    }

    /// Empty display
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

// MARK: - Private

private extension CountCellItem {

    func configure() {
        contentView.backgroundColor = .white

        let infos = UIStackView(arrangedSubviews: [titleLabel,
                                                   visit]).with {
            $0.spacing = Layout.spacing
            $0.alignment = .center
        }
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

        let item = (list, id)
        let visited = sender.isOn
        note.set(item: item,
                 visited: visited,
                 congratulate: false) { [weak sender] result in
            if case .failure = result {
                sender?.isOn = !visited
            }
        }
    }
}
