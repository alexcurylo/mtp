// @copyright Trollwerks Inc.

import Moya

// swiftlint:disable file_length

/// Errors provided by network
enum NetworkError: Swift.Error {

    /// unknown
    case unknown
    /// decoding
    case decoding
    /// deviceOffline
    case deviceOffline
    /// message(String)
    case message(String)
    /// network(String)
    case network(String)
    /// notModified
    case notModified
    /// parameter
    case parameter
    /// serverOffline
    case serverOffline
    /// status
    case status
    /// throttle
    case throttle
    /// token
    case token
}

/// Generic NetworkService completion handler
typealias NetworkCompletion<T> = (_ result: Result<T, NetworkError>) -> Void

/// Provides network-related functionality
protocol NetworkService: ServiceProvider {

    /// Load location photos
    ///
    /// - Parameters:
    ///   - id: Location ID
    ///   - reload: Force reload
    ///   - then: Completion
    func loadPhotos(location id: Int,
                    reload: Bool,
                    then: @escaping NetworkCompletion<PhotosInfoJSON>)
    /// Load logged in user photos
    ///
    /// - Parameters:
    ///   - page: Index
    ///   - reload: Force reload
    ///   - then: Completion
    func loadPhotos(page: Int,
                    reload: Bool,
                    then: @escaping NetworkCompletion<PhotosPageInfoJSON>)
    /// Load user photos
    ///
    /// - Parameters:
    ///   - id: User ID
    ///   - page: Index
    ///   - reload: Force reload
    ///   - then: Completion
    func loadPhotos(profile id: Int,
                    page: Int,
                    reload: Bool,
                    then: @escaping NetworkCompletion<PhotosPageInfoJSON>)
    /// Load location posts
    ///
    /// - Parameters:
    ///   - id: Location ID
    ///   - then: Completion
    func loadPosts(location id: Int,
                   then: @escaping NetworkCompletion<PostsJSON>)
    /// Load user posts
    ///
    /// - Parameters:
    ///   - id: User ID
    ///   - then: Completion
    func loadPosts(user id: Int,
                   then: @escaping NetworkCompletion<PostsJSON>)
    /// Load rankings
    ///
    /// - Parameters:
    ///   - query: Filter
    ///   - then: Completion
    func loadRankings(query: RankingsQuery,
                      then: @escaping NetworkCompletion<RankingsPageInfoJSON>)
    /// Load scorecard
    ///
    /// - Parameters:
    ///   - list: Checklist
    ///   - id: User ID
    ///   - then: Completion
    func loadScorecard(list: Checklist,
                       user id: Int,
                       then: @escaping NetworkCompletion<ScorecardJSON>)
    /// Load user
    ///
    /// - Parameters:
    ///   - id: User ID
    ///   - then: Completion
    func loadUser(id: Int,
                  then: @escaping NetworkCompletion<UserJSON>)
    /// Search
    ///
    /// - Parameters:
    ///   - query: Query
    ///   - then: Completion
    func search(query: String,
                then: @escaping NetworkCompletion<SearchResultJSON>)
    /// Set places visit status
    ///
    /// - Parameters:
    ///   - items: Places
    ///   - visited: Whether visited
    ///   - then: Completion
    func set(items: [Checklist.Item],
             visited: Bool,
             then: @escaping NetworkCompletion<Bool>)
    /// Upload photo
    ///
    /// - Parameters:
    ///   - photo: Data
    ///   - caption: String
    ///   - id: Location ID if any
    ///   - then: Completion
    func upload(photo: Data,
                caption: String?,
                location id: Int?,
                then: @escaping NetworkCompletion<PhotoReply>)
    /// Publish post
    ///
    /// - Parameters:
    ///   - payload: Post payload
    ///   - then: Completion
    func postPublish(payload: PostPayload,
                     then: @escaping NetworkCompletion<PostReply>)
    /// Delete user account
    ///
    /// - Parameter then: Completion
    func userDeleteAccount(then: @escaping NetworkCompletion<String>)
    /// Send reset password link
    ///
    /// - Parameters:
    ///   - email: Email
    ///   - then: Completion
    func userForgotPassword(email: String,
                            then: @escaping NetworkCompletion<String>)
    /// Login user
    ///
    /// - Parameters:
    ///   - email: Email
    ///   - password: Password
    ///   - then: Completion
    func userLogin(email: String,
                   password: String,
                   then: @escaping NetworkCompletion<UserJSON>)
    /// Register new user
    ///
    /// - Parameters:
    ///   - payload: RegistrationPayload
    ///   - then: Completion
    func userRegister(payload: RegistrationPayload,
                      then: @escaping NetworkCompletion<UserJSON>)
    /// Update user info
    ///
    /// - Parameters:
    ///   - payload: UserUpdatePayload
    ///   - then: Completion
    func userUpdate(payload: UserUpdatePayload,
                    then: @escaping NetworkCompletion<UserJSON>)
    /// Resend verification email
    ///
    /// - Parameters:
    ///   - id: User ID
    ///   - then: Completion
    func userVerify(id: Int,
                    then: @escaping NetworkCompletion<String>)

