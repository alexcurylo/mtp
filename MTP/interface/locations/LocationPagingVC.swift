// @copyright Trollwerks Inc.

import Parchment

/// Displays location info tabs
final class LocationPagingVC: FixedPagingViewController {

    fileprivate enum Page: Int {

        case first
        case photos
        case posts
    }

    /// Provide pages container
    ///
    /// - Parameter model: Model to populate pages
    /// - Returns: LocationPagingVC
    static func profile(model: Mappable) -> LocationPagingVC {

        var first: UIViewController? {
            if model.canPost {
                let vc = R.storyboard.locationInfo.locationInfo()
                vc?.inject(model: model)
                return vc
            } else {
                return LocationWebsiteVC(mappable: model)
            }
        }

        #if NONLOCATIONS_CAN_POST
        let second = R.storyboard.locationPhotos.locationPhotos()?.inject(model: model)
        let third = R.storyboard.locationPosts.locationPosts()?.inject(model: model)
        #else
        var second: UIViewController? {
            if model.canPost {
                let vc = R.storyboard.locationPhotos.locationPhotos()
                vc?.inject(model: model)
                return vc
            } else {
                return nil
            }
        }
        var third: UIViewController? {
            if model.canPost {
                let vc = R.storyboard.locationPosts.locationPosts()
                vc?.inject(model: model)
                return vc
            } else {
                return nil
            }
        }
        #endif

        let controllers = [
            first,
            second,
            third
        ].compactMap { $0 }

        return LocationPagingVC(viewControllers: controllers)
    }

    /// Construction by injection
    ///
    /// - Parameter viewControllers: Controllers
    override init(viewControllers: [UIViewController]) {
        super.init(viewControllers: viewControllers)

        if let webVC = viewControllers[0] as? LocationWebsiteVC {
            webVC.titleDelegate = self
        }
        configure()
    }

    /// Unsupported coding constructor
    ///
    /// - Parameter coder: An unarchiver object.
    required init?(coder: NSCoder) {
        return nil
    }

    /// Prepare for reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        expose()
    }

    /// Actions to take after reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        report(screen: "Location Paging")
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
        expose(view: collectionView,
               path: indexPath,
               cell: cell)
        return cell
    }
}

// MARK: - Private

private extension LocationPagingVC {

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

// MARK: - TitleChangeDelegate

extension LocationPagingVC: TitleChangeDelegate {

    /// Notify of title change
    ///
    /// - Parameter title: New title
    func changed(title: String) {
        reloadMenu()
    }
}

// MARK: - Exposing

extension LocationPagingVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        UILocationPaging.menu.expose(item: collectionView)
    }
}

// MARK: - CollectionCellExposing

extension LocationPagingVC: CollectionCellExposing {

    /// Expose cell to UI tests
    ///
    /// - Parameters:
    ///   - view: Collection
    ///   - path: Index path
    ///   - cell: Cell
    func expose(view: UICollectionView,
                path: IndexPath,
                cell: UICollectionViewCell) {
        guard let page = Page(rawValue: path.item) else { return }

        switch page {
        case .first:
            UILocationPaging.first.expose(item: cell)
        case .photos:
            UILocationPaging.photos.expose(item: cell)
        case .posts:
            UILocationPaging.posts.expose(item: cell)
        }
    }
}
