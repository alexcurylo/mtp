// @copyright Trollwerks Inc.

import Moya

enum NetworkError: Swift.Error {
    case unknown
    case decoding
    case deviceOffline
    case message(String)
    case network(String)
    case notModified
    case parameter
    case serverOffline
    case status
    case throttle
    case token
}

typealias NetworkCompletion<T> = (_ result: Result<T, NetworkError>) -> Void

protocol NetworkService: ServiceProvider {

    func loadPhotos(location id: Int,
                    reload: Bool,
                    then: @escaping NetworkCompletion<PhotosInfoJSON>)
    func loadPhotos(page: Int,
                    reload: Bool,
                    then: @escaping NetworkCompletion<PhotosPageInfoJSON>)
    func loadPhotos(profile id: Int,
                    page: Int,
                    reload: Bool,
                    then: @escaping NetworkCompletion<PhotosPageInfoJSON>)
    func loadPosts(location id: Int,
                   then: @escaping NetworkCompletion<PostsJSON>)
    func loadPosts(user id: Int,
                   then: @escaping NetworkCompletion<PostsJSON>)
    func loadRankings(query: RankingsQuery,
                      then: @escaping NetworkCompletion<RankingsPageInfoJSON>)
    func loadScorecard(list: Checklist,
                       user id: Int,
                       then: @escaping NetworkCompletion<ScorecardJSON>)
    func loadUser(id: Int,
                  then: @escaping NetworkCompletion<UserJSON>)
    func search(query: String,
                then: @escaping NetworkCompletion<SearchResultJSON>)
    func set(items: [Checklist.Item],
             visited: Bool,
             then: @escaping NetworkCompletion<Bool>)
    func upload(photo: Data,
                caption: String?,
                location id: Int?,
                then: @escaping NetworkCompletion<PhotoReply>)
    func postPublish(payload: PostPayload,
                     then: @escaping NetworkCompletion<PostReply>)
    func userDeleteAccount(then: @escaping NetworkCompletion<String>)
    func userForgotPassword(email: String,
                            then: @escaping NetworkCompletion<String>)
    func userLogin(email: String,
                   password: String,
                   then: @escaping NetworkCompletion<UserJSON>)
    func userRegister(payload: RegistrationPayload,
                      then: @escaping NetworkCompletion<UserJSON>)
    func userUpdate(payload: UserUpdatePayload,
                    then: @escaping NetworkCompletion<UserJSON>)

    func refreshRankings()
    func refreshEverything()
}

class NetworkServiceImpl: NetworkService {

    let mtp = MTPNetworkController()

    private var queue = OperationQueue {
        $0.name = "refresh"
        $0.maxConcurrentOperationCount = 1
        $0.qualityOfService = .utility
    }

    func refreshData() {
        add { done in self.mtp.loadSettings { _ in done() } }
        add { done in self.mtp.searchCountries { _ in done() } }
        add { done in self.mtp.loadLocations { _ in done() } }

        add { done in self.mtp.loadBeaches { _ in done() } }
        add { done in self.mtp.loadDiveSites { _ in done() } }
        add { done in self.mtp.loadGolfCourses { _ in done() } }
        add { done in self.mtp.loadRestaurants { _ in done() } }
        add { done in self.mtp.loadUNCountries { _ in done() } }
        add { done in self.mtp.loadWHS { _ in done() } }
    }

    func refreshUser() {
        guard data.isLoggedIn else { return }

        mtp.userGetByToken { _ in
            self.refreshUserInfo()
        }
    }

    // MARK: - NetworkService

    func loadPhotos(location id: Int,
                    reload: Bool,
                    then: @escaping NetworkCompletion<PhotosInfoJSON>) {
        mtp.loadPhotos(location: id, reload: reload, then: then)
    }

    func loadPhotos(page: Int,
                    reload: Bool,
                    then: @escaping NetworkCompletion<PhotosPageInfoJSON>) {
        mtp.loadPhotos(page: page, reload: reload, then: then)
    }

