// @copyright Trollwerks Inc.

// migrated from https://github.com/rizumita/CTFeedbackSwift

//
// Created by 和泉田 領一 on 2017/09/07.
// Copyright (c) 2017 CAPH TECH. All rights reserved.
//

import UIKit

/// CellFactoryProtocol
protocol CellFactoryProtocol {

    associatedtype Item
    associatedtype Cell: UITableViewCell
    associatedtype EventHandler

    /// reuse Identifier
    static var reuseIdentifier: String { get }

    /// Configure
    /// - Parameter cell: Cell
    /// - Parameter item: Item
    /// - Parameter indexPath: Index path
    /// - Parameter eventHandler: Event handler
    static func configure(_ cell: Cell,
                          with item: Item,
                          for indexPath: IndexPath,
                          eventHandler: EventHandler)
}

extension CellFactoryProtocol {

    /// Default reuseIdentifier
    static var reuseIdentifier: String { return String(describing: self) }

    /// Default suitable
    /// - Parameter item: Item
    static func suitable(for item: Any) -> Bool { return item is Item }

    /// Default configure
    /// - Parameter cell: Cell
    /// - Parameter item: Item
    /// - Parameter indexPath: Index path
    /// - Parameter eventHandler: Event handler
    static func configure(_ cell: UITableViewCell,
                          with item: Any,
                          for indexPath: IndexPath,
                          eventHandler: Any?) -> UITableViewCell? {
        guard let cell = cell as? Cell,
              let item = item as? Item,
              let eventHandler = eventHandler as? EventHandler
            else { return .none }
        configure(cell, with: item, for: indexPath, eventHandler: eventHandler)
        return cell
    }
}

/// CellFactory
final class CellFactory {

    fileprivate let cellType: AnyClass
    fileprivate let reuseIdentifier: String
    private let suitableClosure: (Any) -> Bool
    private let configureCellClosure: (UITableViewCell, Any, IndexPath, Any?) -> UITableViewCell?

    /// :nodoc:
    init<Factory: CellFactoryProtocol>(_ cellFactory: Factory.Type) {
        cellType = Factory.Cell.self
        reuseIdentifier = cellFactory.reuseIdentifier
        suitableClosure = cellFactory.suitable(for:)
        configureCellClosure = cellFactory.configure(_:with:for:eventHandler:)
    }

    /// Suitability
    /// - Parameter item: Item
    func suitable(for item: Any) -> Bool {
        return suitableClosure(item)
    }

    /// Configure
    /// - Parameter cell: Cell
    /// - Parameter item: Item
    /// - Parameter indexPath: Index path
    /// - Parameter eventHandler: Event handler
    func configure(_ cell: UITableViewCell,
                   with item: Any,
                   for indexPath: IndexPath,
                   eventHandler: Any?) -> UITableViewCell? {
        return configureCellClosure(cell, item, indexPath, eventHandler)
    }

    private static func cellFactoryFilter() -> (Any, [CellFactory]) -> CellFactory? {
        var cache = [String: CellFactory]()
        return { item, factories in
            let itemType = String(describing: type(of: item))
            if let factory = cache[itemType] {
                return factory
            } else if let factory = _cellFactoryFilter(item, factories) {
                cache[itemType] = factory
                return factory
            } else {
                return .none
            }
        }
    }
}

extension UITableView {

    /// Register
    /// - Parameter cellFactory: Factory
    func register(with cellFactory: CellFactory) {
        register(cellFactory.cellType, forCellReuseIdentifier: cellFactory.reuseIdentifier)
    }

    /// dequeueCell
    /// - Parameter item: Item
    /// - Parameter cellFactories: Factories
    /// - Parameter indexPath: Index path
    /// - Parameter filter: Filter
    /// - Parameter eventHandler: Handler
    func dequeueCell(to item: Any,
                     from cellFactories: [CellFactory],
                     for indexPath: IndexPath,
                     filter: (Any, [CellFactory]) -> CellFactory? = _cellFactoryFilter,
                     eventHandler: Any?) -> UITableViewCell {
        guard let cellFactory = filter(item, cellFactories) else {
            fatalError("dequeueCell")
        }
        let cell = dequeueReusableCell(withIdentifier: cellFactory.reuseIdentifier, for: indexPath)
        guard let configured = cellFactory.configure(cell,
                                                     with: item,
                                                     for: indexPath,
                                                     eventHandler: eventHandler)
            else { fatalError("Configuration failure") }
        return configured
    }
}

private let _cellFactoryFilter: (Any, [CellFactory]) -> CellFactory? = { item, factories in
    factories.first { $0.suitable(for: item) }
}
