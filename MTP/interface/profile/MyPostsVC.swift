// @copyright Trollwerks Inc.

import Anchorage

final class MyPostsVC: UICollectionViewController, ServiceProvider {

    @IBOutlet private var layout: UICollectionViewFlowLayout? {
        didSet {
            layout?.itemSize = UICollectionViewFlowLayout.automaticSize
            layout?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    private var cellWidth: CGFloat = 0

    private var posts: [PostCellModel] = []

    private let dateFormatter = DateFormatter {
        $0.dateStyle = .long
        $0.timeStyle = .none
    }

    private var postsObserver: Observer?
    private var viewObservation: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        update()
        observe()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        update()
        observe()
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

extension MyPostsVC {

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: R.reuseIdentifier.postCell,
            for: indexPath)

        if let postCell = cell {
            postCell.set(model: posts[indexPath.row],
                         delegate: self,
                         width: cellWidth)
            return postCell
        }

        return PostCell()
    }
}

// MARK: PostCellDelegate

extension MyPostsVC: PostCellDelegate {

    func toggle(index: Int) {
        guard index < posts.count else { return }

        posts[index].isExpanded.toggle()
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.setNeedsLayout()
        collectionView.reloadData()
    }
}

// MARK: Data management

private extension MyPostsVC {

    func update() {
        var index = 0
        posts = data.posts.map { post in
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

        collectionView.reloadData()
    }

    func observe() {
        if postsObserver == nil {
            postsObserver = data.observer(of: .posts) { [weak self] _ in
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

extension MyPostsVC: Injectable {

    typealias Model = ()

    @discardableResult func inject(model: Model) -> MyPostsVC {
        return self
    }

    func requireInjections() {
        layout.require()
    }
}
