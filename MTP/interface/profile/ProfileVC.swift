// @copyright Trollwerks Inc.

import Anchorage
import Parchment

class ProfileVC: UIViewController, ServiceProvider {

    @IBOutlet private var headerView: UIView?
    @IBOutlet private var avatarImageView: UIImageView?
    @IBOutlet private var fullNameLabel: UILabel?
    @IBOutlet private var countryLabel: UILabel?
    @IBOutlet private var followersLabel: UILabel?
    @IBOutlet private var followingLabel: UILabel?

    @IBOutlet private var pagesHolder: UIView?

    private(set) var pagingVC: ProfilePagingVC?

    private var user: User?

    private var headerObservation: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        setupHeaderView()
        setupPagesHolder()

        configure()
        observe()
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

    var pages: [UIViewController] {
        return []
    }

    func observe() {
        // to be overridden
    }

    func configure() {
        commonConfigure()
    }
}

// MARK: - Private

private extension ProfileVC {

    func setupHeaderView() {
        guard let header = headerView else { return }

        header.round(corners: .top(radius: 5))

        if headerObservation == nil {
            headerObservation = header.layer.observe(\.bounds) { [weak self] _, _ in
                self?.setupHeaderView()
            }
        }
    }

    func setupPagesHolder() {
        guard let holder = pagesHolder,
              let user = user else { return }

        let vcs = pages
        vcs.forEach {
            ($0 as? UserInjectable)?.inject(model: user)
        }
        let paging = ProfilePagingVC(viewControllers: vcs)
        pagingVC = paging
        paging.exposer = self as? CollectionCellExposing
        addChild(paging)
        holder.addSubview(paging.view)
        paging.view.edgeAnchors == holder.edgeAnchors
        paging.didMove(toParent: self)
    }

    func commonConfigure() {
        guard let user = user else { return }

        avatarImageView?.load(image: user)
        fullNameLabel?.text = user.fullName
        countryLabel?.text = user.locationName

        #if FOLLOWERS_IMPLEMENTED
        let followersCount = 9_999
        let followers = L.followers(followersCount.grouped)
        followersLabel?.text = followers
        let followingCount = 9_999
        let following = L.following(followingCount.grouped)
        followingLabel?.text = following
        #endif
    }
}

extension ProfileVC: Injectable {

    typealias Model = User

    @discardableResult func inject(model: Model) -> Self {
        let updating = user != nil
        user = model
        if updating {
            configure()
        }

        return self
    }

    func requireInjections() {
        user.require()

        headerView.require()
        avatarImageView.require()
        fullNameLabel.require()
        countryLabel.require()
        pagesHolder.require()
        #if FOLLOWERS_IMPLEMENTED
        followersLabel.require()
        followingLabel.require()
        #endif
    }
}

protocol UserInjectable {

    @discardableResult func inject(model: User) -> Self
}

extension ProfileVC: UserInjectable { }
