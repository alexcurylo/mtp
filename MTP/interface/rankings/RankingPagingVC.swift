// @copyright Trollwerks Inc.

import Anchorage
import Parchment
import UIKit

final class RankingPagingVC: PagingViewController<RankingPagingItem> {

    private let insets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    private let itemSize = CGSize(width: 70, height: 70)
    lazy var menuHeight: CGFloat = { itemSize.height + insets.top + insets.bottom }()

    func menuHeight(for scrollView: UIScrollView) -> CGFloat {
        let maxChange: CGFloat = 30
        let offset = min(maxChange, scrollView.contentOffset.y + menuHeight) / maxChange
        let height = menuHeight - (offset * maxChange)
        return height
    }

    override func loadView() {
        view = RankingPagingView(options: options,
                                 collectionView: collectionView,
                                 pageView: pageViewController.view)
    }

    func configure() {
        menuItemSource = .class(type: RankingPagingCell.self)
        menuItemSize = .fixed(width: itemSize.width, height: itemSize.height)
        menuInsets = insets
        menuItemSpacing = 8
        menuBackgroundColor = .clear

        borderOptions = .hidden
        indicatorColor = UIColor(white: 1, alpha: 0.6)
        indicatorOptions = .visible(
            height: 1,
            zIndex: Int.max,
            spacing: .zero,
            insets: .zero
        )
    }

    func update(menu height: CGFloat) {
        // swiftlint:disable:next force_cast
        (view as! RankingPagingView).menuHeightConstraint?.constant = height

        menuItemSize = .fixed(
            width: itemSize.width,
            height: height - insets.top - insets.bottom
        )

        collectionViewLayout.invalidateLayout()
        // https://github.com/rechsteiner/Parchment/commit/71a1ab59f5ad19687fa09e635c936087109fe3d2
        // Expected to be in post-1.4.1 release
        collectionViewLayout.invalidationState = .everything
        collectionView.layoutIfNeeded()
   }
}

private class RankingPagingView: PagingView {

    var menuHeightConstraint: NSLayoutConstraint?

    override func setupConstraints() {
        pageView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        menuHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: options.menuHeight)
        menuHeightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),

            pageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            pageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            pageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            pageView.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
}

private class RankingPagingCell: PagingCell {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Avenir.heavy.of(size: 10)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 4
        contentView.clipsToBounds = true

        contentView.addSubview(titleLabel)
        titleLabel.horizontalAnchors == contentView.horizontalAnchors + 6
        titleLabel.bottomAnchor == contentView.bottomAnchor - 6
        titleLabel.heightAnchor == 28

        contentView.addSubview(imageView)
        imageView.horizontalAnchors == contentView.horizontalAnchors
        imageView.topAnchor == contentView.topAnchor + 12 ~ .low
        imageView.bottomAnchor <= titleLabel.topAnchor - 6
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setPagingItem(_ pagingItem: PagingItem,
                                selected: Bool,
                                options: PagingOptions) {
        // swiftlint:disable:next force_cast
        let item = pagingItem as! RankingPagingItem

        imageView.image = item.page.image
        titleLabel.text = item.page.title

        if selected {
            contentView.backgroundColor = UIColor(white: 1, alpha: 0.6)
        } else {
            contentView.backgroundColor = .white
        }
    }
}
