// @copyright Trollwerks Inc.

import UIKit

/// Adopt to provide scorecard and content state
protocol UserCountsPageDataSource: AnyObject {

    /// Scorecard to display
    var scorecard: Scorecard? { get }
    /// Content state to display
    var contentState: ContentState { get }
}

/// Displays user visit counts
final class UserCountsPageVC: CountsPageVC {

    /// Data source for content
    weak var dataSource: UserCountsPageDataSource? {
        didSet { refresh() }
    }

    /// Places to display
    override var places: [PlaceInfo] { return listPlaces }
    /// Places that have been visited
    override var visited: [Int] { return listVisited }

    private var listPlaces: [PlaceInfo] = []
    private var listVisited: [Int] = []
    private let tab: UserCountsVC.Tab
    private let user: User
    private var status: Checklist.VisitStatus

    /// Construction by injection
    ///
    /// - Parameter model: Injected model
    init(model: Model) {
        tab = model.tab
        user = model.user
        status = model.list.visitStatus(of: user)

        super.init(model: model.list)
    }

    /// Unsupported coding constructor
    ///
    /// - Parameter coder: An unarchiver object.
    required init?(coder: NSCoder) {
        return nil
    }

    /// Rebuild data and update
    func refresh() {
        cache()
        update()
    }

    /// Update UI state
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

// MARK: - Private

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

// MARK: - Injectable

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

    /// Provide title from status
    ///
    /// - Parameter status: Visit counts
    /// - Returns: Formatted string
    func title(status: Checklist.VisitStatus) -> String {
        switch self {
        case .visited:
            return L.visitedCount(status.visited)
        case .remaining:
            return L.remainingCount(status.remaining)
       }
    }

    /// Provide score for tab
    ///
    /// - Parameter status: Visit counts
    /// - Returns: Int
    func score(status: Checklist.VisitStatus) -> Int {
        switch self {
        case .visited:
            return status.visited
        case .remaining:
            return status.remaining
        }
    }

    /// Provide title from scorecard
    ///
    /// - Parameter scorecard: Scorecard
    /// - Returns: Formatted string
    func title(scorecard: Scorecard) -> String {
        switch self {
        case .visited:
            return L.visitedCount(scorecard.visited)
        case .remaining:
            return L.remainingCount(scorecard.remaining)
        }
    }

    /// Provide score for tab
    ///
    /// - Parameter scorecard: Scorecard
    /// - Returns: Int
    func score(scorecard: Scorecard) -> Int {
        switch self {
        case .visited:
            return scorecard.visited
        case .remaining:
            return scorecard.remaining
        }
    }
}
