// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class CellFactoryTests: XCTestCase {

    func testReuseIdentifier() {
        XCTAssertEqual(TestCellFactory.reuseIdentifier, "TestCellFactory")
    }

    func testSuitable() {
        let concreteFactory = TestCellFactory.self
        let factory = CellFactory(concreteFactory)
        XCTAssertTrue(factory.suitable(for: ""))
    }

    func testConfigure() {
        let concreteFactory = TestCellFactory.self
        let factory = CellFactory(concreteFactory)
        let cell = UITableViewCell()
        let indexPath = IndexPath(row: 0, section: 0)
        _ = factory.configure(cell,
                              with: "test",
                              for: indexPath,
                              eventHandler: "Handler")
        XCTAssertTrue(concreteFactory.cell === cell)
        XCTAssertEqual(concreteFactory.item, "test")
        XCTAssertEqual(concreteFactory.indexPath, indexPath)
        XCTAssertEqual(concreteFactory.eventHandler, "Handler")
    }

    func testDequeueCell() {
        let concreteFactory = TestCellFactory.self
        let factory = CellFactory(concreteFactory)
        let tableView = UITableView()
        tableView.register(with: factory)
        let indexPath = IndexPath(row: 0, section: 0)
        let cell: UITableViewCell = tableView.dequeueCell(to: "Item",
                                                          from: [factory],
                                                          for: indexPath,
                                                          eventHandler: "EventHandler")
        XCTAssertTrue(concreteFactory.cell === cell)
        XCTAssertEqual(concreteFactory.item, "Item")
        XCTAssertEqual(concreteFactory.indexPath, indexPath)
        XCTAssertEqual(concreteFactory.eventHandler, "EventHandler")
    }
}

private class TestCellFactory: CellFactoryProtocol {

    static var cell: UITableViewCell?
    static var item: String?
    static var indexPath: IndexPath?
    static var eventHandler: String?

    static func configure(_ cell: UITableViewCell,
                          with item: String,
                          for indexPath: IndexPath,
                          eventHandler: String?) {
        self.cell = cell
        self.item = item
        self.indexPath = indexPath
        self.eventHandler = eventHandler
    }
}
