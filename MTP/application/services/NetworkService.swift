// @copyright Trollwerks Inc.

import Moya

// swiftlint:disable file_length

/// Errors provided by network
enum NetworkError: Swift.Error {

    /// unknown
    case unknown
    /// decoding
    case decoding(String)
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
    /// queued
    case queued
    /// serverOffline
    case serverOffline
    /// status
    case status(Int)
    /// throttle
    case throttle
    /// token
    case token
}

/// Generic NetworkService completion handler
typealias NetworkCompletion<T> = (_ result: Result<T, NetworkError>) -> Void

/// Provides network-related functionality
protocol NetworkService: Observable, ServiceProvider {

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
    /// Update user token
    ///
    /// - Parameters:
    ///   - token: String
    ///   - then: Completion
    func userUpdate(token: String,
                    then: @escaping NetworkCompletion<UserTokenReply>)
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

    /// Reset all networking
    func logout()

    /// Direct accessor for connection status
    var isConnected: Bool { get }

    /// Direct accessor for queued requests
    var requests: [OfflineRequest] { get }

    /// Direct accessor for network controller
    var mtp: MTPNetworkController { get }
}

/// Production implementation of NetworkService
class NetworkServiceImpl: NetworkService {

    /// Direct accessor for connection status
    var isConnected: Bool { return offlineRequestManager.connected }

    /// Direct accessor for queued requests
    var requests: [OfflineRequest] { return offlineRequestManager.requests }

    /// Direct accessor for network controller
    let mtp: MTPNetworkController

    private var queue = OperationQueue {
        $0.name = "refresh"
        $0.maxConcurrentOperationCount = 1
        $0.qualityOfService = .utility
    }
    private lazy var offlineRequestManager: OfflineRequestManager = {
        let manager: OfflineRequestManager
        if UIApplication.isTesting {
            manager = OfflineRequestManager.manager(withFileName: "test_manager")
        } else {
            manager = OfflineRequestManager.defaultManager
        }
        manager.simultaneousRequestCap = 1
        manager.submissionInterval = 60
        return manager
    }()

    /// Construction by injection
    ///
    /// - Parameter controller: MTPNetworkController
    init(controller: MTPNetworkController = MTPNetworkController()) {
        mtp = controller
        offlineRequestManager.delegate = self
    }

    fileprivate func refreshData() {
        guard !isThrottled(last: lastRefreshData, wait: .data) else { return }

        lastRefreshData = Date()

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
        guard data.isLoggedIn,
              !isThrottled(last: lastRefreshUser, wait: .user) else { return }

        lastRefreshUser = Date()
        mtp.userGetByToken(reload: false) { _ in
            self.refreshUserInfo()
        }
    }

