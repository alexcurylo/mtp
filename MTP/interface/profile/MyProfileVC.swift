// @copyright Trollwerks Inc.

import Anchorage

final class MyProfileVC: UIViewController, ServiceProvider {

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
        case R.segue.myProfileVC.directEdit.identifier,
             R.segue.myProfileVC.showEditProfile.identifier,
             R.segue.myProfileVC.showSettings.identifier:
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

        let pagesVC = MyProfilePagingVC()
        addChild(pagesVC)
        holder.addSubview(pagesVC.view)
        pagesVC.view.edgeAnchors == holder.edgeAnchors
        pagesVC.didMove(toParent: self)
    }

    func observe() {
        guard userObserver == nil else { return }

        configure()
        userObserver = gestalt.userObserver { [weak self] in
            self?.configure()
        }
    }

    func configure() {
        guard let user = gestalt.user else { return }

        avatarImageView?.set(thumbnail: user)
        fullNameLabel?.text = user.fullName
        countryLabel?.text = user.location.description

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        birthdayLabel?.text = dateFormatter.string(from: user.birthday)

        log.todo("follow counts")
        let followersCount = 9_999
        let followers = Localized.followers(followersCount.grouped)
        followersLabel?.text = followers
        let followingCount = 9_999
        let following = Localized.following(followingCount.grouped)
        followingLabel?.text = following
    }
}
