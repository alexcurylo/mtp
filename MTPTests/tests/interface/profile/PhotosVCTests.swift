// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class PhotosVCTests: XCTestCase {

    func testInitStoryboard() throws {
        // given
        let loaded = R.storyboard.profilePhotos().instantiateInitialViewController()

        // when
        let sut = try unwrap(loaded as? ProfilePhotosVC)

        // then
        XCTAssertNotNil(sut)
    }
}
