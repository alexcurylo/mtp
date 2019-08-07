// @copyright Trollwerks Inc.

import Parchment

final class ProfilePagingVC: FixedPagingViewController, ServiceProvider {

    weak var exposer: CollectionCellExposing?

    override init(viewControllers: [UIViewController]) {
        super.init(viewControllers: viewControllers)
        configure()
    }

    /// Construction by unarchiving
    ///
    /// - Parameter coder: An unarchiver object.
    required init?(coder: NSCoder) {
        super.init(viewControllers: [])
    }

    /// Instrument and inject navigation
    ///
    /// - Parameters:
    ///   - segue: Navigation action
    ///   - sender: Action originator
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }

    /// Provide cell
    ///
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
