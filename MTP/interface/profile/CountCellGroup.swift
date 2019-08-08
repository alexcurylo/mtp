// @copyright Trollwerks Inc.

import Anchorage

/// State of disclosure arrow
enum Disclosure {

    /// Undisclosed
    case close
    /// Nothing to disclose
    case empty
    /// Disclosed
    case expand

    /// Image to prefix title with if any
    var image: UIImage? {
        switch self {
        case .close:
            return R.image.arrowUp()
        case .empty:
            return nil
        case .expand:
            return R.image.arrowDown()
       }
    }
}

/// Notify of display state changes
protocol CountCellGroupDelegate: AnyObject {

    /// Toggle expanded state of country
    ///
    /// - Parameters:
    ///   - region: Region
    ///   - country: Country
    func toggle(region: String,
                country: String)
}

/// Display model for count group
struct CountGroupModel {

    /// Region
    var region: String
    /// Country
    var country: String
    /// Number visited
    var visited: Int?
    /// Number total
    var count: Int
    /// Disclosure state
    var disclose: Disclosure
    /// Whether to round corners
    var isLast: Bool
}

/// Counts item groupd
final class CountCellGroup: UICollectionViewCell {

    /// Dequeueing identifier
    static let reuseIdentifier = NSStringFromClass(CountCellGroup.self)

    /// Delegate
    weak var delegate: CountCellGroupDelegate?

    private var model: CountGroupModel?

    /// Handle dependency injection
    ///
    /// - Parameter model: Data model
    func inject(model: CountGroupModel) {
        self.model = model

        if let visited = model.visited {
            label.text = L.locationVisitedCount(model.country, visited, model.count)
        } else {
            label.text = L.locationCount(model.country, model.count)
        }
        disclosure.image = model.disclose.image

        let rounded: ViewCorners = model.isLast ? .bottom(radius: CountCellItem.cellCornerRadius)
                                                : .square
        round(corners: rounded)
    }

    private enum Layout {
        static let insets = UIEdgeInsets(top: 0,
                                         left: 12,
                                         bottom: 0,
                                         right: 0)
        static let font = Avenir.heavy.of(size: 17)
    }

    private let disclosure = UIImageView {
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }

    private let label = UILabel {
        $0.font = Layout.font
    }

    /// Procedural intializer
    ///
    /// - Parameter frame: Display frame
    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
    }

    /// Unavailable coding constructor
    ///
    /// - Parameter coder: An unarchiver object.
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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

        let stack = UIStackView(arrangedSubviews: [disclosure,
                                                   label]).with {
            $0.alignment = .center
            $0.spacing = 5
        }
        contentView.addSubview(stack)
        stack.edgeAnchors == contentView.edgeAnchors + Layout.insets

        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(tapped))
        addGestureRecognizer(tap)
    }

    @objc func tapped(_ sender: UIGestureRecognizer) {
        guard let model = model else { return }
        delegate?.toggle(region: model.region,
                         country: model.country)
    }
}
