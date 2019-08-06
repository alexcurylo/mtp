// @copyright Trollwerks Inc.

import Anchorage

enum Disclosure {
    case close
    case empty
    case expand

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

protocol CountCellGroupDelegate: AnyObject {

    func toggle(region: String,
                country: String)
}

struct CountGroupModel {

    var region: String
    var country: String
    var visited: Int?
    var count: Int
    var disclose: Disclosure
    var isLast: Bool
}

final class CountCellGroup: UICollectionViewCell {

    static let reuseIdentifier = NSStringFromClass(CountCellGroup.self)

    weak var delegate: CountCellGroupDelegate?

    private var model: CountGroupModel?

    func set(model: CountGroupModel) {
        self.model = model

        if let visited = model.visited {
            label.text = L.locationVisitedCount(model.country, visited, model.count)
        } else {
            label.text = L.locationCount(model.country, model.count)
        }
        disclosure.image = model.disclose.image

        let rounded: ViewCorners = model.isLast ? .bottom(radius: CountsPageVC.Layout.cellCornerRadius)
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
