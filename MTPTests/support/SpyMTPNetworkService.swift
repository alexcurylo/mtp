// @copyright Trollwerks Inc.

@testable import MTP

// swiftlint:disable let_var_whitespace large_tuple
final class SpyMTPNetworkService: MTPNetworkService {

    var invokedCheck = false
    var invokedCheckCount = 0
    var invokedCheckParameters: (list: Checklist, id: Int, visited: Bool, then: MTPResult<Bool>)?
    var invokedCheckParametersList = [(list: Checklist, id: Int, visited: Bool, then: MTPResult<Bool>)]()
    func check(list: Checklist,
               id: Int,
               visited: Bool,
               then: @escaping MTPResult<Bool>) {
        invokedCheck = true
        invokedCheckCount += 1
        invokedCheckParameters = (list, id, visited, then)
        invokedCheckParametersList.append((list, id, visited, then))
    }
    var invokedLoadPhotosLocation = false
    var invokedLoadPhotosLocationCount = 0
    var invokedLoadPhotosLocationParameters: (id: Int, then: MTPResult<PhotosInfoJSON>)?
    var invokedLoadPhotosLocationParametersList = [(id: Int, then: MTPResult<PhotosInfoJSON>)]()
    func loadPhotos(location id: Int,
                    then: @escaping MTPResult<PhotosInfoJSON>) {
        invokedLoadPhotosLocation = true
        invokedLoadPhotosLocationCount += 1
        invokedLoadPhotosLocationParameters = (id, then)
        invokedLoadPhotosLocationParametersList.append((id, then))
    }
    var invokedLoadPhotos = false
    var invokedLoadPhotosCount = 0
    var invokedLoadPhotosParameters: (id: Int?, page: Int, then: MTPResult<PhotosPageInfoJSON>)?
    var invokedLoadPhotosParametersList = [(id: Int?, page: Int, then: MTPResult<PhotosPageInfoJSON>)]()
    func loadPhotos(user id: Int?,
                    page: Int,
                    then: @escaping MTPResult<PhotosPageInfoJSON>) {
        invokedLoadPhotos = true
        invokedLoadPhotosCount += 1
        invokedLoadPhotosParameters = (id, page, then)
        invokedLoadPhotosParametersList.append((id, page, then))
    }
    var invokedLoadPostsLocation = false
    var invokedLoadPostsLocationCount = 0
    var invokedLoadPostsLocationParameters: (id: Int, then: MTPResult<PostsJSON>)?
    var invokedLoadPostsLocationParametersList = [(id: Int, then: MTPResult<PostsJSON>)]()
    func loadPosts(location id: Int, then: @escaping MTPResult<PostsJSON>) {
        invokedLoadPostsLocation = true
        invokedLoadPostsLocationCount += 1
        invokedLoadPostsLocationParameters = (id, then)
        invokedLoadPostsLocationParametersList.append((id, then))
    }
    var invokedLoadRankings = false
    var invokedLoadRankingsCount = 0
    var invokedLoadRankingsParameters: (query: RankingsQuery, then: MTPResult<RankingsPageInfoJSON>)?
    var invokedLoadRankingsParametersList = [(query: RankingsQuery, then: MTPResult<RankingsPageInfoJSON>)]()
    func loadRankings(query: RankingsQuery,
                      then: @escaping MTPResult<RankingsPageInfoJSON>) {
        invokedLoadRankings = true
        invokedLoadRankingsCount += 1
        invokedLoadRankingsParameters = (query, then)
        invokedLoadRankingsParametersList.append((query, then))
    }
    var invokedLoadScorecard = false
    var invokedLoadScorecardCount = 0
    var invokedLoadScorecardParameters: (list: Checklist, id: Int, then: MTPResult<ScorecardJSON>)?
    var invokedLoadScorecardParametersList = [(list: Checklist, id: Int, then: MTPResult<ScorecardJSON>)]()
    func loadScorecard(list: Checklist,
                       user id: Int,
                       then: @escaping MTPResult<ScorecardJSON>) {
        invokedLoadScorecard = true
        invokedLoadScorecardCount += 1
        invokedLoadScorecardParameters = (list, id, then)
        invokedLoadScorecardParametersList.append((list, id, then))
    }
    var invokedLoadUser = false
    var invokedLoadUserCount = 0
    var invokedLoadUserParameters: (id: Int, then: MTPResult<UserJSON>)?
    var invokedLoadUserParametersList = [(id: Int, then: MTPResult<UserJSON>)]()
    func loadUser(id: Int,
                  then: @escaping MTPResult<UserJSON>) {
        invokedLoadUser = true
        invokedLoadUserCount += 1
        invokedLoadUserParameters = (id, then)
        invokedLoadUserParametersList.append((id, then))
    }
    var invokedUserDeleteAccount = false
    var invokedUserDeleteAccountCount = 0
    var invokedUserDeleteAccountParameters: (then: MTPResult<String>, Void)?
    var invokedUserDeleteAccountParametersList = [(then: MTPResult<String>, Void)]()
    func userDeleteAccount(then: @escaping MTPResult<String>) {
        invokedUserDeleteAccount = true
        invokedUserDeleteAccountCount += 1
        invokedUserDeleteAccountParameters = (then, ())
        invokedUserDeleteAccountParametersList.append((then, ()))
    }
    var invokedUserForgotPassword = false
    var invokedUserForgotPasswordCount = 0
    var invokedUserForgotPasswordParameters: (email: String, then: MTPResult<String>)?
    var invokedUserForgotPasswordParametersList = [(email: String, then: MTPResult<String>)]()
    func userForgotPassword(email: String,
                            then: @escaping MTPResult<String>) {
        invokedUserForgotPassword = true
        invokedUserForgotPasswordCount += 1
        invokedUserForgotPasswordParameters = (email, then)
        invokedUserForgotPasswordParametersList.append((email, then))
    }
    var invokedUserLogin = false
    var invokedUserLoginCount = 0
    var invokedUserLoginParameters: (email: String, password: String, then: MTPResult<UserJSON>)?
    var invokedUserLoginParametersList = [(email: String, password: String, then: MTPResult<UserJSON>)]()
    func userLogin(email: String,
                   password: String,
                   then: @escaping MTPResult<UserJSON>) {
        invokedUserLogin = true
        invokedUserLoginCount += 1
        invokedUserLoginParameters = (email, password, then)
        invokedUserLoginParametersList.append((email, password, then))
    }
    var invokedUserRegister = false
    var invokedUserRegisterCount = 0
    var invokedUserRegisterParameters: (info: RegistrationInfo, then: MTPResult<UserJSON>)?
    var invokedUserRegisterParametersList = [(info: RegistrationInfo, then: MTPResult<UserJSON>)]()
    func userRegister(info: RegistrationInfo,
                      then: @escaping MTPResult<UserJSON>) {
        invokedUserRegister = true
        invokedUserRegisterCount += 1
        invokedUserRegisterParameters = (info, then)
        invokedUserRegisterParametersList.append((info, then))
    }
    var invokedRefreshEverything = false
    var invokedRefreshEverythingCount = 0
    func refreshEverything() {
        invokedRefreshEverything = true
        invokedRefreshEverythingCount += 1
    }
    var invokedRefreshRankings = false
    var invokedRefreshRankingsCount = 0
    func refreshRankings() {
        invokedRefreshRankings = true
        invokedRefreshRankingsCount += 1
    }
}
