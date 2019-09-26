// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class UserEmailCellTests: XCTestCase {

    func testHandleTextDidChange() {
        let cell = UserEmailCell(style: .default,
                                 reuseIdentifier: UserEmailCell.reuseIdentifier)
        let item = UserEmailItem(isHidden: false)
        let indexPath = IndexPath(row: 0, section: 0)
        let handler = MockUserEmailCellEventHandler()

        UserEmailCell.configure(cell,
                                with: item,
                                for: indexPath,
                                eventHandler: handler)
        cell.textField.text = "test"
        _ = cell.textField(cell.textField,
                           shouldChangeCharactersIn: NSRange(location: 0, length: 4),
                           replacementString: "")
        XCTAssertEqual(handler.invokedUserEmailTextDidChangeParameters?.text, "test")
    }
}

private class MockUserEmailCellEventHandler: UserEmailCellEventProtocol {

    var invokedUserEmailTextDidChange = false
    var invokedUserEmailTextDidChangeCount = 0
    var invokedUserEmailTextDidChangeParameters: (text: String?, Void)?
    var invokedUserEmailTextDidChangeParametersList = [(text: String?, Void)]()

    func userEmailTextDidChange(_ text: String?) {
        invokedUserEmailTextDidChange = true
        invokedUserEmailTextDidChangeCount += 1
        invokedUserEmailTextDidChangeParameters = (text, ())
        invokedUserEmailTextDidChangeParametersList.append((text, ()))
    }
}
