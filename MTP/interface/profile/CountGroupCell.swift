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

final class CountGroupCell: UICollectionViewCell {

    static let reuseIdentifier = NSStringFromClass(CountGroupCell.self)

    func set(key: String,
             visited: Int?,
             count: Int,
             disclose: Disclosure) {
        if let visited = visited {
            label.text = Localized.locationVisitedCount(key, visited, count)
        } else {
            label.text = Localized.locationCount(key, count)
        }
        disclosure.image = disclose.image
    }

    private enum Layout {
        static let insets = UIEdgeInsets(top: 0,
                                         left: 16,
                                         bottom: 0,
                                         right: 0)
        static let fontSize = CGFloat(17)
    }

    private let disclosure = UIImageView {
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }

    private let label = UILabel {
        $0.font = Avenir.heavy.of(size: Layout.fontSize)
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

        disclosure.image = nil
        label.text = nil
    }
}

private extension CountGroupCell {

    func configure() {
        contentView.backgroundColor = .white

        let stack = UIStackView(arrangedSubviews: [disclosure, label])
        stack.alignment = .center
        stack.spacing = 5
        contentView.addSubview(stack)
        stack.edgeAnchors == contentView.edgeAnchors + Layout.insets
    }
}
