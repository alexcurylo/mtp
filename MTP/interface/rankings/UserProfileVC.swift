// @copyright Trollwerks Inc.

import UIKit

/// Root class for remote user profile
final class UserProfileVC: ProfileVC {

    private typealias Segues = R.segue.userProfileVC

    fileprivate enum Page: Int {

        case about
        case photos
        case posts
    }

    @IBOutlet private var closeButton: UIButton?

    /// Controllers to be displayed in PagingViewController
    override var pages: [UIViewController] {
        return [
            R.storyboard.profileAbout.about(),
            R.storyboard.profilePhotos.photos(),
            R.storyboard.profilePosts.posts()
        ].compactMap { $0 }
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
        case Segues.dismissUserProfile.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

// MARK: - Exposing

extension UserProfileVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        UIUserProfile.close.expose(item: closeButton)
    }
}

// MARK: - CollectionCellExposing

extension UserProfileVC: CollectionCellExposing {

    /// Expose cell to UI tests
    ///
    /// - Parameters:
    ///   - view: Collection
    ///   - path: Index path
    ///   - cell: Cell
    func expose(view: UICollectionView,
                path: IndexPath,
                cell: UICollectionViewCell) {
        switch path.item {
        case Page.about.rawValue:
            UIProfilePaging.about.expose(item: cell)
        case Page.photos.rawValue:
            UIProfilePaging.photos.expose(item: cell)
        case Page.posts.rawValue:
            UIProfilePaging.posts.expose(item: cell)
        default:
            break
        }
    }
}
