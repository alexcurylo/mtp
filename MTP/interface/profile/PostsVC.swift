// @copyright Trollwerks Inc.

import Anchorage

class PostsVC: UICollectionViewController, ServiceProvider {

    @IBOutlet private var layout: UICollectionViewFlowLayout? {
        didSet {
            layout?.itemSize = UICollectionViewFlowLayout.automaticSize
            layout?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    private var cellWidth: CGFloat = 0
    private var shouldInvalidateLayout = true

    private var models: [PostCellModel] = []
    var posts: [Post] {
        fatalError("posts has not been overridden")
    }
    var source: DataServiceChange {
        fatalError("source has not been overridden")
    }

    private let dateFormatter = DateFormatter {
        $0.dateStyle = .long
        $0.timeStyle = .none
    }

    private var postsObserver: Observer?
    private var viewObservation: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()
        layout.require()

        collectionView.register(PostCell.self,
                                forCellWithReuseIdentifier: PostCell.reuseIdentifier)

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

        shouldInvalidateLayout = false
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // swiftlint:disable:next line_length
        // https://stackoverflow.com/questions/51375566/in-ios-12-when-does-the-uicollectionview-layout-cells-use-autolayout-in-nib
        if shouldInvalidateLayout {
            layout?.invalidateLayout()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        log.verbose("prepare for \(segue.name)")
        switch segue.identifier {
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

// MARK: UICollectionViewDataSource

extension PostsVC {

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return models.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PostCell.reuseIdentifier,
            for: indexPath)

        if let postCell = cell as? PostCell {
            postCell.set(model: models[indexPath.row],
                         delegate: self,
                         width: cellWidth)
        }

        return cell
    }
}

// MARK: PostCellDelegate

extension PostsVC: PostCellDelegate {

    func toggle(index: Int) {
        guard index < models.count else { return }

        models[index].isExpanded.toggle()
        // other cells go blank?
        //let path = IndexPath(row: index, section: 0)
        //collectionView.reloadItems(at: [path])
        collectionView.reloadData()
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
        collectionView.reloadData()
    }

    func observe() {
        if postsObserver == nil {
            postsObserver = data.observer(of: source) { [weak self] _ in
                self?.update()
            }
        }

        if viewObservation == nil,
            let view = collectionView {
            cellWidth = layoutWidth
            viewObservation = view.layer.observe(\.bounds) { [weak self] _, _ in
                guard let self = self else { return }

                let newWidth = self.layoutWidth
                if self.cellWidth != newWidth {
                    self.cellWidth = newWidth
                    self.collectionView.collectionViewLayout.invalidateLayout()
                    self.collectionView.setNeedsLayout()
                    self.collectionView.reloadData()
                }
            }
        }
    }

    var layoutWidth: CGFloat {
        return collectionView.bounds.width - (layout?.sectionInset.horizontal ?? 0)
    }
}
