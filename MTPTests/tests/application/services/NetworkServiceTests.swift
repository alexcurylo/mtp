// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class NetworkServiceTests: MTPTestCase {

    func testService() {
        // given
        let spy = MTPNetworkControllerSpy()
        let query = RankingsQuery()
        (spy.data as? DataServiceSpy)?.stubbedLastRankingsQuery = query
        let sut = NetworkServiceImpl(controller: spy)
        let register = RegistrationPayload(facebook: [:])

        // when
        sut.loadPhotos(location: 1, reload: true) { _ in }
        sut.loadPhotos(page: 1, reload: true) { _ in }
        sut.loadPhotos(profile: 1, page: 1, reload: true) { _ in }
        sut.loadPosts(location: 1) { _ in }
        sut.loadPosts(user: 1) { _ in }
        sut.loadRankings(query: query) { _ in }
        sut.loadScorecard(list: .locations, user: 1) { _ in }
        sut.loadUser(id: 1) { _ in }
        sut.search(query: "query") { _ in }
        sut.userDeleteAccount { _ in }
        sut.userForgotPassword(email: "test@test.com") { _ in }
        sut.userLogin(email: "test@test.com", password: "test") { _ in }
        sut.userRegister(payload: register) { _ in }
        sut.userUpdate(payload: UserUpdatePayload()) { _ in }
        sut.userUpdate(token: "token") { _ in }
        sut.userVerify(id: 1) { _ in }
        sut.logout()
        sut.refreshEverything()
        // sort to deal with offline queue
        //sut.set(items: [], visited: true) { _ in }
        //sut.postPublish(payload: PostPayload()) { _ in }
        //sut.upload(photo: Data(), caption: nil, location: nil) { _ in }
        //sut.userUpdate(payload: UserUpdatePayload()) { _ in }

        // then
        XCTAssertTrue(spy.invokedLoadPhotosLocation)
        XCTAssertTrue(spy.invokedLoadPhotosPage)
        XCTAssertTrue(spy.invokedLoadPhotosProfile)
        XCTAssertTrue(spy.invokedLoadPostsLocation)
        XCTAssertTrue(spy.invokedLoadPostsUser)
        XCTAssertTrue(spy.invokedLoadRankings)
        XCTAssertTrue(spy.invokedLoadScorecard)
        XCTAssertTrue(spy.invokedLoadUser)
        XCTAssertTrue(spy.invokedSearch)
        //XCTAssertTrue(spy.invokedSet)
        //XCTAssertTrue(spy.invokedUpload)
        //XCTAssertTrue(spy.invokedPostPublish)
        XCTAssertTrue(spy.invokedUserDeleteAccount)
        XCTAssertTrue(spy.invokedUserForgotPassword)
        XCTAssertTrue(spy.invokedUserLogin)
        XCTAssertTrue(spy.invokedUserRegister)
        //XCTAssertTrue(spy.invokedUserUpdatePayload)
        XCTAssertTrue(spy.invokedUserUpdateToken)
        XCTAssertTrue(spy.invokedUserVerify)
        //XCTAssertTrue(spy.invokedLoadSettings)
        //XCTAssertTrue(spy.invokedLoadChecklists)
        //XCTAssertTrue(spy.invokedSearchCountries)
        //XCTAssertTrue(spy.invokedLoadLocations)
        //XCTAssertTrue(spy.invokedLoadBeaches)
        //XCTAssertTrue(spy.invokedLoadDiveSites)
        //XCTAssertTrue(spy.invokedLoadGolfCourses)
        //XCTAssertTrue(spy.invokedLoadRestaurants)
        //XCTAssertTrue(spy.invokedLoadUNCountries)
        //XCTAssertTrue(spy.invokedLoadWHS)
   }
}
