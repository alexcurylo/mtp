// @copyright Trollwerks Inc.

import Anchorage

/// Base class for user and location post pages
class PostsVC: UITableViewController {

    /// Display a user's posts
    var canCreate: Bool {
        return false
    }

    /// Type of view presenting this controller
    var presenter: Presenter {
        fatalError("presenter has not been overridden")
    }

    /// Create a new post
    func createPost() {
        // override to implement
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
    private var configuredMenu = false

    private let layout = (row: CGFloat(100),
                          header: CGFloat(50))

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundView = UIView { $0.backgroundColor = .clear }
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = layout.row
        tableView.rowHeight = UITableView.automaticDimension
        if canCreate {
            tableView.estimatedSectionHeaderHeight = layout.header
            tableView.sectionHeaderHeight = UITableView.automaticDimension

            tableView.register(
                PostHeader.self,
                forHeaderFooterViewReuseIdentifier: PostHeader.reuseIdentifier
            )
        } else {
            tableView.estimatedSectionHeaderHeight = 1
            tableView.sectionHeaderHeight = 1
        }
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
}

// MARK: - UITableViewControllerDataSource

extension PostsVC {

    /// Number of sections
    ///
    /// - Parameter tableView: UITableView
    /// - Returns: Number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    /// Number of rows in section
    ///
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - section: Section
    /// - Returns: Number of rows in section
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return models.count
    }

    /// Create table header
    ///
    /// - Parameters:
    ///   - tableView: Container
    ///   - section: Index
    /// - Returns: PostHeader
    override func tableView(_ tableView: UITableView,
                            viewForHeaderInSection section: Int) -> UIView? {
        guard canCreate else { return UIView() }

        let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: PostHeader.reuseIdentifier) as? PostHeader

        header?.delegate = self

        return header
     }

    /// Create table cell
    ///
    /// - Parameters:
    ///   - tableView: Container
    ///   - indexPath: Index path
    /// - Returns: PostCell
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //swiftlint:disable:next implicitly_unwrapped_optional
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

    /// Provide row height
    ///
    /// - Parameters:
    ///   - tableView: Container
    ///   - indexPath: Index path
    /// - Returns: Height
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    /// Provide header height
    ///
    /// - Parameters:
    ///   - tableView: Container
    ///   - section: Index
    /// - Returns: Height
    override func tableView(_ tableView: UITableView,
                            heightForHeaderInSection section: Int) -> CGFloat {
        return canCreate ? layout.header : 1
    }

    /// Provide estimated header height
    ///
    /// - Parameters:
    ///   - tableView: Container
    ///   - section: Index
    /// - Returns: Height
    override func tableView(_ tableView: UITableView,
                            estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return canCreate ? layout.header : 1
    }

    /// Menu permission
    ///
    /// - Parameters:
    ///   - tableView: Container
    ///   - indexPath: Index path
    /// - Returns: Permission
    override func tableView(_ tableView: UITableView,
                            shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        configureMenu()
        return true
    }

    /// Action permission
    ///
    /// - Parameters:
    ///   - tableView: Container
    ///   - action: Action
    ///   - indexPath: Index path
    ///   - sender: Sender
    /// - Returns: Permission
    override func tableView(_ tableView: UITableView,
                            canPerformAction action: Selector,
                            forRowAt indexPath: IndexPath,
                            withSender sender: Any?) -> Bool {
        return MenuAction.isContent(action: action)
    }

    /// Action operation
    ///
    /// - Parameters:
    ///   - tableView: Container
    ///   - action: Action
    ///   - indexPath: Index path
    ///   - sender: Sender
    override func tableView(_ tableView: UITableView,
                            performAction action: Selector,
                            forRowAt indexPath: IndexPath,
                            withSender sender: Any?) {
        // Required to be present but only triggers for standard items
    }
}

// MARK: - PostCellDelegate

extension PostsVC: PostCellDelegate {

    /// Profile tapped
    ///
    /// - Parameter user: User to display
    func tapped(profile user: User) {
        show(user: user)
    }

    /// Display toggle tapped
    ///
    /// - Parameter toggle: Model to toggle
    func tapped(toggle: Int) {
        guard toggle < models.count else { return }

        models[toggle].isExpanded.toggle()
        let path = IndexPath(row: toggle, section: 0)
        tableView.update {
            tableView.reloadRows(at: [path], with: .none)
        }
    }

    /// Handle hide action
    ///
    /// - Parameter hide: PostCellModel to hide
    func tapped(hide: PostCellModel?) {
        data.block(post: hide?.postId ?? 0)
    }

    /// Handle report action
    ///
    /// - Parameter report: PostCellModel to report
    func tapped(report: PostCellModel?) {
        let message = L.reportPost(report?.postId ?? 0)
        app.route(to: .reportContent(message))
    }

    /// Handle block action
    ///
    /// - Parameter block: PostCellModel to block
    func tapped(block: PostCellModel?) {
        data.block(user: block?.user?.userId ?? 0)
        app.dismissPresentations()
    }
}

// MARK: - Private

private extension PostsVC {

    @IBAction func addTapped(_ sender: GradientButton) {
        createPost()
    }

    private func configureMenu() {
        guard !configuredMenu else { return }

        configuredMenu = true
        UIMenuController.shared.menuItems = MenuAction.contentItems
    }
}

/// Header of post table
final class PostHeader: UITableViewHeaderFooterView {

    /// Dequeueing identifier
    static let reuseIdentifier = NSStringFromClass(PostHeader.self)

    private let button = GradientButton {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.orientation = GradientOrientation.horizontal.rawValue
        $0.startColor = .dodgerBlue
        $0.endColor = .azureRadiance
        $0.cornerRadius = 4

        let title = L.addPost()
        $0.setTitle(title, for: .normal)
        $0.titleLabel?.font = Avenir.medium.of(size: 15)
        UIPosts.add.expose(item: $0)
    }

    fileprivate var delegate: PostsVC? {
        didSet {
            if let delegate = delegate {
                button.addTarget(delegate,
                                 action: #selector(delegate.addTapped),
                                 for: .touchUpInside)
            } else {
                button.removeTarget(nil,
                                    action: nil,
                                    for: .touchUpInside)
            }
        }
    }

    /// Construct with identifier
    ///
    /// - Parameter reuseIdentifier: Identifier
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        contentView.addSubview(button)
        button.edgeAnchors == edgeAnchors + EdgeInsets(top: 8,
                                                       left: 8,
                                                       bottom: 0,
                                                       right: 8)
    }

    /// Decoding intializer
    ///
    /// - Parameter aDecoder: Decoder
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Empty display
    override func prepareForReuse() {
        super.prepareForReuse()

        delegate = nil
    }
}
