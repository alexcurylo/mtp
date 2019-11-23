// @copyright Trollwerks Inc.

import UIKit

/// Notifies of scroll for menu updating
protocol MyCountsPageVCDelegate: AnyObject {

    /// Scroll notification
    ///
    /// - Parameter rankingsPageVC: Scrollee
    func didScroll(myCountsPageVC: MyCountsPageVC)
}

/// Displays logged in user visit counts
final class MyCountsPageVC: CountsPageVC {

    /// Injected dependencies
    typealias Model = (list: Checklist,
                       delegate: MyCountsPageVCDelegate)

    private weak var delegate: MyCountsPageVCDelegate?

    /// Whether counts are editable
    override var isEditable: Bool { return true }
    /// Places to display
    override var places: [PlaceInfo] { return listPlaces }
    /// Places that have been visited
    override var visited: [Int] { return listVisited }

    private let listPlaces: [PlaceInfo]
    private var listVisited: [Int]

    private var visitedObserver: Observer?
    private var placesObserver: Observer?

    /// Construction by injection
    ///
    /// - Parameter model: Injected model
    init(model: Model) {
        delegate = model.delegate
        listPlaces = model.list.places
        listVisited = model.list.visited
        super.init(model: model.list)
    }

    /// :nodoc:
    required init?(coder: NSCoder) {
        return nil
    }

    /// Set up data change observations
    override func observe() {
        super.observe()

        placesObserver = checklist.observer { [weak self] _ in
            self?.update()
        }

        guard visitedObserver == nil else { return }

        visitedObserver = data.observer(of: .visited) { [weak self] _ in
            guard let self = self else { return }

            self.listVisited = self.checklist.visited
            self.update()
        }
    }
}

// MARK: - UIScrollViewDelegate

extension MyCountsPageVC {

    /// Scrolling notfication
    ///
    /// - Parameter scrollView: Scrollee
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.didScroll(myCountsPageVC: self)
    }
}
