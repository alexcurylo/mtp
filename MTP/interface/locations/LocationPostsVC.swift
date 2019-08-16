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
    private var updated = false

    private var profileModel: UserProfileVC.Model?

    //swiftlint:disable:next implicitly_unwrapped_optional
    private var mappable: Mappable!

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

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
        guard let mappable = mappable else { return }

        guard isImplemented else {
            contentState = .unimplemented
            tableView.set(message: contentState, color: .darkText)
            return
        }

        let posts = data.get(locationPosts: mappable.checklistId)
        models = cellModels(from: posts)
        tableView.reloadData()

        if !models.isEmpty {
            contentState = .data
        } else if !isImplemented {
            contentState = .unimplemented
        } else {
            contentState = updated ? .empty : .loading
        }
        tableView.set(message: contentState, color: .darkText)
    }

    func observe() {
        guard postsObserver == nil else { return }

        postsObserver = data.observer(of: .locationPosts) { [weak self] _ in
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
    /// - Returns: Chainable self
    @discardableResult func inject(model: Model) -> Self {
        mappable = model

        if isImplemented {
            net.loadPosts(location: model.checklistId) { [weak self] _ in
                self?.loaded()
            }
        }

        return self
    }

    /// Enforce dependency injection
    func requireInjections() {
        mappable.require()
    }
}
