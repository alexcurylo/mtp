// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class ApplicationServiceTests: XCTestCase {

    func testService() throws {
        // given
        let sut = UIApplication.shared
        let url = try unwrap(URL(string: "test"))
        let mappable = Mappable()
        let loaded = R.storyboard.main().instantiateInitialViewController()
        let tbc = try unwrap(loaded as? MainTBC)

        // when
        sut.launch(url: url)
        sut.route(reveal: mappable)
        sut.route(show: mappable)
        sut.endEditing()
        sut.dismissPresentations()
        StringKey.configureSettingsDisplay()
        let version = sut.version
        tbc.inject(model: .locations)
        let window = show(root: tbc)
        sut.route(to: .rankings)
        sut.route(to: .myProfile)
        sut.route(to: .editProfile)
        sut.route(to: .reportContent("test"))
        hide(window: window)

        // then
        XCTAssertFalse(version.isEmpty)
    }
}
