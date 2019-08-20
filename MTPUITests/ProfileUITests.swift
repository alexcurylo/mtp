// @copyright Trollwerks Inc.

import XCTest

final class ProfileUITests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testMyProfile() {
        launch(settings: [.loggedIn(true)])

        UIMain.myProfile.tap()
        UIMain.myProfile.wait(for: .selected)

        UIProfileAbout.visited.tap()

        UICountsPage.region(0).tap()
        UICountsPage.group(0, 1).tap()

        UIUserCounts.close.tap()

        UIProfilePaging.counts.tap()

        UIMyCountsPaging.page(.uncountries).tap()
        UIMyCountsPaging.page(.whss).tap()
        UIMyCountsPaging.page(.beaches).tap()
        UIMyCountsPaging.page(.golfcourses).tap()
        UIMyCountsPaging.page(.divesites).tap()
        UIMyCountsPaging.page(.restaurants).tap()

        UICountsPage.region(1).tap()
        UICountsPage.toggle(1, 0).tap()

        UIProfilePaging.photos.tap()

        UIPhotos.add.tap()

        UIAddPhoto.close.tap()

        UIProfilePaging.posts.tap()

        UIPosts.add.tap()

        UIAddPost.close.tap()

        UIProfilePaging.about.tap()

        UIMyProfile.settings.tap()

        UISettings.faq.tap()

        UIFaq.close.tap()

        UISettings.about.tap()

        UIAppAbout.close.tap()

        UISettings.close.tap()
    }

    func testEditProfile() {
        launch(settings: [.loggedIn(true)])

        UIMain.myProfile.tap()
        UIMain.myProfile.wait(for: .selected)

        UIMyProfile.edit.tap()

        UIEditProfile.country.tap()

        UILocationSearch.close.tap()

        UIEditProfile.country.tap()

        UILocationSearch.item(0).tap()

        UIEditProfile.country.tap()

        //UILocationSearch.search.tap()
        //UILocationSearch.cancel.tap()
        //UILocationSearch.search.tap()
        //UILocationSearch.search.type(text: "North")

        UILocationSearch.item(0).tap()

        UIEditProfile.close.tap()
    }
}
