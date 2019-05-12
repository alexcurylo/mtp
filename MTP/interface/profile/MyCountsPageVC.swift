// @copyright Trollwerks Inc.

import UIKit

protocol MyCountsPageVCDelegate: AnyObject {

    func didScroll(myCountsPageVC: MyCountsPageVC)
}

final class MyCountsPageVC: CountsPageVC {

    private weak var delegate: MyCountsPageVCDelegate?

    override var isEditable: Bool { return true }
    override var places: [PlaceInfo] { return list.places }
    override var visited: [Int] { return list.visited }

    private var visitedObserver: Observer?
    private var placesObserver: Observer?

    init(model: Model) {
        delegate = model.delegate
        super.init(model: model.list)
    }

    override func observe() {
        super.observe()

        placesObserver = list.observer { [weak self] _ in
            self?.update()
        }

        guard visitedObserver == nil else { return }

        visitedObserver = data.observer(of: .visited) { [weak self] _ in
            self?.update()
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
