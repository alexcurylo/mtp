// @copyright Trollwerks Inc.

import Parchment

final class LocationPagingVC: FixedPagingViewController, ServiceProvider {

    static func profile(model: Model) -> LocationPagingVC {
        let controllers = [
            R.storyboard.locationInfo.locationInfo()?.inject(model: model),
            R.storyboard.locationPhotos.locationPhotos()?.inject(model: model),
            R.storyboard.locationReviews.locationReviews()?.inject(model: model)
        ].compactMap { $0 }

        return LocationPagingVC(viewControllers: controllers)
    }

    override init(viewControllers: [UIViewController]) {
        super.init(viewControllers: viewControllers)
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

extension LocationPagingVC: Injectable {

    typealias Model = PlaceAnnotation

    @discardableResult func inject(model: Model) -> Self {
        return self
    }

    func requireInjections() {
    }
}
