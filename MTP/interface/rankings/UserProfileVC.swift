// @copyright Trollwerks Inc.

import UIKit

final class UserProfileVC: ProfileVC {

    private typealias Segues = R.segue.userProfileVC

    @IBOutlet private var closeButton: UIButton?

    override var pages: [UIViewController] {
        return [
            R.storyboard.profileAbout.about(),
            R.storyboard.profilePhotos.photos(),
            R.storyboard.profilePosts.posts()
        ].compactMap { $0 }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        expose()
    }

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

    func expose() {
        UserProfileVCs.close.expose(item: closeButton)
    }
}
