// @copyright Trollwerks Inc.

import XCTest

final class ProfileUITests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testProfile() {
        launch(settings: [.loggedIn(true)])

        UIMain.myProfile.tap()
        UIMain.myProfile.wait(for: .selected)

        UIProfileAbout.visited.tap()

        UICountsPage.region(0).tap()
        UICountsPage.group(0, 1).tap()

        UIUserCounts.close.tap()

        UIProfilePaging.counts.tap()

        UIMyCountsPaging.page(.whss).tap()
        UIMyCountsPaging.page(.uncountries).tap()

        UIProfilePaging.photos.tap()

        UIPhotos.add.tap()

        UIAddPhoto.close.tap()

        UIProfilePaging.posts.tap()

        UIPosts.add.tap()

        UIAddPost.close.tap()

        UIProfilePaging.about.tap()

        UIMyProfile.edit.tap()

        UIEditProfile.country.tap()

        UILocationSearch.close.tap()

        UIEditProfile.close.tap()

        UIMyProfile.settings.tap()

        UISettings.faq.tap()

        UIFaq.close.tap()

        UISettings.about.tap()

        UIAppAbout.close.tap()

        UISettings.close.tap()
    }
}
