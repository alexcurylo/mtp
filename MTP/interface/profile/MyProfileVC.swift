// @copyright Trollwerks Inc.

import Anchorage

final class MyProfileVC: UIViewController, ServiceProvider {

    private typealias Segues = R.segue.myProfileVC

    @IBOutlet private var headerView: UIView?
    @IBOutlet private var avatarImageView: UIImageView?
    @IBOutlet private var fullNameLabel: UILabel?
    @IBOutlet private var countryLabel: UILabel?
    @IBOutlet private var birthdayLabel: UILabel?
    @IBOutlet private var followersLabel: UILabel?
    @IBOutlet private var followingLabel: UILabel?

    @IBOutlet private var pagesHolder: UIView?

    private var userObserver: Observer?

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

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
        case Segues.directEdit.identifier,
             Segues.showEditProfile.identifier,
             Segues.showSettings.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

private extension MyProfileVC {

    @IBAction func unwindToMyProfile(segue: UIStoryboardSegue) {
        log.verbose(segue.name)
    }

    func setupHeaderView() {
        headerView?.round(corners: [.topLeft, .topRight], by: 5)
    }

    func setupPagesHolder() {
        guard let holder = pagesHolder else { return }

        let pagesVC = MyProfilePagingVC.profile
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
        guard let user = data.user else { return }

        avatarImageView?.set(thumbnail: user)
        fullNameLabel?.text = user.fullName
        countryLabel?.text = user.location.description

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        birthdayLabel?.text = dateFormatter.string(from: user.birthday)

        #if FOLLOWERS_IMPLEMENTED
        let followersCount = 9_999
        let followers = Localized.followers(followersCount.grouped)
        followersLabel?.text = followers
        let followingCount = 9_999
        let following = Localized.following(followingCount.grouped)
        followingLabel?.text = following
        #endif
    }
}

extension MyProfileVC: Injectable {

    typealias Model = ()

    @discardableResult func inject(model: Model) -> MyProfileVC {
        return self
    }

    func requireInjections() {
        headerView.require()
        avatarImageView.require()
        fullNameLabel.require()
        countryLabel.require()
        birthdayLabel.require()
        pagesHolder.require()
        #if FOLLOWERS_IMPLEMENTED
        followersLabel.require()
        followingLabel.require()
        #endif
    }
}
