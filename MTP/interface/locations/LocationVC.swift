// @copyright Trollwerks Inc.

import Anchorage

final class LocationVC: UIViewController, ServiceProvider {

    //private typealias Segues = R.segue.locationVC

    @IBOutlet private var headerView: UIView?
    @IBOutlet private var avatarImageView: UIImageView?
    @IBOutlet private var fullNameLabel: UILabel?
    @IBOutlet private var countryLabel: UILabel?
    @IBOutlet private var birthdayLabel: UILabel?
    @IBOutlet private var followersLabel: UILabel?
    @IBOutlet private var followingLabel: UILabel?

    @IBOutlet private var pagesHolder: UIView?

    private var place: PlaceAnnotation?

    private var userObserver: Observer?

    private var headerObservation: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        log.todo("implement LocationVC")

        title = place?.title
        setupHeaderView()
        setupPagesHolder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .standard)
        observe()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        log.verbose("prepare for \(segue.name)")
        switch segue.identifier {
        //case Segues.directEdit.identifier,
             //Segues.showEditProfile.identifier,
             //Segues.showSettings.identifier:
            //break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            self.setupHeaderView()
        }
    }
}

private extension LocationVC {

    @IBAction func unwindToLocation(segue: UIStoryboardSegue) {
        log.verbose(segue.name)
    }

    func setupHeaderView() {
        guard let header = headerView else { return }

        header.round(corners: [.topLeft, .topRight], by: 5)

        if headerObservation == nil {
            headerObservation = header.layer.observe(\.bounds) { [weak self] _, _ in
                self?.setupHeaderView()
            }
        }
    }

    func setupPagesHolder() {
        guard let holder = pagesHolder,
              let place = place else { return }

        let pagesVC = LocationPagingVC.profile(model: place)
        addChild(pagesVC)
        holder.addSubview(pagesVC.view)
        pagesVC.view.edgeAnchors == holder.edgeAnchors
        pagesVC.didMove(toParent: self)
    }

    func observe() {
        guard userObserver == nil else { return }

        configure()
        userObserver = data.observer(of: .user) { [weak self] _ in
            self?.configure()
        }
    }

    func configure() {
        guard let place = place else { return }

        avatarImageView?.load(image: place)
        fullNameLabel?.text = place.title
        countryLabel?.text = place.subtitle

        birthdayLabel?.text = ""
    }
}

extension LocationVC: Injectable {

    typealias Model = PlaceAnnotation

    @discardableResult func inject(model: Model) -> Self {
        place = model
        return self
    }

    func requireInjections() {
        place.require()

        avatarImageView.require()
        fullNameLabel.require()
        countryLabel.require()
    }
}
