// @copyright Trollwerks Inc.

import UIKit

extension UITableView {

    // suppress annoying redraw, especially in static tables
    func update(layout: () -> Void = {}) {
        UIView.setAnimationsEnabled(false)
        beginUpdates()

        layout()

        endUpdates()
        UIView.setAnimationsEnabled(true)
    }
}
