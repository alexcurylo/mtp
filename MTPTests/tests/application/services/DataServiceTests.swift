// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class DataServiceTests: TestCase {

    func testStub() throws {
        // given
        let sut = DataServiceStub()

        // when
        let etags = sut.etags

        // then
        XCTAssertTrue(etags.isEmpty)
    }
}
