// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class PhotosVCTests: TestCase {

    func testInitStoryboard() throws {
        // given
        let loaded = R.storyboard.profilePhotos().instantiateInitialViewController()

        // when
        let sut = try XCTUnwrap(loaded as? ProfilePhotosVC)

        // then
        XCTAssertNotNil(sut)
    }
}
