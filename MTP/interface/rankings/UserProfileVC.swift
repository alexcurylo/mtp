// @copyright Trollwerks Inc.

import UIKit

final class UserProfileVC: ProfileVC {

    private typealias Segues = R.segue.userProfileVC

    override var pages: [UIViewController] {
        return [
            R.storyboard.profileAbout.about(),
            R.storyboard.profilePhotos.photos(),
            R.storyboard.profilePosts.posts()
        ].compactMap { $0 }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        log.verbose("prepare for \(segue.name)")
        switch segue.identifier {
        case Segues.dismissUserProfile.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}