    fileprivate enum Refresh: TimeInterval {
        case data = 86_400 // 24 * 60 * 60
        case rankings = 600 // 10 * 60
        case user = 300 // 5 * 60
    }
    private var lastRefreshUser: Date?
    private var lastRefreshData: Date?
    private var lastRefreshRankings: Date?

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
        for item in items {
            let request = MTPVisitedRequest(item: item,
                                            visited: visited)
            if !offlineRequestManager.connected {
                request.failed()
            }
            offlineRequestManager.queueRequest(request)
        }
        then(.failure(.queued))
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
    func postPublish(payload: PostPayload,
                     then: @escaping NetworkCompletion<PostReply>) {
        let request = MTPPostRequest(payload: payload)
        if !offlineRequestManager.connected {
            request.failed()
        }
        offlineRequestManager.queueRequest(request)
        then(.failure(.queued))
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

    /// Update user token
    ///
    /// - Parameters:
    ///   - token: String
    ///   - then: Completion
    func userUpdate(token: String,
                    then: @escaping NetworkCompletion<UserTokenReply>) {
        mtp.userUpdate(token: token, then: then)
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
        guard !isThrottled(last: lastRefreshRankings, wait: .rankings) else { return }

        lastRefreshRankings = Date()
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

    /// Reset all networking
    func logout() {
        offlineRequestManager.clearAllRequests()
        MTP.unthrottle()
        lastRefreshUser = nil
    }
}

// MARK: - OfflineRequestManagerDelegate

extension NetworkServiceImpl: OfflineRequestManagerDelegate {

    /// Method that the delegate uses to generate OfflineRequest objects from dictionaries written to disk
    ///
    /// - Parameter dictionary: dictionary saved to disk associated with an unfinished request
    /// - Returns: OfflineRequest object to be queued
    func offlineRequest(withDictionary dictionary: [String: Any]) -> OfflineRequest? {
        return MTPVisitedRequest(dictionary: dictionary)
    }

    /// Callback indicating the OfflineRequestManager's current progress
    ///
    /// - Parameters:
    ///   - manager: OfflineRequestManager instance
    ///   - progress: current progress for all ongoing requests (ranges from 0 to 1)
    func offlineRequestManager(_ manager: OfflineRequestManager,
                               didUpdateProgress progress: Double) {
        notify(observers: NetworkServiceChange.progress.rawValue,
               info: [ StatusKey.value.rawValue: progress ])
    }

    /// Callback indicating the OfflineRequestManager's current connection status
    ///
    /// - Parameters:
    ///   - manager: OfflineRequestManager instance
    ///   - connected: value indicating whether there is currently connectivity
    func offlineRequestManager(_ manager: OfflineRequestManager,
                               didUpdateConnectionStatus connected: Bool) {
        notify(observers: NetworkServiceChange.connection.rawValue,
               info: [ StatusKey.value.rawValue: connected ])
    }

    /// Callback that can be used to block a request attempt
    ///
    ///   - manager: OfflineRequestManager instance
    ///   - request: OfflineRequest to be performed
    /// - Returns: value indicating whether the OfflineRequestManager should move forward with the request attempt
    func offlineRequestManager(_ manager: OfflineRequestManager,
                               shouldAttemptRequest request: OfflineRequest) -> Bool {
        return true
    }

    /// Callback to reconfigure and reattempt an OfflineRequest
    /// after a failure not related to connectivity issues
    ///
    /// - Parameters:
    ///   - manager: OfflineRequestManager instance
    ///   - request: OfflineRequest that failed
    ///   - error: NSError associated with the failure
    /// - Returns: value indicating whether the OfflineRequestManager should reattempt the OfflineRequest action
    func offlineRequestManager(_ manager: OfflineRequestManager,
                               shouldReattemptRequest request: OfflineRequest,
                               withError error: Error) -> Bool {
        return true
    }

    /// Callback indicating that the OfflineRequest action has started
    ///
    /// - Parameters:
    ///   - manager: OfflineRequestManager instance
    ///   - request: OfflineRequest that started its action
    func offlineRequestManager(_ manager: OfflineRequestManager,
                               didStartRequest request: OfflineRequest) {
        notify(observers: NetworkServiceChange.requests.rawValue,
               info: [ StatusKey.value.rawValue: manager ])
    }

    /// Callback indicating that the OfflineRequest status has changed
    ///
    /// - Parameters:
    ///   - manager: OfflineRequestManager instance
    ///   - request: OfflineRequest that changed its subtitle
    func offlineRequestManager(_ manager: OfflineRequestManager,
                               didUpdateRequest request: OfflineRequest) {
        notify(observers: NetworkServiceChange.requests.rawValue,
               info: [ StatusKey.value.rawValue: manager ])
    }

    /// Callback indicating that the OfflineRequest action has successfully finished
    ///
    /// - Parameters:
    ///   - manager: OfflineRequestManager instance
    ///   - request: OfflineRequest that finished its action
    func offlineRequestManager(_ manager: OfflineRequestManager,
                               didFinishRequest request: OfflineRequest) {
        notify(observers: NetworkServiceChange.requests.rawValue,
               info: [ StatusKey.value.rawValue: manager ])
        if let request = request as? MTPVisitedRequest {
            mtp.userGetByToken(reload: true) { _ in }
            data.delete(rankings: request.checklist)
        }
    }

    /// Callback indicating that the OfflineRequest action has failed for reasons unrelated to connectivity
    ///
    /// - Parameters:
    ///   - manager: OfflineRequestManager instance
    ///   - request: OfflineRequest that failed
    ///   - error: NSError associated with the failure
    func offlineRequestManager(_ manager: OfflineRequestManager,
                               requestDidFail request: OfflineRequest,
                               withError error: Error) {
        notify(observers: NetworkServiceChange.requests.rawValue,
               info: [ StatusKey.value.rawValue: manager ])
    }
}

// MARK: - Private

private extension NetworkServiceImpl {

    func isThrottled(last: Date?, wait: Refresh) -> Bool {
        guard let last = last else {
            return false
        }

        let next = last.addingTimeInterval(wait.rawValue)
        guard next <= Date() else { return true }
        return false
    }

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

/// :nodoc:
final class NetworkServiceStub: NetworkServiceImpl {

    override fileprivate func refreshData() {
        // expect seeded
    }

    override fileprivate func refreshUser() {
        mtp.userGetByToken(reload: false,
                           stub: MTPProvider.immediatelyStub) { _ in }
        guard let user = data.user else { return }

        mtp.loadChecklists(stub: MTPProvider.immediatelyStub) { _ in }
        loadPosts(user: user.id) { _ in }
        loadPhotos(profile: user.id, page: 1, reload: false) { _ in }
        Checklist.allCases.forEach { list in
            loadScorecard(list: list,
                          user: user.id) { _ in }
        }
    }

    /// :nodoc:
    override func refreshRankings() {
        // expect seeded
    }

    /// :nodoc:
    override func loadPhotos(location id: Int,
                             reload: Bool,
                             then: @escaping NetworkCompletion<PhotosInfoJSON>) {
        mtp.loadPhotos(location: id,
                       reload: reload,
                       stub: MTPProvider.immediatelyStub,
                       then: then)
    }

    /// :nodoc:
    override func loadPhotos(page: Int,
                             reload: Bool,
                             then: @escaping NetworkCompletion<PhotosPageInfoJSON>) {
        mtp.loadPhotos(page: page,
                       reload: reload,
                       stub: MTPProvider.immediatelyStub,
                       then: then)
    }

    /// :nodoc:
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

    /// :nodoc:
    override func loadPosts(location id: Int,
                            then: @escaping NetworkCompletion<PostsJSON>) {
        mtp.loadPosts(location: id,
                      stub: MTPProvider.immediatelyStub,
                      then: then)
    }

    /// :nodoc:
    override func loadPosts(user id: Int,
                            then: @escaping NetworkCompletion<PostsJSON>) {
        mtp.loadPosts(user: id,
                      stub: MTPProvider.immediatelyStub,
                      then: then)
    }

    /// :nodoc:
    override func loadRankings(query: RankingsQuery,
                               then: @escaping NetworkCompletion<RankingsPageInfoJSON>) {
        mtp.loadRankings(query: query,
                         stub: MTPProvider.immediatelyStub,
                         then: then)
    }

    /// :nodoc:
    override func loadScorecard(list: Checklist,
                                user id: Int,
                                then: @escaping NetworkCompletion<ScorecardJSON>) {
        mtp.loadScorecard(list: list,
                          user: id,
                          stub: MTPProvider.immediatelyStub,
                          then: then)
    }

    /// :nodoc:
    override func loadUser(id: Int,
                           then: @escaping NetworkCompletion<UserJSON>) {
        mtp.loadUser(id: id,
                     stub: MTPProvider.immediatelyStub,
                     then: then)
    }

    /// :nodoc:
    override func search(query: String,
                         then: @escaping NetworkCompletion<SearchResultJSON>) {
        mtp.search(query: query,
                   stub: MTPProvider.immediatelyStub,
                   then: then)
    }

    /// :nodoc:
    override func set(items: [Checklist.Item],
                      visited: Bool,
                      then: @escaping NetworkCompletion<Bool>) {
        mtp.set(items: items,
                visited: visited,
                stub: MTPProvider.immediatelyStub,
                then: then)
    }

    /// :nodoc:
    override func upload(photo: Data,
                         caption: String?,
                         location id: Int?,
                         then: @escaping NetworkCompletion<PhotoReply>) {
        mtp.upload(photo: photo,
                   caption: caption,
                   location: id,
                   stub: MTPProvider.immediatelyStub,
                   then: then)
    }

    /// :nodoc:
    override func postPublish(payload: PostPayload,
                              then: @escaping NetworkCompletion<PostReply>) {
        mtp.postPublish(payload: payload,
                        stub: MTPProvider.immediatelyStub,
                        then: then)
    }

    /// :nodoc:
    override func userDeleteAccount(then: @escaping NetworkCompletion<String>) {
        mtp.userDeleteAccount(stub: MTPProvider.immediatelyStub,
                              then: then)
    }

    /// :nodoc:
    override func userForgotPassword(email: String,
                                     then: @escaping NetworkCompletion<String>) {
        mtp.userForgotPassword(email: email,
                               stub: MTPProvider.immediatelyStub,
                               then: then)
    }

    /// :nodoc:
    override func userLogin(email: String,
                            password: String,
                            then: @escaping NetworkCompletion<UserJSON>) {
        mtp.userLogin(email: email,
                      password: password,
                      stub: MTPProvider.immediatelyStub,
                      then: then)
    }

    /// :nodoc:
    override func userRegister(payload: RegistrationPayload,
                               then: @escaping NetworkCompletion<UserJSON>) {
        mtp.userRegister(payload: payload,
                         stub: MTPProvider.immediatelyStub,
                         then: then)
    }

    /// :nodoc:
    override func userUpdate(payload: UserUpdatePayload,
                             then: @escaping NetworkCompletion<UserJSON>) {
        mtp.userUpdate(payload: payload,
                       stub: MTPProvider.immediatelyStub,
                       then: then)
    }

    /// :nodoc:
    override func userUpdate(token: String,
                             then: @escaping NetworkCompletion<UserTokenReply>) {
        mtp.userUpdate(token: token,
                       stub: MTPProvider.immediatelyStub,
                       then: then)
    }

    /// :nodoc:
    override func userVerify(id: Int,
                             then: @escaping NetworkCompletion<String>) {
        mtp.userVerify(id: id,
                       stub: MTPProvider.immediatelyStub,
                       then: then)
    }
}

#endif
