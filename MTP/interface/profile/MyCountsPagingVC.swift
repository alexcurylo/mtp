// @copyright Trollwerks Inc.

import Anchorage
import Parchment
import UIKit

final class MyCountsPagingVC: PagingViewController<ListPagingItem> {

    enum Layout {
        static let insets = UIEdgeInsets(top: 8,
                                         left: 8,
                                         bottom: 8,
                                         right: 8)
        static let itemSize = CGSize(width: 70, height: 70)
        static let menuHeight = itemSize.height + insets.horizontal
    }

    func menuHeight(for scrollView: UIScrollView) -> CGFloat {
        let maxChange: CGFloat = 30
        let offset = min(maxChange, scrollView.contentOffset.y + Layout.menuHeight) / maxChange
        let height = Layout.menuHeight - (offset * maxChange)
        return height
    }

    override func loadView() {
        view = MyCountsPagingView(options: options,
                                  collectionView: collectionView,
                                  pageView: pageViewController.view)
    }

    func configure() {
        menuItemSource = .class(type: MyCountsPagingCell.self)
        menuItemSize = .fixed(width: Layout.itemSize.width,
                              height: Layout.itemSize.height)
        menuInsets = Layout.insets
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
        guard let pagingView = view as? MyCountsPagingView else {
            fatalError("MyCountsPagingView type failure")
        }
        pagingView.menuHeightConstraint?.constant = height

        menuItemSize = .fixed(
            width: Layout.itemSize.width,
            height: height - Layout.insets.vertical
        )

        collectionViewLayout.invalidateLayout()
        // https://github.com/rechsteiner/Parchment/commit/71a1ab59f5ad19687fa09e635c936087109fe3d2
        // Expected to be in post-1.4.1 release
        collectionViewLayout.invalidationState = .everything
        collectionView.layoutIfNeeded()
    }
}

private class MyCountsPagingView: PagingView {

    var menuHeightConstraint: NSLayoutConstraint?

    override func configure() {
        super.configure()

        let menuBackground: GradientView = create {
            $0.set(gradient: [.dodgerBlue, .azureRadiance],
                   orientation: .horizontal)
        }
        collectionView.backgroundView = menuBackground
    }

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

private class MyCountsPagingCell: PagingCell {

    private let imageView: UIImageView = create {
        $0.contentMode = .scaleAspectFit
    }

    private let titleLabel: UILabel = create {
        $0.font = Avenir.heavy.of(size: 10)
        $0.textColor = .black
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }

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
        guard let item = pagingItem as? ListPagingItem else {
            fatalError("ListPagingItem type failure")
        }

        imageView.image = item.list.image
        titleLabel.text = item.list.title

        if selected {
            contentView.backgroundColor = UIColor(white: 1, alpha: 0.6)
        } else {
            contentView.backgroundColor = .white
        }
    }
}
