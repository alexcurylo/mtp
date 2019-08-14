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

    @IBOutlet private var closeButton: UIButton?
    @IBOutlet private var headerView: UIView?
    @IBOutlet private var avatarImageView: UIImageView?
    @IBOutlet private var fullNameLabel: UILabel?
    @IBOutlet private var countryLabel: UILabel?

    @IBOutlet private var pagesHolder: UIView?

    private var userObserver: Observer?

    private var list: Checklist = .locations
    private var user: User?
    private var selected: Tab = .visited

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

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

    /// Instrument and inject navigation
    ///
    /// - Parameters:
    ///   - segue: Navigation action
    ///   - sender: Action originator
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.dismissUserCounts.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

// MARK: - Private

private extension UserCountsVC {

    @IBAction func mapButtonTapped(_ sender: UIButton) {
        app.route(to: user)
    }

    func setupPagesHolder() {
        guard let holder = pagesHolder,
              let user = user else { return }

        let pagesVC = UserCountsPagingVC.profile(model: (list, user))
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

        avatarImageView?.load(image: user)
        fullNameLabel?.text = user.fullName
        countryLabel?.text = user.locationName
    }
}

// MARK: - Exposing

extension UserCountsVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        UIUserCounts.close.expose(item: closeButton)
    }
}

// MARK: - Injectable

extension UserCountsVC: Injectable {

    /// Injected dependencies
    typealias Model = (list: Checklist, user: User, tab: Tab)

    /// Handle dependency injection
    ///
    /// - Parameter model: Dependencies
    /// - Returns: Chainable self
    @discardableResult func inject(model: Model) -> Self {
        list = model.list
        user = model.user
        selected = model.tab
        return self
    }

    /// Enforce dependency injection
    func requireInjections() {
        user.require()

        closeButton.require()
        headerView.require()
        avatarImageView.require()
        fullNameLabel.require()
        countryLabel.require()
        pagesHolder.require()
    }
}
