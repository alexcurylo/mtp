// @copyright Trollwerks Inc.

import Anchorage

/// Notify of display state changes
protocol CountSectionHeaderDelegate: AnyObject {

    /// Toggle expanded state of region
    ///
    /// - Parameter region: Region
    func toggle(region: String)
}

/// Display model for count section
struct CountSectionModel {

    /// Region
    var region: String
    /// Number visited
    var visited: Int?
    /// Number total
    var count: Int
    /// Whether is expanded
    var isExpanded: Bool
}

/// Counts section header
final class CountSectionHeader: UICollectionReusableView {

    /// Dequeueing identifier
    static let reuseIdentifier = NSStringFromClass(CountSectionHeader.self)

    /// Delegate
    weak var delegate: CountSectionHeaderDelegate?

    private var model: CountSectionModel?

    /// Handle dependency injection
    ///
    /// - Parameter model: Data model
    func inject(model: CountSectionModel) {
        self.model = model

        let disclose: Disclosure = model.isExpanded ? .close : .expand
        disclosure.image = disclose.image

        if let visited = model.visited {
            label.text = L.locationVisitedCount(model.region, visited, model.count)
        } else {
            label.text = L.locationCount(model.region, model.count)
        }

        let rounded: ViewCorners = model.isExpanded ? .top(radius: Layout.cornerRadius)
                                                    : .all(radius: Layout.cornerRadius)
        round(corners: rounded)
    }

    private enum Layout {
        static let cornerRadius = CGFloat(4)
        static let insets = UIEdgeInsets(top: 0,
                                         left: 8,
                                         bottom: 0,
                                         right: 0)
        static let font = Avenir.heavy.of(size: 18)
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

    /// Unsupported coding constructor
    ///
    /// - Parameter coder: An unarchiver object.
    required init?(coder: NSCoder) {
        return nil
    }

    /// Empty display
    override func prepareForReuse() {
        super.prepareForReuse()

        delegate = nil
        model = nil
        disclosure.image = nil
        label.text = nil
        layer.mask = nil
    }
}

// MARK: - Private

private extension CountSectionHeader {

    func configure() {
        backgroundColor = .white

        let stack = UIStackView(arrangedSubviews: [disclosure,
                                                   label]).with {
            $0.alignment = .center
            $0.spacing = 5
        }
        addSubview(stack)
        stack.edgeAnchors == edgeAnchors + Layout.insets

        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(tapped))
        addGestureRecognizer(tap)
    }

    @objc func tapped(_ sender: UIGestureRecognizer) {
        if let region = model?.region {
            delegate?.toggle(region: region)
        }
    }
}
