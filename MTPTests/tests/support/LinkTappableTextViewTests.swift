// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class LinkTappableTextViewTests: XCTestCase {

    func testInitWithCoder() {
        // when
        let sut = LinkTappableTextView(coder: NSCoder())
        // then
        XCTAssertNil(sut)
    }

    func testHitNothing() {
        // given
        let sut = LinkTappableTextView(frame: .zero,
                                       textContainer: nil)

        // when
        let result = sut.hitTest(.zero, with: nil)

        // then
        XCTAssertNil(result)
    }

    func testHitSomething() {
        // given
        let sut = LinkTappableTextView(frame: .zero,
                                       textContainer: nil)
        let attributes = [NSAttributedString.Key.link: "http://mtp.travel"]
        let text = NSAttributedString(string: "link", attributes: attributes)
        sut.attributedText = text

        // when
        let result = sut.hitTest(.zero, with: nil)

        // then
        XCTAssertEqual(sut, result)
    }
}
