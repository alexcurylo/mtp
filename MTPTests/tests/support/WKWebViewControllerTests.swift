// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class WKWebViewControllerTests: MTPTestCase {

    func testInit() throws {
        let sut = WKWebViewController()

        // when
        let showing = show(nav: sut)
        sut.pureUserAgent = nil
        sut.userAgent = nil
        sut.customUserAgent = nil
        sut.pureUserAgent = "test"
        sut.userAgent = "test2"
        sut.customUserAgent = "test3"
        sut.leftNavigationBarItemTypes = [.back,
                                          .forward,
                                          .reload,
                                          .stop]
        sut.rightNavigationBarItemTypes = [.done,
                                           .flexibleSpace,
                                           .reload,
                                           .custom(icon: nil,
                                                   title: "Test",
                                                   action: { _ in }),
                                           .activity]
        sut.goBackToFirstPage()
        hide(window: showing)

        // then
        XCTAssertNil(sut.source)
    }

    func testInitWithCoder() throws {
        // given
        let sut = try XCTUnwrap(WKWebViewController(coder: NSCoder.empty))
        let source = WKWebSource.string("test", base: nil)

        // when
        sut.source = source

        // then
        XCTAssertNil(source.url)
        XCTAssertNil(source.absoluteString)
        XCTAssertNil(source.remoteURL)
    }

    func testInitWithSource() throws {
        // given
        let url = try XCTUnwrap(URL(string: "file://test"))
        let source = WKWebSource.file(url, access: url)

        // when
        let sut = WKWebViewController(source: source)
        let showing = show(root: sut)
        hide(window: showing)

        // then
        XCTAssertEqual(source.url, url)
        XCTAssertEqual(source.absoluteString, url.absoluteString)
        XCTAssertNil(source.remoteURL)
    }

    func testInitWithUrl() throws {
        // given
        let url = try XCTUnwrap(URL(string: "http://mtp.travel"))

        // when
        let sut = WKWebViewController(url: url)

        // then
        let source = try XCTUnwrap(sut.source)
        XCTAssertEqual(source.url, url)
        XCTAssertEqual(source.absoluteString, url.absoluteString)
        XCTAssertEqual(source.remoteURL, url)
    }
}
