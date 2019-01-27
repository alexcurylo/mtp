// @copyright Trollwerks Inc.

import Anchorage

protocol CountHeaderDelegate: AnyObject {

    func toggle(section key: String)
}

final class CountHeader: UICollectionReusableView {

    static let reuseIdentifier = NSStringFromClass(CountHeader.self)

    weak var delegate: CountHeaderDelegate?

    private var key: String = ""

    func set(key: String, count: Int) {
        self.key = key
        label.text = Localized.regionCount(key, count)
    }

    private enum Layout {
        static let cornerRadius = CGFloat(4)
        static let insets = UIEdgeInsets(top: 0,
                                         left: 16,
                                         bottom: 0,
                                         right: 0)
        static let fontSize = CGFloat(18)
    }

    private let label: UILabel = create {
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
        label.text = nil
    }
}

private extension CountHeader {

    func configure() {
        backgroundColor = .white
        cornerRadius = Layout.cornerRadius
        clipsToBounds = true

        addSubview(label)
        label.edgeAnchors == edgeAnchors + Layout.insets

        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(tapped))
        addGestureRecognizer(tap)
    }

    @objc func tapped(_ sender: UIGestureRecognizer) {
        delegate?.toggle(section: key)
    }
}
