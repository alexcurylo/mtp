// @copyright Trollwerks Inc.

import Anchorage

protocol CountHeaderDelegate: AnyObject {

    func toggle(section key: String)
}

final class CountHeader: UICollectionReusableView {

    static let reuseIdentifier = NSStringFromClass(CountHeader.self)

    weak var delegate: CountHeaderDelegate?

    private var key = ""

    func set(key: String,
             visited: Int?,
             count: Int,
             isExpanded: Bool) {
        self.key = key

        let disclose: Disclosure = isExpanded ? .close : .expand
        disclosure.image = disclose.image

        if let visited = visited {
            label.text = Localized.locationVisitedCount(key, visited, count)
        } else {
            label.text = Localized.locationCount(key, count)
        }

        let corners: UIRectCorner = isExpanded ? [.topLeft, .topRight] : .allCorners
        round(corners: corners, by: Layout.cornerRadius)
    }

    private enum Layout {
        static let cornerRadius = CGFloat(4)
        static let insets = UIEdgeInsets(top: 0,
                                         left: 16,
                                         bottom: 0,
                                         right: 0)
        static let fontSize = CGFloat(18)
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

        delegate = nil
        key = ""
        disclosure.image = nil
        label.text = nil
        layer.mask = nil
    }
}

private extension CountHeader {

    func configure() {
        backgroundColor = .white

        let stack = UIStackView(arrangedSubviews: [disclosure, label])
        stack.alignment = .center
        stack.spacing = 5
        addSubview(stack)
        stack.edgeAnchors == edgeAnchors + Layout.insets

        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(tapped))
        addGestureRecognizer(tap)
    }

    @objc func tapped(_ sender: UIGestureRecognizer) {
        delegate?.toggle(section: key)
    }
}
