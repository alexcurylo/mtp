// @copyright Trollwerks Inc.

@testable import MTP

// generated by https://github.com/seanhenry/SwiftMockGeneratorForXcode
// swiftlint:disable all

final class NetworkServiceSpy: NetworkService {
    var invokedIsConnectedGetter = false
    var invokedIsConnectedGetterCount = 0
    var stubbedIsConnected: Bool! = false
    var isConnected: Bool {
        invokedIsConnectedGetter = true
        invokedIsConnectedGetterCount += 1
        return stubbedIsConnected
    }
    var invokedTasksGetter = false
    var invokedTasksGetterCount = 0
    var stubbedTasks: [OfflineRequestManager.Task]! = []
    var tasks: [OfflineRequestManager.Task] {
        invokedTasksGetter = true
        invokedTasksGetterCount += 1
        return stubbedTasks
    }
    var invokedMtpGetter = false
    var invokedMtpGetterCount = 0
    var stubbedMtp: MTPNetworkController!
    var mtp: MTPNetworkController {
        invokedMtpGetter = true
        invokedMtpGetterCount += 1
        return stubbedMtp
    }
    var invokedStatusKeyGetter = false
    var invokedStatusKeyGetterCount = 0
    var stubbedStatusKey: StatusKey!
    var statusKey: StatusKey {
        invokedStatusKeyGetter = true
        invokedStatusKeyGetterCount += 1
        return stubbedStatusKey
    }
    var invokedNotificationGetter = false
    var invokedNotificationGetterCount = 0
    var stubbedNotification: Notification.Name!
    var notification: Notification.Name {
        invokedNotificationGetter = true
        invokedNotificationGetterCount += 1
        return stubbedNotification
    }
    var invokedAppGetter = false
    var invokedAppGetterCount = 0
    var stubbedApp: ApplicationService!
    var app: ApplicationService {
        invokedAppGetter = true
        invokedAppGetterCount += 1
        return stubbedApp
    }
    var invokedDataGetter = false
    var invokedDataGetterCount = 0
    var stubbedData: DataService!
    var data: DataService {
        invokedDataGetter = true
        invokedDataGetterCount += 1
        return stubbedData
    }
    var invokedLocGetter = false
    var invokedLocGetterCount = 0
    var stubbedLoc: LocationService!
    var loc: LocationService {
        invokedLocGetter = true
        invokedLocGetterCount += 1
        return stubbedLoc
    }
    var invokedLogGetter = false
    var invokedLogGetterCount = 0
    var stubbedLog: LoggingService!
    var log: LoggingService {
        invokedLogGetter = true
        invokedLogGetterCount += 1
        return stubbedLog
    }
    var invokedNetGetter = false
    var invokedNetGetterCount = 0
    var stubbedNet: NetworkService!
    var net: NetworkService {
        invokedNetGetter = true
        invokedNetGetterCount += 1
        return stubbedNet
    }
    var invokedNoteGetter = false
    var invokedNoteGetterCount = 0
    var stubbedNote: NotificationService!
    var note: NotificationService {
        invokedNoteGetter = true
        invokedNoteGetterCount += 1
        return stubbedNote
    }
    var invokedReportGetter = false
    var invokedReportGetterCount = 0
    var stubbedReport: ReportingService!
    var report: ReportingService {
        invokedReportGetter = true
        invokedReportGetterCount += 1
        return stubbedReport
    }
    var invokedStyleGetter = false
    var invokedStyleGetterCount = 0
    var stubbedStyle: StyleService!
    var style: StyleService {
        invokedStyleGetter = true
        invokedStyleGetterCount += 1
        return stubbedStyle
    }
    var invokedLoadPhotosLocation = false
    var invokedLoadPhotosLocationCount = 0
    var invokedLoadPhotosLocationParameters: (id: Int, reload: Bool, then: NetworkCompletion<PhotosInfoJSON>)?
    var invokedLoadPhotosLocationParametersList = [(id: Int, reload: Bool, then: NetworkCompletion<PhotosInfoJSON>)]()
    func loadPhotos(location id: Int,
    reload: Bool,
    then: @escaping NetworkCompletion<PhotosInfoJSON>) {
        invokedLoadPhotosLocation = true
        invokedLoadPhotosLocationCount += 1
        invokedLoadPhotosLocationParameters = (id, reload, then)
        invokedLoadPhotosLocationParametersList.append((id, reload, then))
    }
    var invokedLoadPhotosPage = false
    var invokedLoadPhotosPageCount = 0
    var invokedLoadPhotosPageParameters: (page: Int, reload: Bool, then: NetworkCompletion<PhotosPageInfoJSON>)?
    var invokedLoadPhotosPageParametersList = [(page: Int, reload: Bool, then: NetworkCompletion<PhotosPageInfoJSON>)]()
    func loadPhotos(page: Int,
    reload: Bool,
    then: @escaping NetworkCompletion<PhotosPageInfoJSON>) {
        invokedLoadPhotosPage = true
        invokedLoadPhotosPageCount += 1
        invokedLoadPhotosPageParameters = (page, reload, then)
        invokedLoadPhotosPageParametersList.append((page, reload, then))
    }
    var invokedLoadPhotosProfile = false
    var invokedLoadPhotosProfileCount = 0
    var invokedLoadPhotosProfileParameters: (id: Int, page: Int, reload: Bool, then: NetworkCompletion<PhotosPageInfoJSON>)?
    var invokedLoadPhotosProfileParametersList = [(id: Int, page: Int, reload: Bool, then: NetworkCompletion<PhotosPageInfoJSON>)]()
    func loadPhotos(profile id: Int,
    page: Int,
    reload: Bool,
    then: @escaping NetworkCompletion<PhotosPageInfoJSON>) {
        invokedLoadPhotosProfile = true
        invokedLoadPhotosProfileCount += 1
        invokedLoadPhotosProfileParameters = (id, page, reload, then)
        invokedLoadPhotosProfileParametersList.append((id, page, reload, then))
    }
    var invokedLoadPostsLocation = false
    var invokedLoadPostsLocationCount = 0
    var invokedLoadPostsLocationParameters: (id: Int, then: NetworkCompletion<PostsJSON>)?
    var invokedLoadPostsLocationParametersList = [(id: Int, then: NetworkCompletion<PostsJSON>)]()
    func loadPosts(location id: Int,
    then: @escaping NetworkCompletion<PostsJSON>) {
        invokedLoadPostsLocation = true
        invokedLoadPostsLocationCount += 1
        invokedLoadPostsLocationParameters = (id, then)
        invokedLoadPostsLocationParametersList.append((id, then))
    }
    var invokedLoadPostsUser = false
    var invokedLoadPostsUserCount = 0
    var invokedLoadPostsUserParameters: (id: Int, then: NetworkCompletion<PostsJSON>)?
    var invokedLoadPostsUserParametersList = [(id: Int, then: NetworkCompletion<PostsJSON>)]()
    func loadPosts(user id: Int,
    then: @escaping NetworkCompletion<PostsJSON>) {
        invokedLoadPostsUser = true
        invokedLoadPostsUserCount += 1
        invokedLoadPostsUserParameters = (id, then)
        invokedLoadPostsUserParametersList.append((id, then))
    }
    var invokedLoadRankings = false
    var invokedLoadRankingsCount = 0
    var invokedLoadRankingsParameters: (query: RankingsQuery, then: NetworkCompletion<RankingsPageInfoJSON>)?
    var invokedLoadRankingsParametersList = [(query: RankingsQuery, then: NetworkCompletion<RankingsPageInfoJSON>)]()
    func loadRankings(query: RankingsQuery,
    then: @escaping NetworkCompletion<RankingsPageInfoJSON>) {
        invokedLoadRankings = true
        invokedLoadRankingsCount += 1
        invokedLoadRankingsParameters = (query, then)
        invokedLoadRankingsParametersList.append((query, then))
    }
    var invokedLoadScorecard = false
    var invokedLoadScorecardCount = 0
    var invokedLoadScorecardParameters: (list: Checklist, id: Int, then: NetworkCompletion<ScorecardJSON>)?
    var invokedLoadScorecardParametersList = [(list: Checklist, id: Int, then: NetworkCompletion<ScorecardJSON>)]()
    func loadScorecard(list: Checklist,
    user id: Int,
    then: @escaping NetworkCompletion<ScorecardJSON>) {
        invokedLoadScorecard = true
        invokedLoadScorecardCount += 1
        invokedLoadScorecardParameters = (list, id, then)
        invokedLoadScorecardParametersList.append((list, id, then))
    }
    var invokedLoadUser = false
    var invokedLoadUserCount = 0
    var invokedLoadUserParameters: (id: Int, then: NetworkCompletion<UserJSON>)?
    var invokedLoadUserParametersList = [(id: Int, then: NetworkCompletion<UserJSON>)]()
    func loadUser(id: Int,
    then: @escaping NetworkCompletion<UserJSON>) {
        invokedLoadUser = true
        invokedLoadUserCount += 1
        invokedLoadUserParameters = (id, then)
        invokedLoadUserParametersList.append((id, then))
    }
    var invokedSearch = false
    var invokedSearchCount = 0
    var invokedSearchParameters: (query: String, then: NetworkCompletion<SearchResultJSON>)?
    var invokedSearchParametersList = [(query: String, then: NetworkCompletion<SearchResultJSON>)]()
    func search(query: String,
    then: @escaping NetworkCompletion<SearchResultJSON>) {
        invokedSearch = true
        invokedSearchCount += 1
        invokedSearchParameters = (query, then)
        invokedSearchParametersList.append((query, then))
    }
    var invokedSet = false
    var invokedSetCount = 0
    var invokedSetParameters: (items: [Checklist.Item], visited: Bool, then: NetworkCompletion<Bool>)?
    var invokedSetParametersList = [(items: [Checklist.Item], visited: Bool, then: NetworkCompletion<Bool>)]()
    func set(items: [Checklist.Item],
    visited: Bool,
    then: @escaping NetworkCompletion<Bool>) {
        invokedSet = true
        invokedSetCount += 1
        invokedSetParameters = (items, visited, then)
        invokedSetParametersList.append((items, visited, then))
    }
    var invokedUpload = false
    var invokedUploadCount = 0
    var invokedUploadParameters: (photo: Data, caption: String?, id: Int?, then: NetworkCompletion<PhotoReply>)?
    var invokedUploadParametersList = [(photo: Data, caption: String?, id: Int?, then: NetworkCompletion<PhotoReply>)]()
    func upload(photo: Data,
    caption: String?,
    location id: Int?,
    then: @escaping NetworkCompletion<PhotoReply>) {
        invokedUpload = true
        invokedUploadCount += 1
        invokedUploadParameters = (photo, caption, id, then)
        invokedUploadParametersList.append((photo, caption, id, then))
    }
    var invokedPostPublish = false
    var invokedPostPublishCount = 0
    var invokedPostPublishParameters: (payload: PostPayload, then: NetworkCompletion<PostReply>)?
    var invokedPostPublishParametersList = [(payload: PostPayload, then: NetworkCompletion<PostReply>)]()
    func postPublish(payload: PostPayload,
    then: @escaping NetworkCompletion<PostReply>) {
        invokedPostPublish = true
        invokedPostPublishCount += 1
        invokedPostPublishParameters = (payload, then)
        invokedPostPublishParametersList.append((payload, then))
    }
    var invokedUserDeleteAccount = false
    var invokedUserDeleteAccountCount = 0
    var invokedUserDeleteAccountParameters: (then: NetworkCompletion<String>, Void)?
    var invokedUserDeleteAccountParametersList = [(then: NetworkCompletion<String>, Void)]()
    func userDeleteAccount(then: @escaping NetworkCompletion<String>) {
        invokedUserDeleteAccount = true
        invokedUserDeleteAccountCount += 1
        invokedUserDeleteAccountParameters = (then, ())
        invokedUserDeleteAccountParametersList.append((then, ()))
    }
    var invokedUserForgotPassword = false
    var invokedUserForgotPasswordCount = 0
    var invokedUserForgotPasswordParameters: (email: String, then: NetworkCompletion<String>)?
    var invokedUserForgotPasswordParametersList = [(email: String, then: NetworkCompletion<String>)]()
    func userForgotPassword(email: String,
    then: @escaping NetworkCompletion<String>) {
        invokedUserForgotPassword = true
        invokedUserForgotPasswordCount += 1
        invokedUserForgotPasswordParameters = (email, then)
        invokedUserForgotPasswordParametersList.append((email, then))
    }
    var invokedUserLogin = false
    var invokedUserLoginCount = 0
    var invokedUserLoginParameters: (email: String, password: String, then: NetworkCompletion<UserJSON>)?
    var invokedUserLoginParametersList = [(email: String, password: String, then: NetworkCompletion<UserJSON>)]()
    func userLogin(email: String,
    password: String,
    then: @escaping NetworkCompletion<UserJSON>) {
        invokedUserLogin = true
        invokedUserLoginCount += 1
        invokedUserLoginParameters = (email, password, then)
        invokedUserLoginParametersList.append((email, password, then))
    }
    var invokedUserRegister = false
    var invokedUserRegisterCount = 0
    var invokedUserRegisterParameters: (payload: RegistrationPayload, then: NetworkCompletion<UserJSON>)?
    var invokedUserRegisterParametersList = [(payload: RegistrationPayload, then: NetworkCompletion<UserJSON>)]()
    func userRegister(payload: RegistrationPayload,
    then: @escaping NetworkCompletion<UserJSON>) {
        invokedUserRegister = true
        invokedUserRegisterCount += 1
        invokedUserRegisterParameters = (payload, then)
        invokedUserRegisterParametersList.append((payload, then))
    }
    var invokedUserUpdatePayload = false
    var invokedUserUpdatePayloadCount = 0
    var invokedUserUpdatePayloadParameters: (payload: UserUpdatePayload, then: NetworkCompletion<UserJSON>)?
    var invokedUserUpdatePayloadParametersList = [(payload: UserUpdatePayload, then: NetworkCompletion<UserJSON>)]()
    func userUpdate(payload: UserUpdatePayload,
    then: @escaping NetworkCompletion<UserJSON>) {
        invokedUserUpdatePayload = true
        invokedUserUpdatePayloadCount += 1
        invokedUserUpdatePayloadParameters = (payload, then)
        invokedUserUpdatePayloadParametersList.append((payload, then))
    }
    var invokedUserUpdateToken = false
    var invokedUserUpdateTokenCount = 0
    var invokedUserUpdateTokenParameters: (token: String, then: NetworkCompletion<UserTokenReply>)?
    var invokedUserUpdateTokenParametersList = [(token: String, then: NetworkCompletion<UserTokenReply>)]()
    func userUpdate(token: String,
    then: @escaping NetworkCompletion<UserTokenReply>) {
        invokedUserUpdateToken = true
        invokedUserUpdateTokenCount += 1
        invokedUserUpdateTokenParameters = (token, then)
        invokedUserUpdateTokenParametersList.append((token, then))
    }
    var invokedUserVerify = false
    var invokedUserVerifyCount = 0
    var invokedUserVerifyParameters: (id: Int, then: NetworkCompletion<String>)?
    var invokedUserVerifyParametersList = [(id: Int, then: NetworkCompletion<String>)]()
    func userVerify(id: Int,
    then: @escaping NetworkCompletion<String>) {
        invokedUserVerify = true
        invokedUserVerifyCount += 1
        invokedUserVerifyParameters = (id, then)
        invokedUserVerifyParametersList.append((id, then))
    }
    var invokedRefreshRankings = false
    var invokedRefreshRankingsCount = 0
    func refreshRankings() {
        invokedRefreshRankings = true
        invokedRefreshRankingsCount += 1
    }
    var invokedRefreshEverything = false
    var invokedRefreshEverythingCount = 0
    func refreshEverything() {
        invokedRefreshEverything = true
        invokedRefreshEverythingCount += 1
    }
    var invokedUnthrottle = false
    var invokedUnthrottleCount = 0
    func unthrottle() {
        invokedUnthrottle = true
        invokedUnthrottleCount += 1
    }
    var invokedNotify = false
    var invokedNotifyCount = 0
    var invokedNotifyParameters: (changed: String, info: [AnyHashable: Any])?
    var invokedNotifyParametersList = [(changed: String, info: [AnyHashable: Any])]()
    func notify(observers changed: String,
    info: [AnyHashable: Any]) {
        invokedNotify = true
        invokedNotifyCount += 1
        invokedNotifyParameters = (changed, info)
        invokedNotifyParametersList.append((changed, info))
    }
}
