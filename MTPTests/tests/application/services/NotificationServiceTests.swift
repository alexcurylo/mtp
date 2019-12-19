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

    func testCheckinStrings() throws {
        // given
        let visiting = "A Place"
        let sut = NotificationServiceImpl()
        // swiftlint:disable:next closure_body_length
        Checklist.allCases.forEach { list in
            let map = MappableStub()
            map.stubbedChecklist = list
            map.stubbedTitle = visiting
            let title = L.checkinTitle(list.category(full: true))

            // when
            map.stubbedIsHere = true
            let now = sut.checkinStrings(mappable: map,
                                         triggered: Date())
            map.stubbedIsHere = false
            let when = Date() - 120
            let past = sut.checkinStrings(mappable: map,
                                          triggered: when)
            let time = when.relative

            // then
            XCTAssertEqual(now.0, title)
            let nowMessage = list == .locations
                ? L.checkinInsideNow(visiting)
                : L.checkinNearNow(visiting)
            XCTAssertEqual(now.1, nowMessage)

            XCTAssertEqual(past.0, title)
            let pastMessage = list == .locations
                ? L.checkinInsidePast(visiting, time)
                : L.checkinNearPast(visiting, time)
            XCTAssertEqual(past.1, pastMessage)
        }
    }
}
