// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class CountCellGroupTests: TestCase {

    func testInit() {
        // given
        let sut = CountCellGroup()
        let model = CountGroupModel(section: "region",
                                    group: "country",
                                    subgroup: nil,
                                    visited: 5,
                                    count: 10,
                                    disclose: .close,
                                    isLast: false,
                                    path: IndexPath(row: 0,
                                                    section: 0))

        // when
        sut.inject(model: model)

        // then
        XCTAssertNil(sut.delegate)
    }

    func testInitWithCoder() {
        // when
        let sut = CountCellGroup(coder: NSCoder())

        // then
        XCTAssertNil(sut)
    }
}
