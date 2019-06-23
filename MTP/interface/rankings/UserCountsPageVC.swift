// @copyright Trollwerks Inc.

import UIKit

protocol UserCountsPageDataSource: AnyObject {

    var scorecard: Scorecard? { get }
    var contentState: ContentState { get }
}

final class UserCountsPageVC: CountsPageVC {

    weak var dataSource: UserCountsPageDataSource? {
        didSet { refresh() }
    }

    override var places: [PlaceInfo] { return listPlaces }
    override var visited: [Int] { return listVisited }

    private var listPlaces: [PlaceInfo] = []
    private var listVisited: [Int] = []
    private let tab: UserCountsVC.Tab
    private let user: User
    private let status: Checklist.Status

    init(model: Model) {
        tab = model.tab
        user = model.user
        status = model.list.status(of: user)

        super.init(model: model.list)
    }

    func  refresh() {
        cache()
        update()
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

private extension UserCountsPageVC {

    func cache() {
        if let scorecard = dataSource?.scorecard {
            listVisited = Array(scorecard.visits)
        } else {
            listVisited = []
        }

        guard dataSource?.contentState == .data else {
            listPlaces = []
            return
        }

        let showVisited = tab == .visited
        let places = list.places
        guard !listVisited.isEmpty else {
            listPlaces = showVisited ? [] : places
            return
        }

        listPlaces = places.filter {
            showVisited == listVisited.contains($0.placeId)
        }
    }
}

extension UserCountsPageVC: Injectable {

    typealias Model = (list: Checklist,
                       user: User,
                       tab: UserCountsVC.Tab)

    @discardableResult func inject(model: Model) -> Self {
        return self
    }

    func requireInjections() {
    }
}

extension UserCountsVC.Tab {

    func title(status: Checklist.Status) -> String {
        switch self {
        case .visited:
            return L.visitedCount(status.visited)
        case .remaining:
            return L.remainingCount(status.remaining)
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
            return L.visitedCount(scorecard.visited)
        case .remaining:
            return L.remainingCount(scorecard.remaining)
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
