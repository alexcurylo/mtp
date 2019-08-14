// @copyright Trollwerks Inc.

import Anchorage

/// More Info page for map POIs
final class LocationVC: UIViewController, ServiceProvider {

    private typealias Segues = R.segue.locationVC

    @IBOutlet private var closeButton: UIBarButtonItem?
    @IBOutlet private var mapButton: UIBarButtonItem?
    @IBOutlet private var placeImageView: UIImageView?
    @IBOutlet private var categoryLabel: UILabel?
    @IBOutlet private var distanceLabel: UILabel?
    @IBOutlet private var nameLabel: UILabel?

    @IBOutlet private var pagesHolder: UIView?

    // swiftlint:disable:next implicitly_unwrapped_optional
    private var mappable: Mappable!

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

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

    /// Instrument and inject navigation
    ///
    /// - Parameters:
    ///   - segue: Navigation action
    ///   - sender: Action originator
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.pop.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

// MARK: - Private

private extension LocationVC {

    @IBAction func mapButtonTapped(_ sender: UIBarButtonItem) {
        mappable.reveal(callout: true)
    }

    func configure() {
        guard let mappable = mappable else { return }

        placeImageView?.load(image: mappable)
        categoryLabel?.text = mappable.checklist.category(full: true).uppercased()
        distanceLabel?.text = L.away(mappable.distance.formatted).uppercased()
        nameLabel?.text = mappable.title

        setupPagesHolder()
    }

    func setupPagesHolder() {
        guard let holder = pagesHolder else { return }

        let pagesVC = LocationPagingVC.profile(model: mappable)
        addChild(pagesVC)
        holder.addSubview(pagesVC.view)
        pagesVC.view.edgeAnchors == holder.edgeAnchors
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

// MARK: - Injectable

extension LocationVC: Injectable {

    /// Injected dependencies
    typealias Model = Mappable

    /// Handle dependency injection
    ///
    /// - Parameter model: Dependencies
    /// - Returns: Chainable self
    @discardableResult func inject(model: Model) -> Self {
        mappable = model
        return self
    }

    /// Enforce dependency injection
    func requireInjections() {
        mappable.require()

        closeButton.require()
        mapButton.require()
        placeImageView.require()
        categoryLabel.require()
        distanceLabel.require()
        nameLabel.require()
        pagesHolder.require()
    }
}
