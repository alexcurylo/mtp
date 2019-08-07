// @copyright Trollwerks Inc.

import Parchment

/// Displays logged in user information
final class MyProfileVC: ProfileVC {

    private typealias Segues = R.segue.myProfileVC

    @IBOutlet private var birthdayLabel: UILabel?

    fileprivate enum Page: Int {

        case about
        case counts
        case photos
        case posts
    }

    /// Controllers to be displayed in PagingViewController
    override var pages: [UIViewController] {
        return [
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
        switch segue.identifier {
        case Segues.showSettings.identifier:
            if let settings = Segues.showSettings(segue: segue)?.destination {
                settings.inject(model: reportMessage)
                reportMessage = ""
            }
        case Segues.directEdit.identifier,
             Segues.showEditProfile.identifier,
             Segues.showSettings.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }

    override func observe() {
        guard userObserver == nil else { return }

        userObserver = data.observer(of: .user) { [weak self] _ in
            guard let self = self,
                let user = self.data.user else { return }

            self.inject(model: User(from: user))
        }
    }

    override func configure() {
        super.configure()

        let title: String?
        if let birthday = data.user?.birthday {
            title = DateFormatter.mtpBirthday.string(from: birthday)
            return
        } else {
            title = nil
        }
        birthdayLabel?.text = title
    }

    func reportContent(message: String) {
        reportMessage = message
        performSegue(withIdentifier: Segues.showSettings, sender: self)
    }
}

// MARK: - Exposing

extension MyProfileVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        guard let menu = pagingVC?.collectionView else { return }
        MyProfileVCs.menu.expose(item: menu)
    }
}

// MARK: - CollectionCellExposing

extension MyProfileVC: CollectionCellExposing {

    func expose(view: UICollectionView,
                path: IndexPath,
                cell: UICollectionViewCell) {
        switch path.item {
        case Page.about.rawValue:
            MyProfileVCs.about.expose(item: cell)
        case Page.counts.rawValue:
            MyProfileVCs.counts.expose(item: cell)
        case Page.photos.rawValue:
            MyProfileVCs.photos.expose(item: cell)
        case Page.posts.rawValue:
            MyProfileVCs.posts.expose(item: cell)
        default:
            break
        }
    }
}

// MARK: - Private

private extension MyProfileVC {

    @IBAction func unwindToMyProfile(segue: UIStoryboardSegue) { }
}
