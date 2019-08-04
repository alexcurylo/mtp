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
    private var status: Checklist.VisitStatus

    init(model: Model) {
        tab = model.tab
        user = model.user
        status = model.list.visitStatus(of: user)

        super.init(model: model.list)
    }

    func  refresh() {
        cache()
        update()
    }

    override func update() {
        super.update()

        status = list.visitStatus(of: user)
        title = tab.title(status: status)

        let state: ContentState
        if let scorecard = dataSource?.scorecard {
            let isEmpty = tab.score(scorecard: scorecard) == 0
            state = isEmpty ? .empty : .data
        } else {
            state = dataSource?.contentState ?? .loading
        }
        collectionView.set(message: state)
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

    /// Injected dependencies
    typealias Model = (list: Checklist,
                       user: User,
                       tab: UserCountsVC.Tab)

    /// Handle dependency injection
    ///
    /// - Parameter model: Dependencies
    /// - Returns: Chainable self
    @discardableResult func inject(model: Model) -> Self {
        return self
    }

    /// Enforce dependency injection
    func requireInjections() { }
}

extension UserCountsVC.Tab {

    func title(status: Checklist.VisitStatus) -> String {
        switch self {
        case .visited:
            return L.visitedCount(status.visited)
        case .remaining:
            return L.remainingCount(status.remaining)
       }
    }

    func score(status: Checklist.VisitStatus) -> Int {
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
