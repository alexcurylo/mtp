// @copyright Trollwerks Inc.

@testable import MTP
import UserNotifications
import XCTest

final class NotificationServiceTests: TestCase {

    func testService() throws {
        // given
        let item: Checklist.Item = (.locations, 0)
        let mappable = Mappable()
        let sut = NotificationServiceImpl()
        let expected = "Could not test - your device appears to be offline. Please connect to the Internet."

        // when
        let called = expectation(description: "called")
        sut.authorizeNotifications { _ in called.fulfill() }
        sut.set(item: item,
                visited: true) { _ in }
        sut.set(items: [item],
                visited: true) { _ in }
        sut.ask(question: "test") { _ in }
        sut.checkPending()
        sut.notify(mappable: mappable,
                   triggered: Date()) { _ in }
        sut.congratulate(item: item)
        sut.congratulate(mappable: mappable)
        sut.postInfo(title: nil, body: nil)
        sut.postVisit(title: "test", body: "test", info: [:])
        sut.post(error: "test")
        sut.background { }
        sut.post(title: "test",
                 subtitle: "test",
                 body: "test",
                 category: "test",
                 info: [:])
        sut.modal(success: "test")
        sut.modal(info: "test")
        sut.modal(error: "test")
        let failure = sut.modal(failure: .deviceOffline, operation: "test")
        sut.dismissModal()
        sut.message(error: "test")
        sut.unimplemented()

        // then
        waitForExpectations(timeout: 1, handler: nil)
        failure.assert(equal: expected)
    }
}
