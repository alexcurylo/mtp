// @copyright Trollwerks Inc.

import Parchment

/// Holder of profile pages
final class ProfilePagingVC: FixedPagingViewController {

    /// Provider of UI test exposition
    weak var exposer: CollectionCellExposing?

    /// Construction by injection
    /// - Parameter viewControllers: Controllers
    override init(viewControllers: [UIViewController]) {
        super.init(viewControllers: viewControllers)

        configure()
    }

    /// :nodoc:
    required init?(coder: NSCoder) { nil }

    /// :nodoc:
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        expose()
    }

    /// :nodoc:
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        report(screen: "Profile Paging")
    }

    /// Provide cell
    /// - Parameters:
    ///   - collectionView: Collection
    ///   - indexPath: Index path
    /// - Returns: Exposed cell
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView,
                                        cellForItemAt: indexPath)
        exposer?.expose(view: collectionView,
                        path: indexPath,
                        cell: cell)
        return cell
    }
}

// MARK: - Private

private extension ProfilePagingVC {

    func configure() {
        menuItemSize = .sizeToFit(minWidth: 50, height: 38)
        menuBackgroundColor = .clear

        font = Avenir.heavy.of(size: 16)
        selectedFont = Avenir.heavy.of(size: 16)
        textColor = .white
        selectedTextColor = .white
        indicatorColor = .white

        menuInteraction = .none
        indicatorOptions = .visible(
            height: 4,
            zIndex: .max,
            spacing: .zero,
            insets: .zero)
    }
}

// MARK: - Exposing

extension ProfilePagingVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        UIProfilePaging.menu.expose(item: collectionView)
    }
}
