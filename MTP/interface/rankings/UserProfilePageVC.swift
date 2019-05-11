// @copyright Trollwerks Inc.

import UIKit

protocol UserProfilePageDataSource: AnyObject {

    var scorecard: Scorecard? { get }
    var contentState: ContentState { get }
}

final class UserProfilePageVC: CountsPageVC {

    weak var dataSource: UserProfilePageDataSource? {
        didSet { update() }
    }

    private var tab: UserProfileVC.Tab
    private var user: User
    private var status: Checklist.Status

    override var places: [PlaceInfo] {
        guard dataSource?.contentState == .data else { return [] }

        let showVisited = tab == .visited
        let places = list.places
        let visited = visits
        guard !visited.isEmpty else { return showVisited ? [] : places }

        return places.compactMap {
            let isVisited = visited.contains($0.placeId)
            return isVisited == showVisited ? $0 : nil
        }
    }
    override var visits: [Int] {
        if let scorecard = dataSource?.scorecard {
            return Array(scorecard.visits)
        } else {
            return []
        }
    }

    init(model: Model) {
        tab = model.tab
        user = model.user
        status = model.list.status(of: user)

        super.init(model: model.list)
    }

    override func update() {
        super.update()

        if let scorecard = dataSource?.scorecard {
            title = tab.title(scorecard: scorecard)
            let isEmpty = tab.score(scorecard: scorecard) == 0
            let state: ContentState = isEmpty ? .empty : .data
            collectionView.set(message: state)
        } else {
            title = tab.title(status: status)
            let state = dataSource?.contentState ?? .loading
            collectionView.set(message: state)
        }
    }
}

extension UserProfilePageVC: Injectable {

    typealias Model = (list: Checklist,
                       user: User,
                       tab: UserProfileVC.Tab)

    @discardableResult func inject(model: Model) -> Self {
        return self
    }

    func requireInjections() {
    }
}

extension UserProfileVC.Tab {

    func title(status: Checklist.Status) -> String {
        switch self {
        case .visited:
            return Localized.visitedCount(status.visited)
        case .remaining:
            return Localized.remainingCount(status.remaining)
       }
    }

    func score(status: Checklist.Status) -> Int {
        switch self {
        case .visited:
            return status.visited
        case .remaining:
            return status.remaining
        }
    }

    func title(scorecard: Scorecard) -> String {
        switch self {
        case .visited:
            return Localized.visitedCount(scorecard.visited)
        case .remaining:
            return Localized.remainingCount(scorecard.remaining)
        }
    }

    func score(scorecard: Scorecard) -> Int {
        switch self {
        case .visited:
            return scorecard.visited
        case .remaining:
            return scorecard.remaining
        }
    }
}
