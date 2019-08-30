// @copyright Trollwerks Inc.

import Parchment

/// Displays logged in user information
final class MyProfileVC: ProfileVC {

    private typealias Segues = R.segue.myProfileVC

    fileprivate enum Page: Int {

        case about
        case counts
        case photos
        case posts
    }

    @IBOutlet private var editButton: UIBarButtonItem?
    @IBOutlet private var settingsButton: UIBarButtonItem?

    /// Controllers to be displayed in PagingViewController
    override var pages: [UIViewController] {
        return super.pages + [
            R.storyboard.profileAbout.about(),
            R.storyboard.myCounts.myCounts(),
            R.storyboard.profilePhotos.photos(),
            R.storyboard.profilePosts.posts()
        ].compactMap { $0 }
    }

    private var userObserver: Observer?
    private var reportMessage = ""

    /// Prepare for interaction
    override func viewDidLoad() {
        if let user = data.user {
            inject(model: User(from: user))
        }
        super.viewDidLoad()
    }

    /// Prepare for reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        expose()
    }

    /// Instrument and inject navigation
    ///
    /// - Parameters:
    ///   - segue: Navigation action
    ///   - sender: Action originator
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let settings = Segues.showSettings(segue: segue)?
                                .destination {
            settings.inject(model: reportMessage)
            reportMessage = ""
        }
    }

    /// Set up data change observations
    override func observe() {
        guard userObserver == nil else { return }

        userObserver = data.observer(of: .user) { [weak self] _ in
            guard let self = self,
                let user = self.data.user else { return }

            self.inject(model: User(from: user))
        }
    }

    /// Handle content reporting
    ///
    /// - Parameter message: Email body
    func reportContent(message: String) {
        reportMessage = message
        performSegue(withIdentifier: Segues.showSettings, sender: self)
    }
}

// MARK: - Exposing

extension MyProfileVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        let bar = navigationController?.navigationBar
        UIMyProfile.nav.expose(item: bar)
        UIMyProfile.edit.expose(item: editButton)
        UIMyProfile.settings.expose(item: settingsButton)
    }
}

// MARK: - CollectionCellExposing

extension MyProfileVC: CollectionCellExposing {

    /// Expose cell to UI tests
    ///
    /// - Parameters:
    ///   - view: Collection
    ///   - path: Index path
    ///   - cell: Cell
    func expose(view: UICollectionView,
                path: IndexPath,
                cell: UICollectionViewCell) {
        guard let page = Page(rawValue: path.item) else { return }

        switch page {
        case .about:
            UIProfilePaging.about.expose(item: cell)
        case .counts:
            UIProfilePaging.counts.expose(item: cell)
        case .photos:
            UIProfilePaging.photos.expose(item: cell)
        case .posts:
            UIProfilePaging.posts.expose(item: cell)
        }
    }
}

// MARK: - Private

private extension MyProfileVC {

    @IBAction func unwindToMyProfile(segue: UIStoryboardSegue) { }
}
