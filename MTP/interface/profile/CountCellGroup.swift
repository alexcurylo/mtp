// @copyright Trollwerks Inc.

import Anchorage

/// State of disclosure arrow
enum Disclosure {

    /// Undisclosed
    case close
    /// Disclosed
    case expand

    /// Image to prefix title with if any
    var image: UIImage? {
        switch self {
        case .close:
            return R.image.arrowUp()
        case .expand:
            return R.image.arrowDown()
       }
    }
}

/// Notify of display state changes
protocol CountCellGroupDelegate: AnyObject {

    /// Toggle expanded state of group
    /// - Parameters:
    ///   - section: Name
    ///   - group: Name
    func toggle(section: String,
                group: String)

    /// Toggle expanded state of subgroup
    /// - Parameters:
    ///   - section: Name
    ///   - group: Name
    ///   - subgroup: Name
    func toggle(section: String,
                group: String,
                subgroup: String)
}

/// Display model for count group
struct CountGroupModel: CountCellModel {

    /// Region or brand
    let section: String
    /// Country or region
    let group: String
    /// Location or country
    let subgroup: String?
    /// Number visited
    let visited: Int?
    /// Number total
    let count: Int
    /// Disclosure state
    let disclose: Disclosure
    /// Whether to round corners
    let isLast: Bool
    /// IndexPath for exposing
    let path: IndexPath
}

/// Counts item groupd
final class CountCellGroup: UICollectionViewCell {

    /// Dequeueing identifier
    static let reuseIdentifier = NSStringFromClass(CountCellGroup.self)

    /// Delegate
    weak var delegate: CountCellGroupDelegate?

    private var model: CountGroupModel?

    /// Handle dependency injection
    /// - Parameter model: Data model
    func inject(model: CountCellModel) {
        guard let model = model as? CountGroupModel else { return }

        self.model = model

        let title = model.subgroup ?? model.group
        if let visited = model.visited {
            label.text = L.locationVisitedCount(title, visited, model.count)
        } else {
            label.text = L.locationCount(title, model.count)
        }
        disclosure.image = model.disclose.image
        let isSubgroup = model.subgroup != nil
        indentConstraint?.constant = isSubgroup ? layout.inset.subgroup : layout.inset.group

        let rounded: ViewCorners = model.isLast ? .bottom(radius: CountCellItem.cellCornerRadius)
                                                : .square
        round(corners: rounded)

        UICountsPage.group(model.path.section, model.path.row).expose(item: self)
    }

    private let layout = (
        inset: (
            group: CGFloat(12),
            subgroup: CGFloat(16)
        ),
        font: Avenir.heavy.of(size: 17)
    )
    private var indentConstraint: NSLayoutConstraint?
    private let disclosure = UIImageView {
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }
    private lazy var label = UILabel {
        $0.font = layout.font
    }

    /// :nodoc:
    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
    }

    /// :nodoc:
    required init?(coder: NSCoder) { nil }

    /// Empty display
    override func prepareForReuse() {
        super.prepareForReuse()

        delegate = nil
        model = nil
        disclosure.image = nil
        label.text = nil
    }
}

// MARK: - Private

private extension CountCellGroup {

    func configure() {
        contentView.backgroundColor = .white

        let stack = UIStackView(arrangedSubviews: [
            disclosure,
            label,
        ]).with {
            $0.alignment = .center
            $0.spacing = 5
        }
        contentView.addSubview(stack)
        stack.verticalAnchors == contentView.verticalAnchors
        stack.rightAnchor == contentView.rightAnchor
        indentConstraint = stack.leftAnchor == contentView.leftAnchor

        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(tapped))
        addGestureRecognizer(tap)
    }

    @objc func tapped(_ sender: UIGestureRecognizer) {
        guard let model = model else { return }

        if let subgroup = model.subgroup {
            delegate?.toggle(section: model.section,
                             group: model.group,
                             subgroup: subgroup)
        } else {
            delegate?.toggle(section: model.section,
                             group: model.group)
        }
    }
}
