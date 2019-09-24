// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class AttachmentItemTests: XCTestCase {

    func testAttached() throws {
        var item = AttachmentItem(isHidden: false)
        XCTAssertFalse(item.attached)

        item.media = .image(try XCTUnwrap(UIImage(color: .red)))
        XCTAssertTrue(item.attached)

        item.media = .video(try XCTUnwrap(UIImage(color: .red)),
                            try XCTUnwrap(URL(string: "https://example.com")))
        XCTAssertTrue(item.attached)
    }

    func testImage() throws {
        var item = AttachmentItem(isHidden: false)
        XCTAssertNil(item.image)

        let image = try XCTUnwrap(UIImage(color: .red))
        item.media = .image(image)
        XCTAssertNotNil(item.image)
        XCTAssertTrue(item.image === image)

        item.media = .video(image, try XCTUnwrap(URL(string: "https://example.com")))
        XCTAssertNotNil(item.image)
        XCTAssertTrue(item.image === image)
    }
}
