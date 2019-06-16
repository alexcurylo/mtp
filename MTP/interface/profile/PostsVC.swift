// @copyright Trollwerks Inc.

import Anchorage

class PostsVC: UITableViewController, ServiceProvider {

    @IBOutlet private var backgroundView: UIView?

    private var models: [PostCellModel] = []
    var posts: [Post] {
        fatalError("posts has not been overridden")
    }
    var source: DataServiceChange {
        fatalError("source has not been overridden")
    }

    private var contentState: ContentState = .loading
    private var postsObserver: Observer?
    private var viewObservation: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()

        #if GRADIENT_BACKGROUND
        tableView.backgroundView = backgroundView
        #else
        tableView.backgroundView = UIView { $0.backgroundColor = .clear }
        #endif
        tableView.tableFooterView = UIView()

        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension

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

// MARK: UITableViewControllerDataSource

extension PostsVC {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return models.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: R.reuseIdentifier.postCell,
            for: indexPath) ?? PostCell()

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
}

// MARK: PostCellDelegate

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

// MARK: Data management

private extension PostsVC {

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
