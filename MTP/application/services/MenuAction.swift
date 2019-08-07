// @copyright Trollwerks Inc.

import UIKit

/// Actions that can be shown in popup menus
enum MenuAction: String {

    /// Hide triggering content
    case hide = "hide:"
    /// Report triggering content
    case report = "report:"
    /// Block triggering user
    case block = "block:"

    /// Actions for dealing with UGC as per Apple's requirements
    static let contentItems = [
        UIMenuItem(title: L.menuHide(), action: MenuAction.hide.selector()),
        UIMenuItem(title: L.menuReport(), action: MenuAction.report.selector()),
        UIMenuItem(title: L.menuBlock(), action: MenuAction.block.selector())
    ]

    /// Is a menu action one of our content actions?
    ///
    /// - Parameter action: Action selector
    /// - Returns: Whether it is a content action
    static func isContent(action: Selector) -> Bool {
        switch action {
        case MenuAction.block.selector(),
             MenuAction.hide.selector(),
             MenuAction.report.selector():
            return true
        default:
        return false
        }
    }

    private func selector() -> Selector {
        return Selector(self.rawValue)
    }
}
