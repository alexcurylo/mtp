// @copyright Trollwerks Inc.

import UIKit

enum Exposed {

    case locationsVCs
    case mainTBCs
    case myProfileVCs
}

enum LocationsVCs: Exposable {
    case nav
    case filter
    case nearby
}

enum MainTBCs: Exposable {
    case bar
    case locations
    case rankings
    case myProfile
}

enum MyProfileVCs: Exposable {
    case menu
    case about
    case counts
    case photos
    case posts
}
