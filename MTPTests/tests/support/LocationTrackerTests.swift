// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class LocationTrackerTests: MTPTestCase {

    func testAlert() {
        // given
        let sut = LocationTrackerSpy(nibName: nil, bundle: nil)

        // when
        sut.alertLocationAccessNeeded()

        // then
        XCTAssertTrue(sut.invokedPresent)
    }
}
