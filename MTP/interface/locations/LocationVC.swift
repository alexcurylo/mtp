// @copyright Trollwerks Inc.

import Anchorage

final class LocationVC: UIViewController, ServiceProvider {

    private typealias Segues = R.segue.locationVC

    @IBOutlet private var placeImageView: UIImageView?
    @IBOutlet private var categoryLabel: UILabel?
    @IBOutlet private var distanceLabel: UILabel?
    @IBOutlet private var nameLabel: UILabel?

    @IBOutlet private var pagesHolder: UIView?

    // swiftlint:disable:next implicitly_unwrapped_optional
    private var mappable: Mappable!

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        configure()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .standard)
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

// MARK: - Injectable

extension LocationVC: Injectable {

    typealias Model = Mappable

    @discardableResult func inject(model: Model) -> Self {
        mappable = model
        return self
    }

    func requireInjections() {
        mappable.require()

        placeImageView.require()
        categoryLabel.require()
        distanceLabel.require()
        nameLabel.require()
        pagesHolder.require()
    }
}
