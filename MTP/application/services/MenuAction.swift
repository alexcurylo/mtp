// @copyright Trollwerks Inc.

import UIKit

/// Actions that can be shown in popup menus
enum MenuAction: String {

    /// Hide triggering content
    case hide = "menuHide:"
    /// Report triggering content
    case report = "menuReport:"
    /// Block triggering user
    case block = "menuBlock:"

    /// Edit content
    case edit = "menuEdit:"
    /// Delete content
    case delete = "menuDelete:"

    /// Actions for dealing with UGC as per Apple's requirements
    static let theirItems = [
        UIMenuItem(title: L.menuHide(), action: MenuAction.hide.selector()),
        UIMenuItem(title: L.menuReport(), action: MenuAction.report.selector()),
        UIMenuItem(title: L.menuBlock(), action: MenuAction.block.selector())
    ]
    /// Actions for editing our own content
    static let myItems = [
        UIMenuItem(title: L.menuEdit(), action: MenuAction.edit.selector()),
        UIMenuItem(title: L.menuDelete(), action: MenuAction.delete.selector())
    ]

    /// Is a menu action one of our content actions?
    ///
    /// - Parameter action: Action selector
    /// - Returns: Whether it is a content action
    static func isContent(action: Selector) -> Bool {
        switch action {
        case MenuAction.block.selector(),
             MenuAction.hide.selector(),
             MenuAction.report.selector(),
             MenuAction.edit.selector(),
             MenuAction.delete.selector():
            return true
        default:
            return false
        }
    }

    private func selector() -> Selector {
        return Selector(self.rawValue)
    }
}
