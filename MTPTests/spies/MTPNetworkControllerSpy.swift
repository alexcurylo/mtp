// @copyright Trollwerks Inc.

import CoreLocation
@testable import MTP

// generated by https://github.com/seanhenry/SwiftMockGeneratorForXcode
// swiftlint:disable all

final class MTPNetworkControllerSpy: MTPNetworkController {
    var invokedSet = false
    var invokedSetCount = 0
    var invokedSetParameters: (items: [Checklist.Item], visited: Bool, stub: MTPProvider.StubClosure, then: NetworkCompletion<Bool>)?
    var invokedSetParametersList = [(items: [Checklist.Item], visited: Bool, stub: MTPProvider.StubClosure, then: NetworkCompletion<Bool>)]()
    override func set(items: [Checklist.Item],
    visited: Bool,
    stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
    then: @escaping NetworkCompletion<Bool>) {
        invokedSet = true
        invokedSetCount += 1
        invokedSetParameters = (items, visited, stub, then)
        invokedSetParametersList.append((items, visited, stub, then))
    }
    var invokedLoadBeaches = false
    var invokedLoadBeachesCount = 0
    var invokedLoadBeachesParameters: (then: NetworkCompletion<[PlaceJSON]>, Void)?
    var invokedLoadBeachesParametersList = [(then: NetworkCompletion<[PlaceJSON]>, Void)]()
    override func loadBeaches(then: @escaping NetworkCompletion<[PlaceJSON]> = { _ in }) {
        invokedLoadBeaches = true
        invokedLoadBeachesCount += 1
        invokedLoadBeachesParameters = (then, ())
        invokedLoadBeachesParametersList.append((then, ()))
    }
    var invokedLoadChecklists = false
    var invokedLoadChecklistsCount = 0
    var invokedLoadChecklistsParameters: (stub: MTPProvider.StubClosure, then: NetworkCompletion<Checked>)?
    var invokedLoadChecklistsParametersList = [(stub: MTPProvider.StubClosure, then: NetworkCompletion<Checked>)]()
    override func loadChecklists(stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
    then: @escaping NetworkCompletion<Checked> = { _ in }) {
        invokedLoadChecklists = true
        invokedLoadChecklistsCount += 1
        invokedLoadChecklistsParameters = (stub, then)
        invokedLoadChecklistsParametersList.append((stub, then))
    }
    var invokedLoadDiveSites = false
    var invokedLoadDiveSitesCount = 0
    var invokedLoadDiveSitesParameters: (then: NetworkCompletion<[PlaceJSON]>, Void)?
    var invokedLoadDiveSitesParametersList = [(then: NetworkCompletion<[PlaceJSON]>, Void)]()
    override func loadDiveSites(then: @escaping NetworkCompletion<[PlaceJSON]> = { _ in }) {
        invokedLoadDiveSites = true
        invokedLoadDiveSitesCount += 1
        invokedLoadDiveSitesParameters = (then, ())
        invokedLoadDiveSitesParametersList.append((then, ()))
    }
    var invokedLoadGolfCourses = false
    var invokedLoadGolfCoursesCount = 0
    var invokedLoadGolfCoursesParameters: (then: NetworkCompletion<[PlaceJSON]>, Void)?
    var invokedLoadGolfCoursesParametersList = [(then: NetworkCompletion<[PlaceJSON]>, Void)]()
    override func loadGolfCourses(then: @escaping NetworkCompletion<[PlaceJSON]> = { _ in }) {
        invokedLoadGolfCourses = true
        invokedLoadGolfCoursesCount += 1
        invokedLoadGolfCoursesParameters = (then, ())
        invokedLoadGolfCoursesParametersList.append((then, ()))
    }
    var invokedLoadLocations = false
    var invokedLoadLocationsCount = 0
    var invokedLoadLocationsParameters: (then: NetworkCompletion<[LocationJSON]>, Void)?
    var invokedLoadLocationsParametersList = [(then: NetworkCompletion<[LocationJSON]>, Void)]()
    override func loadLocations(then: @escaping NetworkCompletion<[LocationJSON]> = { _ in }) {
        invokedLoadLocations = true
        invokedLoadLocationsCount += 1
        invokedLoadLocationsParameters = (then, ())
        invokedLoadLocationsParametersList.append((then, ()))
    }
    var invokedLoadPhotosLocation = false
    var invokedLoadPhotosLocationCount = 0
    var invokedLoadPhotosLocationParameters: (id: Int, reload: Bool, stub: MTPProvider.StubClosure, then: NetworkCompletion<PhotosInfoJSON>)?
    var invokedLoadPhotosLocationParametersList = [(id: Int, reload: Bool, stub: MTPProvider.StubClosure, then: NetworkCompletion<PhotosInfoJSON>)]()
    override func loadPhotos(location id: Int,
    reload: Bool,
    stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
    then: @escaping NetworkCompletion<PhotosInfoJSON> = { _ in }) {
        invokedLoadPhotosLocation = true
        invokedLoadPhotosLocationCount += 1
        invokedLoadPhotosLocationParameters = (id, reload, stub, then)
        invokedLoadPhotosLocationParametersList.append((id, reload, stub, then))
    }
    var invokedLoadPhotosPage = false
    var invokedLoadPhotosPageCount = 0
    var invokedLoadPhotosPageParameters: (page: Int, reload: Bool, stub: MTPProvider.StubClosure, then: NetworkCompletion<PhotosPageInfoJSON>)?
    var invokedLoadPhotosPageParametersList = [(page: Int, reload: Bool, stub: MTPProvider.StubClosure, then: NetworkCompletion<PhotosPageInfoJSON>)]()
    override func loadPhotos(page: Int,
    reload: Bool,
    stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
    then: @escaping NetworkCompletion<PhotosPageInfoJSON> = { _ in }) {
        invokedLoadPhotosPage = true
        invokedLoadPhotosPageCount += 1
        invokedLoadPhotosPageParameters = (page, reload, stub, then)
        invokedLoadPhotosPageParametersList.append((page, reload, stub, then))
    }
    var invokedLoadPhotosProfile = false
    var invokedLoadPhotosProfileCount = 0
    var invokedLoadPhotosProfileParameters: (id: Int, page: Int, reload: Bool, stub: MTPProvider.StubClosure, then: NetworkCompletion<PhotosPageInfoJSON>)?
    var invokedLoadPhotosProfileParametersList = [(id: Int, page: Int, reload: Bool, stub: MTPProvider.StubClosure, then: NetworkCompletion<PhotosPageInfoJSON>)]()
    override func loadPhotos(profile id: Int,
    page: Int,
    reload: Bool,
    stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
    then: @escaping NetworkCompletion<PhotosPageInfoJSON> = { _ in }) {
        invokedLoadPhotosProfile = true
        invokedLoadPhotosProfileCount += 1
        invokedLoadPhotosProfileParameters = (id, page, reload, stub, then)
        invokedLoadPhotosProfileParametersList.append((id, page, reload, stub, then))
    }
    var invokedLoadPostsLocation = false
    var invokedLoadPostsLocationCount = 0
    var invokedLoadPostsLocationParameters: (id: Int, stub: MTPProvider.StubClosure, then: NetworkCompletion<PostsJSON>)?
    var invokedLoadPostsLocationParametersList = [(id: Int, stub: MTPProvider.StubClosure, then: NetworkCompletion<PostsJSON>)]()
    override func loadPosts(location id: Int,
    stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
    then: @escaping NetworkCompletion<PostsJSON> = { _ in }) {
        invokedLoadPostsLocation = true
        invokedLoadPostsLocationCount += 1
        invokedLoadPostsLocationParameters = (id, stub, then)
        invokedLoadPostsLocationParametersList.append((id, stub, then))
    }
    var invokedLoadPostsUser = false
    var invokedLoadPostsUserCount = 0
    var invokedLoadPostsUserParameters: (id: Int, stub: MTPProvider.StubClosure, then: NetworkCompletion<PostsJSON>)?
    var invokedLoadPostsUserParametersList = [(id: Int, stub: MTPProvider.StubClosure, then: NetworkCompletion<PostsJSON>)]()
    override func loadPosts(user id: Int,
    stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
    then: @escaping NetworkCompletion<PostsJSON> = { _ in }) {
        invokedLoadPostsUser = true
        invokedLoadPostsUserCount += 1
        invokedLoadPostsUserParameters = (id, stub, then)
        invokedLoadPostsUserParametersList.append((id, stub, then))
    }
    var invokedLoadRankings = false
    var invokedLoadRankingsCount = 0
    var invokedLoadRankingsParameters: (query: RankingsQuery, stub: MTPProvider.StubClosure, then: NetworkCompletion<RankingsPageInfoJSON>)?
    var invokedLoadRankingsParametersList = [(query: RankingsQuery, stub: MTPProvider.StubClosure, then: NetworkCompletion<RankingsPageInfoJSON>)]()
    override func loadRankings(query: RankingsQuery,
    stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
    then: @escaping NetworkCompletion<RankingsPageInfoJSON> = { _ in }) {
        invokedLoadRankings = true
        invokedLoadRankingsCount += 1
        invokedLoadRankingsParameters = (query, stub, then)
        invokedLoadRankingsParametersList.append((query, stub, then))
    }
    var invokedLoadRestaurants = false
    var invokedLoadRestaurantsCount = 0
    var invokedLoadRestaurantsParameters: (then: NetworkCompletion<[RestaurantJSON]>, Void)?
    var invokedLoadRestaurantsParametersList = [(then: NetworkCompletion<[RestaurantJSON]>, Void)]()
    override func loadRestaurants(then: @escaping NetworkCompletion<[RestaurantJSON]> = { _ in }) {
        invokedLoadRestaurants = true
        invokedLoadRestaurantsCount += 1
        invokedLoadRestaurantsParameters = (then, ())
        invokedLoadRestaurantsParametersList.append((then, ()))
    }
    var invokedLoadScorecard = false
    var invokedLoadScorecardCount = 0
    var invokedLoadScorecardParameters: (list: Checklist, id: Int, stub: MTPProvider.StubClosure, then: NetworkCompletion<ScorecardJSON>)?
    var invokedLoadScorecardParametersList = [(list: Checklist, id: Int, stub: MTPProvider.StubClosure, then: NetworkCompletion<ScorecardJSON>)]()
    override func loadScorecard(list: Checklist,
    user id: Int,
    stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
    then: @escaping NetworkCompletion<ScorecardJSON> = { _ in }) {
        invokedLoadScorecard = true
        invokedLoadScorecardCount += 1
        invokedLoadScorecardParameters = (list, id, stub, then)
        invokedLoadScorecardParametersList.append((list, id, stub, then))
    }
    var invokedLoadSettings = false
    var invokedLoadSettingsCount = 0
    var invokedLoadSettingsParameters: (then: NetworkCompletion<SettingsJSON>, Void)?
    var invokedLoadSettingsParametersList = [(then: NetworkCompletion<SettingsJSON>, Void)]()
    override func loadSettings(then: @escaping NetworkCompletion<SettingsJSON> = { _ in }) {
        invokedLoadSettings = true
        invokedLoadSettingsCount += 1
        invokedLoadSettingsParameters = (then, ())
        invokedLoadSettingsParametersList.append((then, ()))
    }
    var invokedLoadUNCountries = false
    var invokedLoadUNCountriesCount = 0
    var invokedLoadUNCountriesParameters: (then: NetworkCompletion<[LocationJSON]>, Void)?
    var invokedLoadUNCountriesParametersList = [(then: NetworkCompletion<[LocationJSON]>, Void)]()
    override func loadUNCountries(then: @escaping NetworkCompletion<[LocationJSON]> = { _ in }) {
        invokedLoadUNCountries = true
        invokedLoadUNCountriesCount += 1
        invokedLoadUNCountriesParameters = (then, ())
        invokedLoadUNCountriesParametersList.append((then, ()))
    }
    var invokedLoadUser = false
    var invokedLoadUserCount = 0
    var invokedLoadUserParameters: (id: Int, stub: MTPProvider.StubClosure, then: NetworkCompletion<UserJSON>)?
    var invokedLoadUserParametersList = [(id: Int, stub: MTPProvider.StubClosure, then: NetworkCompletion<UserJSON>)]()
    override func loadUser(id: Int,
    stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
    then: @escaping NetworkCompletion<UserJSON> = { _ in }) {
        invokedLoadUser = true
        invokedLoadUserCount += 1
        invokedLoadUserParameters = (id, stub, then)
        invokedLoadUserParametersList.append((id, stub, then))
    }
    var invokedLoadWHS = false
    var invokedLoadWHSCount = 0
    var invokedLoadWHSParameters: (then: NetworkCompletion<[WHSJSON]>, Void)?
    var invokedLoadWHSParametersList = [(then: NetworkCompletion<[WHSJSON]>, Void)]()
    override func loadWHS(then: @escaping NetworkCompletion<[WHSJSON]> = { _ in }) {
        invokedLoadWHS = true
        invokedLoadWHSCount += 1
        invokedLoadWHSParameters = (then, ())
        invokedLoadWHSParametersList.append((then, ()))
    }
    var invokedPostPublish = false
    var invokedPostPublishCount = 0
    var invokedPostPublishParameters: (payload: PostPayload, stub: MTPProvider.StubClosure, then: NetworkCompletion<PostReply>)?
    var invokedPostPublishParametersList = [(payload: PostPayload, stub: MTPProvider.StubClosure, then: NetworkCompletion<PostReply>)]()
    override func postPublish(payload: PostPayload,
    stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
    then: @escaping NetworkCompletion<PostReply>) {
        invokedPostPublish = true
        invokedPostPublishCount += 1
        invokedPostPublishParameters = (payload, stub, then)
        invokedPostPublishParametersList.append((payload, stub, then))
    }
    var invokedSearchCountries = false
    var invokedSearchCountriesCount = 0
    var invokedSearchCountriesParameters: (query: String, then: NetworkCompletion<[CountryJSON]>)?
    var invokedSearchCountriesParametersList = [(query: String, then: NetworkCompletion<[CountryJSON]>)]()
    override func searchCountries(query: String = "",
    then: @escaping NetworkCompletion<[CountryJSON]>) {
        invokedSearchCountries = true
        invokedSearchCountriesCount += 1
        invokedSearchCountriesParameters = (query, then)
        invokedSearchCountriesParametersList.append((query, then))
    }
    var invokedSearch = false
    var invokedSearchCount = 0
    var invokedSearchParameters: (query: String, stub: MTPProvider.StubClosure, then: NetworkCompletion<SearchResultJSON>)?
    var invokedSearchParametersList = [(query: String, stub: MTPProvider.StubClosure, then: NetworkCompletion<SearchResultJSON>)]()
    override func search(query: String,
    stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
    then: @escaping NetworkCompletion<SearchResultJSON>) {
        invokedSearch = true
        invokedSearchCount += 1
        invokedSearchParameters = (query, stub, then)
        invokedSearchParametersList.append((query, stub, then))
    }
    var invokedUpload = false
    var invokedUploadCount = 0
    var invokedUploadParameters: (photo: Data, caption: String?, id: Int?, stub: MTPProvider.StubClosure, then: NetworkCompletion<PhotoReply>)?
    var invokedUploadParametersList = [(photo: Data, caption: String?, id: Int?, stub: MTPProvider.StubClosure, then: NetworkCompletion<PhotoReply>)]()
    override func upload(photo: Data,
    caption: String?,
    location id: Int?,
    stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
    then: @escaping NetworkCompletion<PhotoReply>) {
        invokedUpload = true
        invokedUploadCount += 1
        invokedUploadParameters = (photo, caption, id, stub, then)
        invokedUploadParametersList.append((photo, caption, id, stub, then))
    }
    var invokedUserDeleteAccount = false
    var invokedUserDeleteAccountCount = 0
    var invokedUserDeleteAccountParameters: (stub: MTPProvider.StubClosure, then: NetworkCompletion<String>)?
    var invokedUserDeleteAccountParametersList = [(stub: MTPProvider.StubClosure, then: NetworkCompletion<String>)]()
    override func userDeleteAccount(
    stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
    then: @escaping NetworkCompletion<String>
    ) {
        invokedUserDeleteAccount = true
        invokedUserDeleteAccountCount += 1
        invokedUserDeleteAccountParameters = (stub, then)
        invokedUserDeleteAccountParametersList.append((stub, then))
    }
    var invokedUserForgotPassword = false
    var invokedUserForgotPasswordCount = 0
    var invokedUserForgotPasswordParameters: (email: String, stub: MTPProvider.StubClosure, then: NetworkCompletion<String>)?
    var invokedUserForgotPasswordParametersList = [(email: String, stub: MTPProvider.StubClosure, then: NetworkCompletion<String>)]()
    override func userForgotPassword(
    email: String,
    stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
    then: @escaping NetworkCompletion<String>
    ) {
        invokedUserForgotPassword = true
        invokedUserForgotPasswordCount += 1
        invokedUserForgotPasswordParameters = (email, stub, then)
        invokedUserForgotPasswordParametersList.append((email, stub, then))
    }
    var invokedUserGetByToken = false
    var invokedUserGetByTokenCount = 0
    var invokedUserGetByTokenParameters: (reload: Bool, stub: MTPProvider.StubClosure, then: NetworkCompletion<UserJSON>)?
    var invokedUserGetByTokenParametersList = [(reload: Bool, stub: MTPProvider.StubClosure, then: NetworkCompletion<UserJSON>)]()
    override func userGetByToken(
    reload: Bool,
    stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
    then: @escaping NetworkCompletion<UserJSON>
    ) {
        invokedUserGetByToken = true
        invokedUserGetByTokenCount += 1
        invokedUserGetByTokenParameters = (reload, stub, then)
        invokedUserGetByTokenParametersList.append((reload, stub, then))
    }
    var invokedUserLogin = false
    var invokedUserLoginCount = 0
    var invokedUserLoginParameters: (email: String, password: String, stub: MTPProvider.StubClosure, then: NetworkCompletion<UserJSON>)?
    var invokedUserLoginParametersList = [(email: String, password: String, stub: MTPProvider.StubClosure, then: NetworkCompletion<UserJSON>)]()
    override func userLogin(email: String,
    password: String,
    stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
    then: @escaping NetworkCompletion<UserJSON>) {
        invokedUserLogin = true
        invokedUserLoginCount += 1
        invokedUserLoginParameters = (email, password, stub, then)
        invokedUserLoginParametersList.append((email, password, stub, then))
    }
    var invokedUserRegister = false
    var invokedUserRegisterCount = 0
    var invokedUserRegisterParameters: (payload: RegistrationPayload, stub: MTPProvider.StubClosure, then: NetworkCompletion<UserJSON>)?
    var invokedUserRegisterParametersList = [(payload: RegistrationPayload, stub: MTPProvider.StubClosure, then: NetworkCompletion<UserJSON>)]()
    override func userRegister(payload: RegistrationPayload,
    stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
    then: @escaping NetworkCompletion<UserJSON>) {
        invokedUserRegister = true
        invokedUserRegisterCount += 1
        invokedUserRegisterParameters = (payload, stub, then)
        invokedUserRegisterParametersList.append((payload, stub, then))
    }
    var invokedUserUpdatePayload = false
    var invokedUserUpdatePayloadCount = 0
    var invokedUserUpdatePayloadParameters: (payload: UserUpdatePayload, stub: MTPProvider.StubClosure, then: NetworkCompletion<UserJSON>)?
    var invokedUserUpdatePayloadParametersList = [(payload: UserUpdatePayload, stub: MTPProvider.StubClosure, then: NetworkCompletion<UserJSON>)]()
    override func userUpdate(payload: UserUpdatePayload,
    stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
    then: @escaping NetworkCompletion<UserJSON>) {
        invokedUserUpdatePayload = true
        invokedUserUpdatePayloadCount += 1
        invokedUserUpdatePayloadParameters = (payload, stub, then)
        invokedUserUpdatePayloadParametersList.append((payload, stub, then))
    }
    var invokedUserUpdateToken = false
    var invokedUserUpdateTokenCount = 0
    var invokedUserUpdateTokenParameters: (token: String, stub: MTPProvider.StubClosure, then: NetworkCompletion<UserTokenReply>)?
    var invokedUserUpdateTokenParametersList = [(token: String, stub: MTPProvider.StubClosure, then: NetworkCompletion<UserTokenReply>)]()
    override func userUpdate(token: String,
    stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
    then: @escaping NetworkCompletion<UserTokenReply>) {
        invokedUserUpdateToken = true
        invokedUserUpdateTokenCount += 1
        invokedUserUpdateTokenParameters = (token, stub, then)
        invokedUserUpdateTokenParametersList.append((token, stub, then))
    }
    var invokedUserVerify = false
    var invokedUserVerifyCount = 0
    var invokedUserVerifyParameters: (id: Int, stub: MTPProvider.StubClosure, then: NetworkCompletion<String>)?
    var invokedUserVerifyParametersList = [(id: Int, stub: MTPProvider.StubClosure, then: NetworkCompletion<String>)]()
    override func userVerify(id: Int,
    stub: @escaping MTPProvider.StubClosure = MTPProvider.neverStub,
    then: @escaping NetworkCompletion<String>) {
        invokedUserVerify = true
        invokedUserVerifyCount += 1
        invokedUserVerifyParameters = (id, stub, then)
        invokedUserVerifyParametersList.append((id, stub, then))
    }
}