    func loadPhotos(profile id: Int,
                    page: Int,
                    reload: Bool,
                    then: @escaping NetworkCompletion<PhotosPageInfoJSON>) {
        mtp.loadPhotos(profile: id, page: page, reload: reload, then: then)
    }

    func loadPosts(location id: Int,
                   then: @escaping NetworkCompletion<PostsJSON>) {
        mtp.loadPosts(location: id, then: then)
    }

    func loadPosts(user id: Int, then: @escaping NetworkCompletion<PostsJSON>) {
        mtp.loadPosts(user: id, then: then)
    }

    func loadRankings(query: RankingsQuery,
                      then: @escaping NetworkCompletion<RankingsPageInfoJSON>) {
        mtp.loadRankings(query: query, then: then)
    }

    func loadScorecard(list: Checklist,
                       user id: Int,
                       then: @escaping NetworkCompletion<ScorecardJSON>) {
        mtp.loadScorecard(list: list, user: id, then: then)
    }

    func loadUser(id: Int, then: @escaping NetworkCompletion<UserJSON>) {
        mtp.loadUser(id: id, then: then)
    }

    func search(query: String,
                then: @escaping NetworkCompletion<SearchResultJSON>) {
        mtp.search(query: query, then: then)
    }

    func set(items: [Checklist.Item],
             visited: Bool,
             then: @escaping NetworkCompletion<Bool>) {
        mtp.set(items: items, visited: visited, then: then)
    }

    func upload(photo: Data,
                caption: String?,
                location id: Int?,
                then: @escaping NetworkCompletion<PhotoReply>) {
        mtp.upload(photo: photo, caption: caption, location: id, then: then)
    }

    func postPublish(payload: PostPayload, then: @escaping NetworkCompletion<PostReply>) {
        mtp.postPublish(payload: payload, then: then)
    }

    func userDeleteAccount(then: @escaping NetworkCompletion<String>) {
        mtp.userDeleteAccount(then: then)
    }

    func userForgotPassword(email: String,
                            then: @escaping NetworkCompletion<String>) {
        mtp.userForgotPassword(email: email, then: then)
    }

    func userLogin(email: String,
                   password: String,
                   then: @escaping NetworkCompletion<UserJSON>) {
        mtp.userLogin(email: email, password: password) { result in
            if case .success = result {
                self.refreshUserInfo()
            }
            then(result)
        }
    }

    func userRegister(payload: RegistrationPayload,
                      then: @escaping NetworkCompletion<UserJSON>) {
        mtp.userRegister(payload: payload, then: then)
    }

    func userUpdate(payload: UserUpdatePayload,
                    then: @escaping NetworkCompletion<UserJSON>) {
        mtp.userUpdate(payload: payload, then: then)
    }

    func refreshRankings() {
        var query = data.lastRankingsQuery
        Checklist.allCases.forEach { list in
            query.checklistKey = list.key
            add { done in self.mtp.loadRankings(query: query) { _ in done() } }
        }
    }

    func refreshEverything() {
        refreshUser()
        refreshData()
        refreshRankings()
    }
}

// MARK: - Private

private extension NetworkServiceImpl {

    func add(operation: @escaping AsyncBlockOperation.Operation) {
        queue.addOperation(
            AsyncBlockOperation(operation: operation)
        )
    }

    func refreshUserInfo() {
        guard let user = data.user else { return }

        add { done in self.mtp.loadChecklists { _ in done() } }
        add { done in self.mtp.loadPosts(user: user.id) { _ in done() } }
        add { done in self.mtp.loadPhotos(page: 1, reload: false) { _ in done() } }
        Checklist.allCases.forEach { list in
            add { done in self.loadScorecard(list: list, user: user.id) { _ in done() } }
        }
    }
}

final class NetworkServiceStub: NetworkServiceImpl {

    override func refreshData() {
        // expect seeded
    }

