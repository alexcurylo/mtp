// @copyright Trollwerks Inc.

import UIKit

/// Exposes an item to UI tests
/// Intended as base class for screen based enums
protocol Exposable {

    /// Defaults to Type.self
    var identifier: String { get }
}

extension Exposable {

    /// accessibilityIdentifier for UI tests
    var identifier: String {
        return "\(String(describing: type(of: self))).\(self)"
    }

    /// Assign accessibility identifier to item
    ///
    /// - Parameter item: Thing to expose
    func expose(item: UIAccessibilityIdentification?) {
        guard let item = item else { return }
        item.accessibilityIdentifier = identifier
    }
}

extension UIAccessibilityIdentification {

    /// Assign accessibility identifier to ourselves
    ///
    /// - Parameter exposable: Identifier provider
    func expose(as exposable: Exposable?) {
        guard let identifier = exposable?.identifier else { return }
        accessibilityIdentifier = identifier
    }
}

/// Tagging protocol for view controllers
protocol Exposing {

    /// Conventional call for exposing selected UI once created
    func expose()
}

/// Tagging protocol for collection data sources
protocol CollectionCellExposing: AnyObject {

    /// Conventional call for exposing cell once created
    ///
    /// - Parameters:
    ///   - view: Container
    ///   - path: Will be encoded in accessibility identifier
    ///   - cell: Cell to expose
    func expose(view: UICollectionView,
                path: IndexPath,
                cell: UICollectionViewCell)
}

/// Tagging protocol for table data sources
protocol TableCellExposing: AnyObject {

    /// Conventional call for exposing cell once created
    ///
    /// - Parameters:
    ///   - view: Container
    ///   - path: Will be encoded in accessibility identifier
    ///   - cell: Cell to expose
    func expose(view: UITableView,
                path: IndexPath,
                cell: UITableViewCell)
}

/// Enhance readability
typealias Rank = Int

/// Mapping to bridge Checklist with UI tests' identifiers
enum ChecklistIndex: Int, CustomStringConvertible {

    /// Checklist .locations as 0
    case locations
    /// Checklist .uncountries as 1
    case uncountries
    /// Checklist .whss as 2
    case whss
    /// Checklist .beaches as 3
    case beaches
    /// Checklist .golfcourses as 4
    case golfcourses
    /// Checklist .divesites as 5
    case divesites
    /// Checklist .restaurants as 6
    case restaurants

    var description: String {
        return "\(rawValue)"
    }
}
