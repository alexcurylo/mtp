// @copyright Trollwerks Inc.

import Parchment

final class MyProfileVC: ProfileVC {

    private typealias Segues = R.segue.myProfileVC

    @IBOutlet private var birthdayLabel: UILabel?

    fileprivate enum Page: Int {

        case about
        case counts
        case photos
        case posts
    }

    override var pages: [UIViewController] {
        return [
            R.storyboard.profileAbout.about(),
            R.storyboard.myCounts.myCounts(),
            R.storyboard.profilePhotos.photos(),
            R.storyboard.profilePosts.posts()
        ].compactMap { $0 }
    }

    private var userObserver: Observer?

    override func viewDidLoad() {
        if let user = data.user {
            inject(model: User(from: user))
        }
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        expose()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
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

        guard let user = data.user else { return }

        birthdayLabel?.text = DateFormatter.mtpBirthday.string(from: user.birthday)
    }
}

// MARK: - Exposing

extension MyProfileVC: Exposing {

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
