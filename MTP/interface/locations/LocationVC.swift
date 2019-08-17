// @copyright Trollwerks Inc.

import Anchorage

/// More Info page for map POIs
final class LocationVC: UIViewController, ServiceProvider {

    private typealias Segues = R.segue.locationVC

    // verified in requireOutlets
    @IBOutlet private var closeButton: UIBarButtonItem!
    @IBOutlet private var mapButton: UIBarButtonItem!
    @IBOutlet private var placeImageView: UIImageView!
    @IBOutlet private var categoryLabel: UILabel!
    @IBOutlet private var distanceLabel: UILabel!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var pagesHolder: UIView!

    // verified in requireInjection
    private var mappable: Mappable!
    // swiftlint:disable:previous implicitly_unwrapped_optional

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireOutlets()
        requireInjection()

        configure()
    }

    /// Prepare for reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .standard)
        expose()
    }
}

// MARK: - Private

private extension LocationVC {

    @IBAction func mapButtonTapped(_ sender: UIBarButtonItem) {
        mappable.reveal(callout: true)
    }

    func configure() {
        guard let mappable = mappable else { return }

        placeImageView.load(image: mappable)
        categoryLabel.text = mappable.checklist.category(full: true).uppercased()
        distanceLabel.text = L.away(mappable.distance.formatted).uppercased()
        nameLabel.text = mappable.title

        setupPagesHolder()
    }

    func setupPagesHolder() {
        let pagesVC = LocationPagingVC.profile(model: mappable)
        addChild(pagesVC)
        pagesHolder.addSubview(pagesVC.view)
        pagesVC.view.edgeAnchors == pagesHolder.edgeAnchors
        pagesVC.didMove(toParent: self)
    }
}

// MARK: - Exposing

extension LocationVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        UILocation.close.expose(item: closeButton)
        UILocation.map.expose(item: mapButton)
    }
}

// MARK: - InterfaceBuildable

extension LocationVC: InterfaceBuildable {

    /// Injection enforcement for viewDidLoad
    func requireOutlets() {
        categoryLabel.require()
        closeButton.require()
        distanceLabel.require()
        mapButton.require()
        nameLabel.require()
        pagesHolder.require()
        placeImageView.require()
    }
}

// MARK: - Injectable

extension LocationVC: Injectable {

    /// Injected dependencies
    typealias Model = Mappable

    /// Handle dependency injection
    ///
    /// - Parameter model: Dependencies
    func inject(model: Model) {
        mappable = model
    }

    /// Enforce dependency injection
    func requireInjection() {
        mappable.require()
    }
}
