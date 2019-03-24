// @copyright Trollwerks Inc.

import Anchorage
import Parchment

protocol MyCountsPageVCDelegate: AnyObject {

    func didScroll(myCountsPageVC: MyCountsPageVC)
}

final class MyCountsPageVC: CountsPageVC {

    private weak var delegate: MyCountsPageVCDelegate?

    init(model: Model,
         delegate: MyCountsPageVCDelegate? = nil) {
        super.init(model: model)

        self.delegate = delegate
    }
}

// MARK: - UIScrollViewDelegate

extension MyCountsPageVC {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.didScroll(myCountsPageVC: self)
    }
}
