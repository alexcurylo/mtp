// @copyright Trollwerks Inc.

import Foundation
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

class NetworkServiceImpl {

    let mtp = MTPNetworkController()

    private var queue = OperationQueue {
        $0.name = "refresh"
        $0.maxConcurrentOperationCount = 1
        $0.qualityOfService = .utility
    }

    // MARK: - Overriden in NetworkServiceStub

    func refreshUser() {
        guard data.isLoggedIn else { return }

        mtp.userGetByToken { _ in
            self.refreshUserInfo()
        }
    }
}

// MARK: - NetworkService

extension NetworkServiceImpl: NetworkService {

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

    func refreshEverything() {
        refreshUser()
        refreshData()
        refreshRankings()
    }

    func refreshRankings() {
        var query = data.lastRankingsQuery
        Checklist.allCases.forEach { list in
            query.checklistKey = list.key
            add { done in self.mtp.loadRankings(query: query) { _ in done() } }
        }
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
        add { done in self.mtp.loadChecklists { _ in done() } }
        add { done in self.mtp.loadChecklists { _ in done() } }
        Checklist.allCases.forEach { list in
            add { done in self.mtp.loadScorecard(list: list, user: user.id) { _ in done() } }
        }
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
}

final class NetworkServiceStub: NetworkServiceImpl {

    override func refreshUser() {
        mtp.userGetByToken(stub: MTPProvider.immediatelyStub) { _ in
            self.refreshUserInfo()
        }
    }
}
