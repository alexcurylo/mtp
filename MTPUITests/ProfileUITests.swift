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

        UICountsPage.section(0).tap()
        UICountsPage.group(0, 1).tap()

        UIUserCountsPaging.remaining.tap()

        UIUserCounts.close.tap()

        UIProfileAbout.remaining.tap()

        UIUserCountsPaging.visited.tap()

        UIUserCounts.close.tap()

        UIProfilePaging.counts.tap()

        UIMyCountsPaging.page(.uncountries).tap()
        UIMyCountsPaging.page(.whss).tap()
        UIMyCountsPaging.page(.beaches).tap()
        UIMyCountsPaging.page(.golfcourses).tap()
        UIMyCountsPaging.page(.divesites).tap()
        UIMyCountsPaging.page(.restaurants).tap()
        UIMyCountsPaging.page(.hotels).tap()

        UICountsPage.brand.tap()
        UICountsPage.section(1).tap()
        UICountsPage.group(0, 0).tap()
        UICountsPage.group(0, 1).tap()
        UICountsPage.toggle(0, 2).tap()

        UISystem.button("OK").tap()

        UIProfilePaging.photos.tap()

        /* switch to Edit + Delete here, move this to locations
        UIPhotos.photo(0).showMenu()

        UISystem.menu("Hide").tap()

        UIPhotos.photo(0).showMenu()

        UISystem.menu("Report").tap()
        UISystem.button("Settings").tap()

        UISettings.close.tap()

        UIProfilePaging.photos.tap()

        UIPhotos.photo(0).showMenu()

        UISystem.menu("Block user").tap()

        UISystem.button("OK").tap()
         */
        UIPhotos.add.tap()

        UIAddPhoto.close.tap()

        UIProfilePaging.posts.tap()

        /* switch to Edit + Delete here, move this to locations
        UIPosts.post(0).showMenu()

        UISystem.menu("Hide").tap()

        UIPosts.post(0).showMenu()

        UISystem.menu("Report").tap()
        UISystem.button("Settings").tap()

        UISettings.close.tap()

        UIProfilePaging.posts.tap()

        UIPosts.post(0).showMenu()

        UISystem.menu("Block user").tap()

        UISystem.button("OK").tap()
         */

        UIPosts.add.tap()

        UIAddPost.close.tap()

        UIProfilePaging.about.tap()

        /* crashes on tap with Xcode 11.1?
        UIMyProfile.settings.tap()

        UISettings.faq.tap()

        UIFaq.close.tap()

        UISettings.about.tap()

        UIAppAbout.close.tap()

        UISettings.network.tap()

        UINetwork.close.tap()

        UISettings.close.tap()
         */
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

        UIEditProfile.avatar.tap()

        UIPhotos.photo(0).tap()
        UIPhotos.save.tap()

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
