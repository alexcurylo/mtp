// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class BodyCellTests: XCTestCase {

    func testEventHandling() {
        let cell = BodyCell(style: .default, reuseIdentifier: BodyCell.reuseIdentifier)
        let item = BodyItem(bodyText: "test")
        let handler = MockBodyCellEventHandler()
        let indexPath = IndexPath(row: 0, section: 0)
        BodyCell.configure(cell, with: item, for: indexPath, eventHandler: handler)
        cell.textViewDidChange(cell.textView)
        XCTAssertTrue(handler.invokedBodyCellHeightChanged)
        XCTAssertEqual(handler.invokedBodyTextDidChangeParameters?.text, "test")
    }
}

private class MockBodyCellEventHandler: BodyCellEventProtocol {

    var invokedBodyCellHeightChanged = false
    var invokedBodyCellHeightChangedCount = 0

    func bodyCellHeightChanged() {
        invokedBodyCellHeightChanged = true
        invokedBodyCellHeightChangedCount += 1
    }

    var invokedBodyTextDidChange = false
    var invokedBodyTextDidChangeCount = 0
    var invokedBodyTextDidChangeParameters: (text: String?, Void)?
    var invokedBodyTextDidChangeParametersList = [(text: String?, Void)]()

    func bodyTextDidChange(_ text: String?) {
        invokedBodyTextDidChange = true
        invokedBodyTextDidChangeCount += 1
        invokedBodyTextDidChangeParameters = (text, ())
        invokedBodyTextDidChangeParametersList.append((text, ()))
    }
}
