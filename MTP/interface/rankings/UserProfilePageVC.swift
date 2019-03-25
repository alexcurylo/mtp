// @copyright Trollwerks Inc.

import UIKit

final class UserProfilePageVC: CountsPageVC {

    private var tab: UserProfileVC.Tab
    private var user: User
    private var status: Checklist.Status

    override var places: [PlaceInfo] {
        //let places = list.places
        log.todo("filter by tab and user visits")
        return []
    }

    init(model: Model) {
        tab = model.tab
        user = model.user
        status = model.list.status(of: model.user)
        super.init(model: model.list)
    }

    override func update() {
        super.update()

        title = tab.title(status: status)
    }
}

extension UserProfilePageVC: Injectable {

    typealias Model = (list: Checklist,
                       user: User,
                       tab: UserProfileVC.Tab)

    func inject(model: Model) {
    }

    func requireInjections() {
    }
}

extension UserProfileVC.Tab {

    func title(status: Checklist.Status) -> String {
        switch self {
        case .visited:
            return Localized.visited(status.visited)
        case .remaining:
            return Localized.remaining(status.remaining)
       }
    }
}
