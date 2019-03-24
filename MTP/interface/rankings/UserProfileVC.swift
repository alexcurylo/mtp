// @copyright Trollwerks Inc.

import Anchorage

final class UserProfileVC: UIViewController, ServiceProvider {

    enum Tab {
        case visited
        case remaining
    }

    private typealias Segues = R.segue.userProfileVC

    @IBOutlet private var headerView: UIView?
    @IBOutlet private var avatarImageView: UIImageView?
    @IBOutlet private var fullNameLabel: UILabel?
    @IBOutlet private var countryLabel: UILabel?

    @IBOutlet private var pagesHolder: UIView?

    private var userObserver: Observer?

    private var user: User?
    private var selected: Tab?
    private var errorMessage: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        setupPagesHolder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

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
        case Segues.dismissUserProfile.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

private extension UserProfileVC {

    @IBAction func mapButtonTapped(_ sender: UIButton) {
        let tabController = presentingViewController as? MainTBC
        tabController?.dismiss(animated: false) { [user] in
            tabController?.route(to: user)
        }
    }

    func setupPagesHolder() {
        guard let holder = pagesHolder else { return }

        let pagesVC = UserProfilePagingVC.profile
        addChild(pagesVC)
        holder.addSubview(pagesVC.view)
        pagesVC.view.edgeAnchors == holder.edgeAnchors
        pagesVC.didMove(toParent: self)
    }

    func observe() {
        guard userObserver == nil else { return }

        configure()
        userObserver = data.observer(of: .userId) { [weak self] _ in
            self?.configure()
        }
    }

    func configure() {
        guard let user = user else { return }

        avatarImageView?.set(thumbnail: user)
        fullNameLabel?.text = user.fullName
        countryLabel?.text = user.locationName
    }
}

extension UserProfileVC: Injectable {

    typealias Model = (user: User, tab: Tab)

    func inject(model: Model) {
        user = model.user
        selected = model.tab
    }

    func requireInjections() {
        user.require()
        selected.require()

        headerView.require()
        avatarImageView.require()
        fullNameLabel.require()
        countryLabel.require()
        pagesHolder.require()
    }
}
