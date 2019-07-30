// @copyright Trollwerks Inc.

import Parchment

final class LocationPagingVC: FixedPagingViewController, ServiceProvider {

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

    override init(viewControllers: [UIViewController]) {
        super.init(viewControllers: viewControllers)

        if let webVC = viewControllers[0] as? LocationWebsiteVC {
            webVC.titleDelegate = self
        }
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(viewControllers: [])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

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

// MARK: - Injectable

extension LocationPagingVC: TitleChangeDelegate {

    func changed(title: String) {
        reloadMenu()
    }
}

// MARK: - Injectable

extension LocationPagingVC: Injectable {

    typealias Model = Mappable

    @discardableResult func inject(model: Model) -> Self {
        return self
    }

    func requireInjections() {
    }
}