    /// Refresh first page of each list's rankings
    func refreshRankings()
    /// Refresh everything
    func refreshEverything()
}

/// Production implementation of NetworkService
class NetworkServiceImpl: NetworkService {

    fileprivate let mtp = MTPNetworkController()
    private var queue = OperationQueue {
        $0.name = "refresh"
        $0.maxConcurrentOperationCount = 1
        $0.qualityOfService = .utility
    }

    fileprivate func refreshData() {
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

    fileprivate func refreshUser() {
        guard data.isLoggedIn else { return }

        mtp.userGetByToken { _ in
            self.refreshUserInfo()
        }
    }

    // MARK: - NetworkService

    /// Load location photos
    ///
    /// - Parameters:
    ///   - id: Location ID
    ///   - reload: Force reload
    ///   - then: Completion
    func loadPhotos(location id: Int,
                    reload: Bool,
                    then: @escaping NetworkCompletion<PhotosInfoJSON>) {
        mtp.loadPhotos(location: id, reload: reload, then: then)
    }

    /// Load logged in user photos
    ///
    /// - Parameters:
    ///   - page: Index
    ///   - reload: Force reload
    ///   - then: Completion
    func loadPhotos(page: Int,
                    reload: Bool,
                    then: @escaping NetworkCompletion<PhotosPageInfoJSON>) {
        mtp.loadPhotos(page: page, reload: reload, then: then)
    }

    /// Load user photos
    ///
    /// - Parameters:
    ///   - id: User ID
    ///   - page: Index
    ///   - reload: Force reload
    ///   - then: Completion
    func loadPhotos(profile id: Int,
                    page: Int,
                    reload: Bool,
                    then: @escaping NetworkCompletion<PhotosPageInfoJSON>) {
        mtp.loadPhotos(profile: id, page: page, reload: reload, then: then)
    }

    /// Load location posts
    ///
    /// - Parameters:
    ///   - id: Location ID
    ///   - then: Completion
    func loadPosts(location id: Int,
                   then: @escaping NetworkCompletion<PostsJSON>) {
        mtp.loadPosts(location: id, then: then)
    }

    /// Load user posts
    ///
    /// - Parameters:
    ///   - id: User ID
    ///   - then: Completion
    func loadPosts(user id: Int, then: @escaping NetworkCompletion<PostsJSON>) {
        mtp.loadPosts(user: id, then: then)
    }

    /// Load rankings
    ///
    /// - Parameters:
    ///   - query: Filter
    ///   - then: Completion
    func loadRankings(query: RankingsQuery,
                      then: @escaping NetworkCompletion<RankingsPageInfoJSON>) {
        mtp.loadRankings(query: query, then: then)
    }

    /// Load scorecard
    ///
    /// - Parameters:
    ///   - list: Checklist
    ///   - id: User ID
    ///   - then: Completion
    func loadScorecard(list: Checklist,
                       user id: Int,
                       then: @escaping NetworkCompletion<ScorecardJSON>) {
        mtp.loadScorecard(list: list, user: id, then: then)
    }

    /// Load user
    ///
    /// - Parameters:
    ///   - id: User ID
    ///   - then: Completion
    func loadUser(id: Int, then: @escaping NetworkCompletion<UserJSON>) {
        mtp.loadUser(id: id, then: then)
    }

    /// Search
    ///
    /// - Parameters:
    ///   - query: Query
    ///   - then: Completion
    func search(query: String,
                then: @escaping NetworkCompletion<SearchResultJSON>) {
        mtp.search(query: query, then: then)
    }

    /// Set places visit status
    ///
    /// - Parameters:
    ///   - items: Places
    ///   - visited: Whether visited
    ///   - then: Completion
    func set(items: [Checklist.Item],
             visited: Bool,
             then: @escaping NetworkCompletion<Bool>) {
        mtp.set(items: items, visited: visited, then: then)
    }

    /// Upload photo
    ///
    /// - Parameters:
    ///   - photo: Data
    ///   - caption: String
    ///   - id: Location ID if any
    ///   - then: Completion
    func upload(photo: Data,
                caption: String?,
                location id: Int?,
                then: @escaping NetworkCompletion<PhotoReply>) {
        mtp.upload(photo: photo, caption: caption, location: id, then: then)
    }

    /// Publish post
    ///
    /// - Parameters:
    ///   - payload: Post payload
    ///   - then: Completion
    func postPublish(payload: PostPayload, then: @escaping NetworkCompletion<PostReply>) {
        mtp.postPublish(payload: payload, then: then)
    }

    /// Delete user account
    ///
    /// - Parameter then: Completion
    func userDeleteAccount(then: @escaping NetworkCompletion<String>) {
        mtp.userDeleteAccount(then: then)
    }

    /// Send reset password link
    ///
    /// - Parameters:
    ///   - email: Email
    ///   - then: Completion
    func userForgotPassword(email: String,
                            then: @escaping NetworkCompletion<String>) {
        mtp.userForgotPassword(email: email, then: then)
    }

    /// Login user
    ///
    /// - Parameters:
    ///   - email: Email
    ///   - password: Password
    ///   - then: Completion
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

    /// Register new user
    ///
    /// - Parameters:
    ///   - payload: RegistrationPayload
    ///   - then: Completion
    func userRegister(payload: RegistrationPayload,
                      then: @escaping NetworkCompletion<UserJSON>) {
        mtp.userRegister(payload: payload, then: then)
    }

    /// Update user info
    ///
    /// - Parameters:
    ///   - payload: UserUpdatePayload
    ///   - then: Completion
    func userUpdate(payload: UserUpdatePayload,
                    then: @escaping NetworkCompletion<UserJSON>) {
        mtp.userUpdate(payload: payload, then: then)
    }

    /// Resend verification email
    ///
    /// - Parameters:
    ///   - id: User ID
    ///   - then: Completion
    func userVerify(id: Int,
                    then: @escaping NetworkCompletion<String>) {
        mtp.userVerify(id: id, then: then)
    }

    /// Refresh first page of each list's rankings
    func refreshRankings() {
        Checklist.allCases.forEach { list in
            var query = data.lastRankingsQuery
            query.checklistKey = list.key
            add { done in self.mtp.loadRankings(query: query) { _ in done() } }
        }
    }

    /// Refresh everything
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

// MARK: - Testing

#if DEBUG

/// Stub for testing
final class NetworkServiceStub: NetworkServiceImpl {

    override fileprivate func refreshData() {
        // expect seeded
    }

    override fileprivate func refreshUser() {
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

    /// Refresh first page of each list's rankings
    override func refreshRankings() {
        // expect seeded
    }

    /// Load location photos
    ///
    /// - Parameters:
    ///   - id: Location ID
    ///   - reload: Force reload
    ///   - then: Completion
    override func loadPhotos(location id: Int,
                             reload: Bool,
                             then: @escaping NetworkCompletion<PhotosInfoJSON>) {
        log.error("not stubbed yet!")
        then(.failure(.message("not stubbed yet!")))
    }

    /// Load logged in user photos
    ///
    /// - Parameters:
    ///   - page: Index
    ///   - reload: Force reload
    ///   - then: Completion
    override func loadPhotos(page: Int,
                             reload: Bool,
                             then: @escaping NetworkCompletion<PhotosPageInfoJSON>) {
        mtp.loadPhotos(page: page,
                       reload: reload,
                       stub: MTPProvider.immediatelyStub,
                       then: then)
    }

    /// Load user photos
    ///
    /// - Parameters:
    ///   - id: User ID
    ///   - page: Index
    ///   - reload: Force reload
    ///   - then: Completion
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

    /// Load location posts
    ///
    /// - Parameters:
    ///   - id: Location ID
    ///   - then: Completion
    override func loadPosts(location id: Int,
                            then: @escaping NetworkCompletion<PostsJSON>) {
        log.error("not stubbed yet!")
        then(.failure(.message("not stubbed yet!")))
    }

    /// Load user posts
    ///
    /// - Parameters:
    ///   - id: User ID
    ///   - then: Completion
    override func loadPosts(user id: Int,
                            then: @escaping NetworkCompletion<PostsJSON>) {
        mtp.loadPosts(user: id,
                      stub: MTPProvider.immediatelyStub,
                      then: then)
    }

    /// Load rankings
    ///
    /// - Parameters:
    ///   - query: Filter
    ///   - then: Completion
    override func loadRankings(query: RankingsQuery,
                               then: @escaping NetworkCompletion<RankingsPageInfoJSON>) {
        mtp.loadRankings(query: query,
                         stub: MTPProvider.immediatelyStub,
                         then: then)
    }

    /// Load scorecard
    ///
    /// - Parameters:
    ///   - list: Checklist
    ///   - id: User ID
    ///   - then: Completion
    override func loadScorecard(list: Checklist,
                                user id: Int,
                                then: @escaping NetworkCompletion<ScorecardJSON>) {
        mtp.loadScorecard(list: list,
                          user: id,
                          stub: MTPProvider.immediatelyStub,
                          then: then)
    }

    /// Load user
    ///
    /// - Parameters:
    ///   - id: User ID
    ///   - then: Completion
    override func loadUser(id: Int,
                           then: @escaping NetworkCompletion<UserJSON>) {
        mtp.loadUser(id: id,
                     stub: MTPProvider.immediatelyStub,
                     then: then)
    }

    /// Search
    ///
    /// - Parameters:
    ///   - query: Query
    ///   - then: Completion
    override func search(query: String,
                         then: @escaping NetworkCompletion<SearchResultJSON>) {
        log.error("not stubbed yet!")
        then(.failure(.message("not stubbed yet!")))
    }

    /// Set places visit status
    ///
    /// - Parameters:
    ///   - items: Places
    ///   - visited: Whether visited
    ///   - then: Completion
    override func set(items: [Checklist.Item],
                      visited: Bool,
                      then: @escaping NetworkCompletion<Bool>) {
        log.error("not stubbed yet!")
        then(.failure(.message("not stubbed yet!")))
    }

    /// Upload photo
    ///
    /// - Parameters:
    ///   - photo: Data
    ///   - caption: String
    ///   - id: Location ID if any
    ///   - then: Completion
    override func upload(photo: Data,
                         caption: String?,
                         location id: Int?,
                         then: @escaping NetworkCompletion<PhotoReply>) {
        log.error("not stubbed yet!")
        then(.failure(.message("not stubbed yet!")))
    }

    /// Publish post
    ///
    /// - Parameters:
    ///   - payload: Post payload
    ///   - then: Completion
    override func postPublish(payload: PostPayload,
                              then: @escaping NetworkCompletion<PostReply>) {
        log.error("not stubbed yet!")
        then(.failure(.message("not stubbed yet!")))
    }

    /// Delete user account
    ///
    /// - Parameter then: Completion
    override func userDeleteAccount(then: @escaping NetworkCompletion<String>) {
        log.error("not stubbed yet!")
        then(.failure(.message("not stubbed yet!")))
    }

    /// Send reset password link
    ///
    /// - Parameters:
    ///   - email: Email
    ///   - then: Completion
    override func userForgotPassword(email: String,
                                     then: @escaping NetworkCompletion<String>) {
        log.error("not stubbed yet!")
        then(.failure(.message("not stubbed yet!")))
    }

    /// Login user
    ///
    /// - Parameters:
    ///   - email: Email
    ///   - password: Password
    ///   - then: Completion
    override func userLogin(email: String,
                            password: String,
                            then: @escaping NetworkCompletion<UserJSON>) {
        log.error("not stubbed yet!")
        then(.failure(.message("not stubbed yet!")))
    }

    /// Register new user
    ///
    /// - Parameters:
    ///   - payload: RegistrationPayload
    ///   - then: Completion
    override func userRegister(payload: RegistrationPayload,
                               then: @escaping NetworkCompletion<UserJSON>) {
        log.error("not stubbed yet!")
        then(.failure(.message("not stubbed yet!")))
    }

    /// Update user info
    ///
    /// - Parameters:
    ///   - payload: UserUpdatePayload
    ///   - then: Completion
    override func userUpdate(payload: UserUpdatePayload,
                             then: @escaping NetworkCompletion<UserJSON>) {
        log.error("not stubbed yet!")
        then(.failure(.message("not stubbed yet!")))
    }

    /// Resend verification email
    ///
    /// - Parameters:
    ///   - id: User ID
    ///   - then: Completion
    override func userVerify(id: Int,
                             then: @escaping NetworkCompletion<String>) {
        log.error("not stubbed yet!")
        then(.failure(.message("not stubbed yet!")))
    }
}

#endif
