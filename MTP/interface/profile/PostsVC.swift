// @copyright Trollwerks Inc.

import Anchorage

/// Base class for user and location post pages
class PostsVC: UITableViewController {

    /// Whether user can add a new post
    var canCreate: Bool {
        return false
    }

    /// Whether a new post is queued to upload
    var isQueued: Bool {
        return false
    }

    /// Post to be edited in Add screen
    var injectPost: PostCellModel?

    /// Type of view presenting this controller
    var presenter: Presenter {
        fatalError("presenter has not been overridden")
    }

    /// Edit or create a new Post
    func add(post: PostCellModel?) {
        // swiftlint:disable:previous unavailable_function
        fatalError("add(post:) has not been overridden")
    }

    /// Present user profile
    ///
    /// - Parameter user: User to present
    func show(user: User) {
        // override to implement
    }

    /// Content state to display
    var contentState: ContentState = .loading
    /// Data models
    var models: [PostCellModel] = []
    /// Filtered queued network actions
    var queuedPosts: [MTPPostRequest] = []
    private var requestsObserver: Observer?
    private var headerModel: PostHeader.Model = (false, false) {
        didSet {
            if headerModel != oldValue {
                tableView.reloadData()
            }
        }
    }

    private let layout = (row: CGFloat(100),
                          header: (create: CGFloat(50),
                                   queued: CGFloat(100)))

    /// :nodoc:
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundView = UIView { $0.backgroundColor = .clear }
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = layout.row
        tableView.rowHeight = UITableView.automaticDimension
        if canCreate {
            tableView.estimatedSectionHeaderHeight = headerHeight
            tableView.sectionHeaderHeight = UITableView.automaticDimension

            tableView.register(
                PostHeader.self,
                forHeaderFooterViewReuseIdentifier: PostHeader.reuseIdentifier
            )
        } else {
            tableView.estimatedSectionHeaderHeight = 1
            tableView.sectionHeaderHeight = 1
        }
        UIPosts.posts.expose(item: tableView)

        /// expect descendants to call update() at end
    }

    /// Construct cell models
    ///
    /// - Parameter posts: List of posts
    /// - Returns: List of displayable models
    func cellModels(from posts: [Post]) -> [PostCellModel] {
        let blockedPosts = data.blockedPosts
        let blockedUsers = data.blockedUsers
        var index = 0
        // swiftlint:disable:next closure_body_length
        let cellModels: [PostCellModel] = posts.compactMap { post in
            guard !blockedPosts.contains(post.postId),
                  !blockedUsers.contains(post.userId) else { return nil }

            let location = data.get(location: post.locationId)
            let user = data.get(user: post.userId)
            let title: String
            switch presenter {
            case .location:
                title = user?.fullName ?? L.loading()
            case .user:
                title = location?.placeTitle ?? L.unknown()
            }
            let model = PostCellModel(
                index: index,
                date: DateFormatter.mtpPost.string(from: post.updatedAt).uppercased(),
                title: title,
                body: post.post,
                postId: post.postId,
                presenter: presenter,
                location: location,
                user: user,
                isExpanded: false
            )
            index += 1
            return model
        }
        return cellModels
    }

    /// Track queued posts for possible display
    /// Expect descendants to call update() at end of viewDidLoad()
    func update() {
        queuedPosts = net.requests.of(type: MTPPostRequest.self)
        headerModel = (add: canCreate, queue: isQueued)

        observeRequests()
    }
}

// MARK: - UITableViewControllerDataSource

extension PostsVC: PostHeaderDelegate {

    func addTapped() {
        add(post: nil)
    }

    func queueTapped() {
        app.route(to: .network)
    }
}

// MARK: - UITableViewControllerDataSource

extension PostsVC {

    /// :nodoc:
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    /// :nodoc:
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return models.count
    }

    /// :nodoc:
    override func tableView(_ tableView: UITableView,
                            viewForHeaderInSection section: Int) -> UIView? {
        guard canCreate else { return UIView() }

        let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: PostHeader.reuseIdentifier) as? PostHeader

        header?.inject(model: headerModel,
                       delegate: self)

        return header
     }

    /// :nodoc:
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable:next implicitly_unwrapped_optional
        let cell: PostCell! = tableView.dequeueReusableCell(
            withIdentifier: R.reuseIdentifier.postCell,
            for: indexPath)

        cell.inject(model: models[indexPath.row],
                    delegate: self)

        return cell
    }
}

// MARK: - UITableViewDelegate

extension PostsVC {

    /// :nodoc:
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    /// :nodoc:
    override func tableView(_ tableView: UITableView,
                            heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }

    /// :nodoc:
    override func tableView(_ tableView: UITableView,
                            estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }

    /// :nodoc:
    override func tableView(_ tableView: UITableView,
                            shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        configure(menu: models[indexPath.row])
        return true
    }

    /// :nodoc:
    override func tableView(_ tableView: UITableView,
                            canPerformAction action: Selector,
                            forRowAt indexPath: IndexPath,
                            withSender sender: Any?) -> Bool {
        return MenuAction.isContent(action: action)
    }

    /// :nodoc:
    override func tableView(_ tableView: UITableView,
                            performAction action: Selector,
                            forRowAt indexPath: IndexPath,
                            withSender sender: Any?) {
        // Required to be present but only triggers for standard items
    }
}

// MARK: - PostCellDelegate

extension PostsVC: PostCellDelegate {

    /// :nodoc:
    func tapped(profile user: User) {
        show(user: user)
    }

    /// :nodoc:
    func tapped(toggle: Int) {
        guard toggle < models.count else { return }

        models[toggle].isExpanded.toggle()
        let path = IndexPath(row: toggle, section: 0)
        tableView.update {
            tableView.reloadRows(at: [path], with: .none)
        }
    }

    /// :nodoc:
    func tapped(hide: PostCellModel?) {
        data.block(post: hide?.postId ?? 0)
    }

    /// :nodoc:
    func tapped(report: PostCellModel?) {
        let message = L.reportPost(report?.postId ?? 0)
        app.route(to: .reportContent(message))
    }

    /// :nodoc:
    func tapped(block: PostCellModel?) {
        if data.block(user: block?.user?.userId ?? 0) {
            app.dismissPresentations()
        }
    }

    /// :nodoc:
    func tapped(edit: PostCellModel?) {
        add(post: edit)
    }

    /// :nodoc:
    func tapped(delete: PostCellModel?) {
        guard let delete = delete else { return }
        let postId = delete.postId
        let userId = delete.user?.userId ?? 0
        let locationId = delete.location?.placeId ?? 0

        net.delete(post: postId) { [net, data] _ in
            data.delete(post: postId)
            if userId > 0 {
                net.loadPosts(user: userId,
                              reload: true) { _ in }
            }
            if locationId > 0 {
                net.loadPosts(location: locationId,
                              reload: true) { _ in }
            }
        }
    }
}

// MARK: - Private

private extension PostsVC {

    var headerHeight: CGFloat {
        switch (canCreate, isQueued) {
        case (true, true):
            return layout.header.queued
        case (true, false):
            return layout.header.create
        case (false, _):
            return 1
        }
    }

    private func configure(menu post: PostCellModel) {
        if post.user?.userId == data.user?.id {
            UIMenuController.shared.menuItems = MenuAction.myItems
        } else {
            UIMenuController.shared.menuItems = MenuAction.theirItems
        }
    }

    func observeRequests() {
        guard requestsObserver == nil else { return }

        requestsObserver = net.observer(of: .requests) { [weak self] _ in
            self?.update()
        }
    }
}
