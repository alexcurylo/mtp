// @copyright Trollwerks Inc.

import Anchorage

final class CountGroupCell: UICollectionViewCell {

    static let reuseIdentifier = NSStringFromClass(CountGroupCell.self)

    func set(key: String,
             count: Int,
             visited: Int) {

        label.text = Localized.regionVisitedCount(key, visited, count)
    }

    private enum Layout {
        static let insets = UIEdgeInsets(top: 0,
                                         left: 16,
                                         bottom: 0,
                                         right: 0)
        static let fontSize = CGFloat(17)
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

        label.text = nil
    }
}

private extension CountGroupCell {

    func configure() {
        contentView.backgroundColor = .white

        contentView.addSubview(label)
        label.edgeAnchors == contentView.edgeAnchors + Layout.insets
    }
}
