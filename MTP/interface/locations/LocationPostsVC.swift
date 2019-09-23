// @copyright Trollwerks Inc.

import UIKit

/// Display a location's posts
final class LocationPostsVC: PostsVC {

    private typealias Segues = R.segue.locationPostsVC

    /// Can create new content
    override var canCreate: Bool {
        return isImplemented
    }
    private var isImplemented: Bool {
        return mappable?.checklist == .locations
    }

    /// Type of view presenting this controller
    override var presenter: Presenter {
        return .location
    }

    private var postsObserver: Observer?
    private var locationPostsObserver: Observer?
    private var blockedUsersObserver: Observer?
    private var blockedPostsObserver: Observer?
    private var updated = false

    private var profileModel: UserProfileVC.Model?

    // verified in requireInjection
    private var mappable: Mappable!
    // swiftlint:disable:previous implicitly_unwrapped_optional

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjection()

        update()
    }

    /// Instrument and inject navigation
    ///
    /// - Parameters:
    ///   - segue: Navigation action
    ///   - sender: Action originator
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let edit = Segues.addPost(segue: segue)?
                            .destination {
            edit.inject(model: mappable)
        } else if let profile = Segues.showUserProfile(segue: segue)?
                                      .destination,
                  let profileModel = profileModel {
            profile.inject(model: profileModel)
        }
    }

    /// Create a new post
    override func createPost() {
        performSegue(withIdentifier: Segues.addPost,
                     sender: self)
    }

    /// Present user profile
    ///
    /// - Parameter user: User to present
    override func show(user: User) {
        profileModel = user
        performSegue(withIdentifier: Segues.showUserProfile, sender: self)
    }
}

// MARK: - Private

private extension LocationPostsVC {

    func loaded() {
        updated = true
        update()
        observe()
    }

    func update() {
        guard isImplemented else {
            contentState = .unknown
            tableView.set(message: L.unimplemented(), color: .darkText)
            return
        }

        let posts = data.get(locationPosts: mappable.checklistId)
        models = cellModels(from: posts)
        tableView.reloadData()

        if !models.isEmpty {
            contentState = .data
        } else {
            contentState = updated ? .empty : .loading
        }
        tableView.set(message: contentState, color: .darkText)
    }

    func observe() {
        guard postsObserver == nil else { return }

        postsObserver = data.observer(of: .posts) { [weak self] _ in
            self?.update()
        }
        locationPostsObserver = data.observer(of: .locationPosts) { [weak self] _ in
            self?.update()
        }
        blockedPostsObserver = data.observer(of: .blockedPosts) { [weak self] _ in
             self?.update()
        }
        blockedUsersObserver = data.observer(of: .blockedUsers) { [weak self] _ in
             self?.update()
        }
    }
}

// MARK: - Injectable

extension LocationPostsVC: Injectable {

    /// Injected dependencies
    typealias Model = Mappable

    /// Handle dependency injection
    ///
    /// - Parameter model: Dependencies
    func inject(model: Model) {
        mappable = model

        if isImplemented {
            net.loadPosts(location: model.checklistId) { [weak self] _ in
                self?.loaded()
            }
        }
    }

    /// Enforce dependency injection
    func requireInjection() {
        mappable.require()
    }
}
