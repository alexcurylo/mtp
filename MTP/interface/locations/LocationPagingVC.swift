// @copyright Trollwerks Inc.

import Parchment

/// Displays location info tabs
final class LocationPagingVC: FixedPagingViewController, ServiceProvider {

    /// Provide pages container
    ///
    /// - Parameter model: Model to populate pages
    /// - Returns: LocationPagingVC
    static func profile(model: Model) -> LocationPagingVC {

        var first: UIViewController? {
            if model.canPost {
                return R.storyboard.locationInfo.locationInfo()?.inject(model: model)
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
                return R.storyboard.locationPhotos.locationPhotos()?.inject(model: model)
            } else {
                return nil
            }
        }
        var third: UIViewController? {
            if model.canPost {
                return R.storyboard.locationPosts.locationPosts()?.inject(model: model)
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

    /// Unavailable coding constructor
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

// MARK: - Injectable

extension LocationPagingVC: Injectable {

    /// Injected dependencies
    typealias Model = Mappable

    /// Handle dependency injection
    ///
    /// - Parameter model: Dependencies
    /// - Returns: Chainable self
    @discardableResult func inject(model: Model) -> Self {
        return self
    }

    /// Enforce dependency injection
    func requireInjections() { }
}
