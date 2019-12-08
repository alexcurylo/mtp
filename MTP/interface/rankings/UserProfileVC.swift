// @copyright Trollwerks Inc.

import UIKit

/// Root class for remote user profile
final class UserProfileVC: ProfileVC {

    // verified in requireOutlets
    @IBOutlet private var closeButton: UIBarButtonItem!

    fileprivate enum Page: Int {

        case about
        case photos
        case posts
    }

    /// Controllers to be displayed in PagingViewController
    override var pages: [UIViewController] {
        return super.pages + [
            R.storyboard.profileAbout.about(),
            R.storyboard.profilePhotos.photos(),
            R.storyboard.profilePosts.posts()
        ].compactMap { $0 }
    }

    /// :nodoc:
     override func viewDidLoad() {
         super.viewDidLoad()
         closeButton.require()
    }

    /// :nodoc:
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        expose()
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
    /// - Parameters:
    ///   - view: Collection
    ///   - path: Index path
    ///   - cell: Cell
    func expose(view: UICollectionView,
                path: IndexPath,
                cell: UICollectionViewCell) {
        switch Page(rawValue: path.item) {
        case .about?:
            UIProfilePaging.about.expose(item: cell)
        case .photos?:
            UIProfilePaging.photos.expose(item: cell)
        default:
            UIProfilePaging.posts.expose(item: cell)
        }
    }
}
