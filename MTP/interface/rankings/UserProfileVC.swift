// @copyright Trollwerks Inc.

import Anchorage
import Parchment

final class UserProfileVC: UIViewController, ServiceProvider {

    enum Tab: Int {
        case visited = 0
        case remaining
    }

    private typealias Segues = R.segue.userProfileVC

    @IBOutlet private var headerView: UIView?
    @IBOutlet private var avatarImageView: UIImageView?
    @IBOutlet private var fullNameLabel: UILabel?
    @IBOutlet private var countryLabel: UILabel?

    @IBOutlet private var pagesHolder: UIView?

    private var userObserver: Observer?

    private var list: Checklist = .locations
    private var user: User?
    private var selected: Tab = .visited

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
        guard let holder = pagesHolder,
              let user = user else { return }

        let pagesVC = UserProfilePagingVC.profile(model: (list, user))
        addChild(pagesVC)
        holder.addSubview(pagesVC.view)
        pagesVC.view.edgeAnchors == holder.edgeAnchors
        pagesVC.didMove(toParent: self)

        let item = pagesVC.pagingViewController(pagesVC,
                                                pagingItemForIndex: selected.rawValue)
        pagesVC.select(pagingItem: item, animated: false)
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

    typealias Model = (list: Checklist, user: User, tab: Tab)

    @discardableResult func inject(model: Model) -> UserProfileVC {
        list = model.list
        user = model.user
        selected = model.tab
        return self
    }

    func requireInjections() {
        user.require()

        headerView.require()
        avatarImageView.require()
        fullNameLabel.require()
        countryLabel.require()
        pagesHolder.require()
    }
}
