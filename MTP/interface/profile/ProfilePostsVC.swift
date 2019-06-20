// @copyright Trollwerks Inc.

import UIKit

final class ProfilePostsVC: PostsVC, UserInjectable {

    override var posts: [Post] {
        guard let id = user?.id else { return [] }

        return data.getPosts(user: id)
    }

    override var source: DataServiceChange {
        return .posts
    }

    private var user: User?
    private var isSelf: Bool = false

    override var canCreate: Bool {
        return isSelf
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()
    }
}

extension ProfilePostsVC: Injectable {

    typealias Model = User

    @discardableResult func inject(model: Model) -> Self {
        user = model
        isSelf = model.id == data.user?.id

        mtp.loadPosts(user: model.id) { _ in }

        return self
    }

    func requireInjections() {
        user.require()
    }
}
