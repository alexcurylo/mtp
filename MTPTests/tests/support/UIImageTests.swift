// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class UIImageTests: MTPTestCase {

    func testRoundedImage() {
        // given
        let size = CGSize(width: 100, height: 100)

        // when
        let colored = UIImage.image(color: .white, size: size)
        let rounded = colored?.rounded(cornerRadius: 5)

        // then
        XCTAssertNotNil(colored)
        XCTAssertNotNil(rounded)
    }
}
