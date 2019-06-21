// @copyright Trollwerks Inc.

import Anchorage

class PostsVC: UITableViewController, ServiceProvider {

    var canCreate: Bool {
        return false
    }

    var posts: [Post] {
        fatalError("posts has not been overridden")
    }

    var source: DataServiceChange {
        fatalError("source has not been overridden")
    }

    private var models: [PostCellModel] = []
    private var contentState: ContentState = .loading
    private var postsObserver: Observer?
    private var viewObservation: NSKeyValueObservation?

    private let layout = (row: CGFloat(100),
                          header: CGFloat(50))

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
        }

        update()
        observe()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        update()
        observe()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
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
        guard canCreate else { return nil }

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
        return canCreate ? layout.header : 0
    }

    override func tableView(_ tableView: UITableView,
                            estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return layout.header
    }
}

// MARK: - PostCellDelegate

extension PostsVC: PostCellDelegate {

    func toggle(index: Int) {
        guard index < models.count else { return }

        models[index].isExpanded.toggle()
        let path = IndexPath(row: index, section: 0)
        tableView.update {
            tableView.reloadRows(at: [path], with: .none)
        }
    }
}

// MARK: - Private

private extension PostsVC {

    @IBAction func addTapped(_ sender: GradientButton) {
        log.todo("implement addTapped")
        note.unimplemented()
    }

    func cellModels(from posts: [Post]) -> [PostCellModel] {
        var index = 0
        let cellModels: [PostCellModel] = posts.map { post in
            let location = data.get(location: post.locationId)
            let model = PostCellModel(
                index: index,
                location: location,
                date: DateFormatter.mtpPost.string(from: post.updatedAt).uppercased(),
                title: location?.placeTitle ?? Localized.unknown(),
                body: post.post,
                isExpanded: false
            )
            index += 1
            return model
        }
        return cellModels
    }

    func update() {
        #if HAVE_LOADING_STATE
        let newModels: [PostCellModel]
        if let posts = posts {
            newModels = cellModels(from: posts)
            contentState = newModels.isEmpty ? .empty : .data
        } else {
            newModels = []
            contentState = .loading
        }
        models = newModels
        #else
        models = cellModels(from: posts)
        contentState = models.isEmpty ? .empty : .data
        #endif

        tableView.reloadData()
        tableView.set(message: contentState, color: .darkText)
    }

    func observe() {
        if postsObserver == nil {
            postsObserver = data.observer(of: source) { [weak self] _ in
                self?.update()
            }
        }
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

        let title = Localized.addPost()
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

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        delegate = nil
    }
}
