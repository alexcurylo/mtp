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

    private let dateFormatter = DateFormatter(mtp: .long)

    private var postsObserver: Observer?
    private var viewObservation: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()

        #if GRADIENT_BACKGROUND
        tableView.backgroundView = backgroundView
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
        // suppress animation to kill white flicker
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.reloadRows(at: [path], with: .none)
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
}

// MARK: Data management

private extension PostsVC {

    func update() {
        var index = 0
        let cellModels: [PostCellModel] = posts.map { post in
            let location = data.get(location: post.locationId)
            let model = PostCellModel(
                index: index,
                location: location,
                date: dateFormatter.string(from: post.updatedAt).uppercased(),
                title: location?.placeTitle ?? Localized.unknown(),
                body: post.post,
                isExpanded: false
            )
            index += 1
            return model
        }
        models = cellModels
        tableView.reloadData()
    }

    func observe() {
        if postsObserver == nil {
            postsObserver = data.observer(of: source) { [weak self] _ in
                self?.update()
            }
        }
    }
}
