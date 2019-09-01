// @copyright Trollwerks Inc.

import XCTest

final class ProfileUITests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    //swiftlint:disable:next function_body_length
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

        UIPhotos.photo(0).showMenu()

        UISystem.menu("Hide").tap()

        UIPhotos.photo(0).showMenu()

        UISystem.menu("Report").tap()
        UISystem.button("OK").tap()

        UISettings.close.tap()

        UIProfilePaging.photos.tap()

        UIPhotos.photo(0).showMenu()

        UISystem.menu("Block user").tap()

        UISystem.button("OK").tap()

        UIPhotos.add.tap()

        UIAddPhoto.close.tap()

        UIProfilePaging.posts.tap()

        UIPosts.post(0).showMenu()

        UISystem.menu("Hide").tap()

        UIPosts.post(0).showMenu()

        UISystem.menu("Report").tap()
        UISystem.button("OK").tap()

        UISettings.close.tap()

        UIProfilePaging.posts.tap()

        UIPosts.post(0).showMenu()

        UISystem.menu("Block user").tap()

        UISystem.button("OK").tap()

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

        UIEditProfile.avatar.tap()

        UIPhotos.add.tap()

        UIAddPhoto.image.tap()

        // Camera Roll
        wait(for: 6)
        app.tap(x: 50, y: 200)
        // first picture
        wait(for: 2)
        app.tap(x: 50, y: 100)
        // Choose
        wait(for: 2)
        app.tap(x: -50, y: -20)

        UIAddPhoto.save.tap()

        UIProfilePhotos.close.tap()

        UIEditProfile.country.tap()

        UILocationSearch.close.tap()

        UIEditProfile.country.tap()

        let preferNot = 0
        UILocationSearch.result(preferNot).tap()

        UIEditProfile.country.tap()

        let antigua = 6
        UILocationSearch.result(antigua).tap()

        UIEditProfile.location.tap()

        let redonda = 2
        UILocationSearch.result(redonda).tap()

        UIEditProfile.country.tap()

        UILocationSearch.search.tap()
        UILocationSearch.cancel.tap()
        UILocationSearch.search.tap()
        UILocationSearch.search.type(text: "North")

        let northKorea = 0
        UILocationSearch.result(northKorea).tap()

        UIEditProfile.save.tap()
    }
}