    override func refreshRankings() {
        // expect seeded
    }

    override func refreshUser() {
        mtp.userGetByToken(stub: MTPProvider.immediatelyStub) { _ in }
        guard let user = data.user else { return }

        mtp.loadChecklists(stub: MTPProvider.immediatelyStub) { _ in }
        loadPosts(user: user.id) { _ in }
        loadPhotos(profile: user.id, page: 1, reload: false) { _ in }
        Checklist.allCases.forEach { list in
            loadScorecard(list: list,
                          user: user.id) { _ in }
        }
    }

    override func loadPhotos(location id: Int,
                             reload: Bool,
                             then: @escaping NetworkCompletion<PhotosInfoJSON>) {
        log.error("not stubbed yet")
    }

    override func loadPhotos(page: Int,
                             reload: Bool,
                             then: @escaping NetworkCompletion<PhotosPageInfoJSON>) {
        mtp.loadPhotos(page: page,
                       reload: reload,
                       stub: MTPProvider.immediatelyStub,
                       then: then)
    }

    override func loadPhotos(profile id: Int,
                             page: Int,
                             reload: Bool,
                             then: @escaping NetworkCompletion<PhotosPageInfoJSON>) {
        mtp.loadPhotos(profile: id,
                       page: page,
                       reload: reload,
                       stub: MTPProvider.immediatelyStub,
                       then: then)
    }

    override func loadPosts(location id: Int,
                            then: @escaping NetworkCompletion<PostsJSON>) {
        log.error("not stubbed yet")
    }

    override func loadPosts(user id: Int,
                            then: @escaping NetworkCompletion<PostsJSON>) {
        mtp.loadPosts(user: id,
                      stub: MTPProvider.immediatelyStub,
                      then: then)
    }

    override func loadRankings(query: RankingsQuery,
                               then: @escaping NetworkCompletion<RankingsPageInfoJSON>) {
        mtp.loadRankings(query: query,
                         stub: MTPProvider.immediatelyStub,
                         then: then)
    }

    override func loadScorecard(list: Checklist,
                                user id: Int,
                                then: @escaping NetworkCompletion<ScorecardJSON>) {
        mtp.loadScorecard(list: list,
                          user: id,
                          stub: MTPProvider.immediatelyStub,
                          then: then)
    }

    override func loadUser(id: Int,
                           then: @escaping NetworkCompletion<UserJSON>) {
        mtp.loadUser(id: id,
                     stub: MTPProvider.immediatelyStub,
                     then: then)
    }

    override func search(query: String,
                         then: @escaping NetworkCompletion<SearchResultJSON>) {
        log.error("not stubbed yet")
    }

    override func set(items: [Checklist.Item],
                      visited: Bool,
                      then: @escaping NetworkCompletion<Bool>) {
        log.error("not stubbed yet")
    }

    override func upload(photo: Data,
                         caption: String?,
                         location id: Int?,
                         then: @escaping NetworkCompletion<PhotoReply>) {
        log.error("not stubbed yet")
    }

    override func postPublish(payload: PostPayload,
                              then: @escaping NetworkCompletion<PostReply>) {
        log.error("not stubbed yet")
    }

    override func userDeleteAccount(then: @escaping NetworkCompletion<String>) {
        log.error("not stubbed yet")
    }

    override func userForgotPassword(email: String,
                                     then: @escaping NetworkCompletion<String>) {
        log.error("not stubbed yet")
    }

    override func userLogin(email: String,
                            password: String,
                            then: @escaping NetworkCompletion<UserJSON>) {
        log.error("not stubbed yet")
    }

    override func userRegister(payload: RegistrationPayload,
                               then: @escaping NetworkCompletion<UserJSON>) {
        log.error("not stubbed yet")
    }

    override func userUpdate(payload: UserUpdatePayload,
                             then: @escaping NetworkCompletion<UserJSON>) {
        log.error("not stubbed yet")
    }
}
