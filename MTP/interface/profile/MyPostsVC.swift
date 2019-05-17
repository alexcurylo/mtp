// @copyright Trollwerks Inc.

import UIKit

final class MyPostsVC: PostsVC {

    override var posts: [Post] {
        return data.posts
    }

    override var source: DataServiceChange {
        return .posts
    }
}
