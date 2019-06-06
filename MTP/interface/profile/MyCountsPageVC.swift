// @copyright Trollwerks Inc.

import UIKit

protocol MyCountsPageVCDelegate: AnyObject {

    func didScroll(myCountsPageVC: MyCountsPageVC)
}

final class MyCountsPageVC: CountsPageVC {

    private weak var delegate: MyCountsPageVCDelegate?

    override var isEditable: Bool { return true }
    override var places: [PlaceInfo] { return listPlaces }
    override var visited: [Int] { return listVisited }

    private let listPlaces: [PlaceInfo]
    private var listVisited: [Int]

    private var visitedObserver: Observer?
    private var placesObserver: Observer?

    init(model: Model) {
        delegate = model.delegate
        listPlaces = model.list.places
        listVisited = model.list.visited
        super.init(model: model.list)
    }

    override func observe() {
        super.observe()

        placesObserver = list.observer { [weak self] _ in
            self?.update()
        }

        guard visitedObserver == nil else { return }

        visitedObserver = data.observer(of: .visited) { [weak self] _ in
            guard let self = self else { return }

            self.listVisited = self.list.visited
            self.update()
        }
    }
}

// MARK: - UIScrollViewDelegate

extension MyCountsPageVC {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.didScroll(myCountsPageVC: self)
    }
}

extension MyCountsPageVC: Injectable {

    typealias Model = (list: Checklist, delegate: MyCountsPageVCDelegate)

    @discardableResult func inject(model: Model) -> Self {
        return self
    }

    func requireInjections() {
    }
}
