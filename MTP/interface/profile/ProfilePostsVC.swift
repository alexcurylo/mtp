// @copyright Trollwerks Inc.

import UIKit

final class ProfilePostsVC: PostsVC, UserInjectable {

    private typealias Segues = R.segue.profilePostsVC

    private var postsObserver: Observer?
    private var isLoading = true

    private var user: User?
    private var isSelf: Bool = false

    override var canCreate: Bool {
        return isSelf
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        update()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.addPost.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }

    override func createPost() {
        performSegue(withIdentifier: Segues.addPost,
                     sender: self)
    }
}

private extension ProfilePostsVC {

    func loaded() {
        isLoading = false
        update()
        observe()
    }

    func update() {
        guard let user = user else { return }

        let posts = data.getPosts(user: user.id)
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

extension ProfilePostsVC: Injectable {

    typealias Model = User

    @discardableResult func inject(model: Model) -> Self {
        user = model
        isSelf = model.id == data.user?.id

        mtp.loadPosts(user: model.id) { [weak self] _ in
            self?.loaded()
        }

        return self
    }

    func requireInjections() {
        user.require()
    }
}
