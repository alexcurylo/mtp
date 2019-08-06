// @copyright Trollwerks Inc.

import UIKit

extension UITableView {

    /// Suppress annoying redraw, especially in static tables
    ///
    /// - Returns: nothing
    func update(layout: () -> Void = {}) {
        UIView.setAnimationsEnabled(false)
        beginUpdates()

        layout()

        endUpdates()
        UIView.setAnimationsEnabled(true)
    }
}
