// @copyright Trollwerks Inc.

import UIKit

/// Display a user's posts
final class ProfilePostsVC: PostsVC, UserInjectable {

    private typealias Segues = R.segue.profilePostsVC

    private var postsObserver: Observer?
    private var blockedPostsObserver: Observer?
    private var isLoading = true

    // verified in requireInjection
    private var user: User!
    // swiftlint:disable:previous implicitly_unwrapped_optional

    private var isSelf: Bool = false

    /// Whether user can add a new post
    override var canCreate: Bool {
        return isSelf
    }

    /// Whether a new post is queued to upload
    override var isQueued: Bool {
        return isSelf && !queuedPosts.isEmpty
    }

    /// Type of view presenting this controller
    override var presenter: Presenter {
        return .user
    }

    /// :nodoc:
    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjection()

        update()
    }

    /// Create a new post
    override func createPost() {
        performSegue(withIdentifier: Segues.addPost,
                     sender: self)
    }

    /// Update contents
    override func update() {
        super.update()

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
}

// MARK: - Private

private extension ProfilePostsVC {

    func loaded() {
        isLoading = false
        update()
        observe()
    }

    func observe() {
        guard postsObserver == nil else { return }

        postsObserver = data.observer(of: .posts) { [weak self] _ in
            self?.update()
        }
        blockedPostsObserver = data.observer(of: .blockedPosts) { [weak self] _ in
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
    func inject(model: Model) {
        user = model
        isSelf = model.isSelf

        net.loadPosts(user: model.userId,
                      reload: false) { [weak self] _ in
            self?.loaded()
        }
    }

    /// Enforce dependency injection
    func requireInjection() {
        user.require()
    }
}
