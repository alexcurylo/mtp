// @copyright Trollwerks Inc.

import Anchorage
import Parchment

/// Allow user to review and edit all visits
final class UserCountsVC: UIViewController, ServiceProvider {

    /// Visited or remaining tab
    enum Tab: Int {

        /// Visited tab index 0
        case visited = 0
        /// Remaining tab index 1
        case remaining
    }

    private typealias Segues = R.segue.userCountsVC

    /// Injection enforcement for viewDidLoad
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var headerView: UIView!
    @IBOutlet private var avatarImageView: UIImageView!
    @IBOutlet private var fullNameLabel: UILabel!
    @IBOutlet private var countryLabel: UILabel!
    @IBOutlet private var pagesHolder: UIView!

    private var userObserver: Observer?

    // verified in requireInjection
    private var user: User!
    // swiftlint:disable:previous implicitly_unwrapped_optional

    private var list: Checklist = .locations
    private var selected: Tab = .visited

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireOutlets()
        requireInjection()

        setupPagesHolder()
    }

    /// Prepare for reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        observe()
        expose()
    }
}

// MARK: - Private

private extension UserCountsVC {

    func setupPagesHolder() {
        let pagesVC = UserCountsPagingVC.profile(model: (list, user))
        addChild(pagesVC)
        pagesHolder.addSubview(pagesVC.view)
        pagesVC.view.edgeAnchors == pagesHolder.edgeAnchors
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
        avatarImageView.load(image: user)
        fullNameLabel.text = user.fullName
        countryLabel.text = user.locationName
    }
}

// MARK: - Exposing

extension UserCountsVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        UIUserCounts.close.expose(item: closeButton)
    }
}

// MARK: - InterfaceBuildable

extension UserCountsVC: InterfaceBuildable {

    /// Injection enforcement for viewDidLoad
    func requireOutlets() {
        avatarImageView.require()
        closeButton.require()
        countryLabel.require()
        fullNameLabel.require()
        headerView.require()
        pagesHolder.require()
    }
}

// MARK: - Injectable

extension UserCountsVC: Injectable {

    /// Injected dependencies
    typealias Model = (list: Checklist, user: User, tab: Tab)

    /// Handle dependency injection
    ///
    /// - Parameter model: Dependencies
    func inject(model: Model) {
        list = model.list
        user = model.user
        selected = model.tab
    }

    /// Enforce dependency injection
    func requireInjection() {
        user.require()
    }
}
