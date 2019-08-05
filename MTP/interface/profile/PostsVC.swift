// @copyright Trollwerks Inc.

import Anchorage

class PostsVC: UITableViewController, ServiceProvider {

    var canCreate: Bool {
        return false
    }

    var presenter: Presenter {
        fatalError("presenter has not been overridden")
    }

    //swiftlint:disable:next unavailable_function
    func createPost() {
        fatalError("createPost has not been overridden")
    }

    func show(user: User) {
        // override to implement
    }

    var contentState: ContentState = .loading
    var models: [PostCellModel] = []

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

    func cellModels(from posts: [Post]) -> [PostCellModel] {
        var index = 0
        let cellModels: [PostCellModel] = posts.map { post in
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return models.count
    }

    override func tableView(_ tableView: UITableView,
                            viewForHeaderInSection section: Int) -> UIView? {
        guard canCreate else { return UIView() }

        let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: PostHeader.reuseIdentifier) as? PostHeader

        header?.delegate = self

        return header
     }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //swiftlint:disable:next implicitly_unwrapped_optional
        let cell: PostCell! = tableView.dequeueReusableCell(
            withIdentifier: R.reuseIdentifier.postCell,
            for: indexPath)

        cell.set(model: models[indexPath.row],
                 delegate: self)

        return cell
    }
}

// MARK: - UITableViewDelegate

extension PostsVC {

    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView,
                            estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView,
                            heightForHeaderInSection section: Int) -> CGFloat {
        return canCreate ? layout.header : 1
    }

    override func tableView(_ tableView: UITableView,
                            estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return canCreate ? layout.header : 1
    }
}

// MARK: - PostCellDelegate

extension PostsVC: PostCellDelegate {

    func tapped(profile user: User) {
        show(user: user)
    }

    func tapped(toggle: Int) {
        guard toggle < models.count else { return }

        models[toggle].isExpanded.toggle()
        let path = IndexPath(row: toggle, section: 0)
        tableView.update {
            tableView.reloadRows(at: [path], with: .none)
        }
    }
}

// MARK: - Private

private extension PostsVC {

    @IBAction func addTapped(_ sender: GradientButton) {
        createPost()
    }
}

final class PostHeader: UITableViewHeaderFooterView {

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
    }

    var delegate: PostsVC? {
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

    override func prepareForReuse() {
        super.prepareForReuse()

        delegate = nil
    }
}
