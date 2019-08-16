// @copyright Trollwerks Inc.

import UIKit

/// Display a user's posts
final class ProfilePostsVC: PostsVC, UserInjectable {

    private typealias Segues = R.segue.profilePostsVC

    private var postsObserver: Observer?
    private var isLoading = true

    private var user: User?
    private var isSelf: Bool = false

    /// Can create new content
    override var canCreate: Bool {
        return isSelf
    }

    /// Type of view presenting this controller
    override var presenter: Presenter {
        return .user
    }

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        update()
    }

    /// Create a new post
    override func createPost() {
        performSegue(withIdentifier: Segues.addPost,
                     sender: self)
    }
}

// MARK: - Private

private extension ProfilePostsVC {

    func loaded() {
        isLoading = false
        update()
        observe()
    }

    func update() {
        guard let user = user else { return }

        let posts = data.getPosts(user: user.userId)
        models = cellModels(from: posts)
        tableView.reloadData()

        if !models.isEmpty {
            contentState = .data
        } else {
            contentState = isLoading ? .loading : .empty
        }
        tableView.set(message: contentState, color: .darkText)
    }

    func observe() {
        guard postsObserver == nil else { return }

        postsObserver = data.observer(of: .posts) { [weak self] _ in
            self?.update()
        }
    }
}

// MARK: - Injectable

extension ProfilePostsVC: Injectable {

    /// Injected dependencies
    typealias Model = User

    /// Handle dependency injection
    ///
    /// - Parameter model: Dependencies
    /// - Returns: Chainable self
    @discardableResult func inject(model: Model) -> Self {
        user = model
        isSelf = model.isSelf

        net.loadPosts(user: model.userId) { [weak self] _ in
            self?.loaded()
        }

        return self
    }

    /// Enforce dependency injection
    func requireInjections() {
        user.require()
    }
}
