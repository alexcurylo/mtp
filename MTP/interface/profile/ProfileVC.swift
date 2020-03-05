// @copyright Trollwerks Inc.

import Anchorage
import Parchment

/// Base class for local and remote user profiles
class ProfileVC: UIViewController {

    // verified in requireOutlets
    @IBOutlet private var headerView: UIView!
    @IBOutlet private var avatarImageView: UIImageView!
    @IBOutlet private var fullNameLabel: UILabel!
    @IBOutlet private var countryLabel: UILabel!
    @IBOutlet private var followersLabel: UILabel!
    @IBOutlet private var followingLabel: UILabel!
    @IBOutlet private var pagesHolder: UIView!

    /// Pages controller
    private(set) var pagingVC: ProfilePagingVC?

    // verified in requireInjection
    private var user: User!
    // swiftlint:disable:previous implicitly_unwrapped_optional

    private var headerObservation: NSKeyValueObservation?

    /// :nodoc:
    override func viewDidLoad() {
        super.viewDidLoad()

        requireOutlets()
        requireInjection()

        setupHeaderView()
        setupPagesHolder()

        configure()
        observe()
    }

    /// :nodoc:
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .standard)
    }

    /// Controllers to be displayed in PagingViewController
    var pages: [UIViewController] { [] }

    /// Set up data change observations
    func observe() {
        // to be overridden
    }

    /// Configure for display
    func configure() {
        commonConfigure()
    }
}

// MARK: - Private

private extension ProfileVC {

    func setupHeaderView() {
        headerView.round(corners: .top(radius: 5))

        if headerObservation == nil {
            headerObservation = headerView.layer.observe(\.bounds) { [weak self] _, _ in
                self?.setupHeaderView()
            }
        }
    }

    func setupPagesHolder() {
        let vcs = pages
        vcs.forEach {
            ($0 as? UserInjectable)?.inject(model: user)
        }
        let paging = ProfilePagingVC(viewControllers: vcs)
        pagingVC = paging
        paging.exposer = self as? CollectionCellExposing
        addChild(paging)
        pagesHolder.addSubview(paging.view)
        paging.view.edgeAnchors == pagesHolder.edgeAnchors
        paging.didMove(toParent: self)
    }

    func commonConfigure() {
        avatarImageView.load(image: user)
        fullNameLabel.text = user.fullName
        countryLabel.text = user.locationName

        #if FOLLOWERS_IMPLEMENTED
        let followersCount = 9999
        let followers = L.followers(followersCount.grouped)
        followersLabel.text = followers
        let followingCount = 9999
        let following = L.following(followingCount.grouped)
        followingLabel.text = following
        #endif
    }
}

// MARK: - InterfaceBuildable

extension ProfileVC: InterfaceBuildable {

    /// Injection enforcement for viewDidLoad
    func requireOutlets() {
        avatarImageView.require()
        countryLabel.require()
        fullNameLabel.require()
        headerView.require()
        pagesHolder.require()
        #if FOLLOWERS_IMPLEMENTED
        followersLabel.require()
        followingLabel.require()
        #endif
    }
}

// MARK: - Injectable

extension ProfileVC: Injectable {

    /// Injected dependencies
    typealias Model = User

    /// Handle dependency injection
    /// - Parameter model: Dependencies
    func inject(model: Model) {
        let updating = user != nil
        user = model
        if updating {
            configure()
        }
    }

    /// Enforce dependency injection
    func requireInjection() {
        user.require()
    }
}

/// Convenience for injecting a User model
protocol UserInjectable {

    /// Inject a User
    /// - Parameter model: User
    func inject(model: User)
}

extension ProfileVC: UserInjectable { }
