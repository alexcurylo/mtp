// @copyright Trollwerks Inc.

import Anchorage

final class MyPostsVC: UICollectionViewController, ServiceProvider {

    private enum Layout {
        static let cellHeight = CGFloat(100)
    }

    private var posts: [PostCellModel] = []

    private let dateFormatter = DateFormatter {
        $0.dateStyle = .long
        $0.timeStyle = .none
    }

    private var postsObserver: Observer?

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        flow?.itemSize = UICollectionViewFlowLayout.automaticSize
        flow?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

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

        if let postCell = cell,
           let flow = flow {
            postCell.set(model: posts[indexPath.row],
                         delegate: self,
                         width: collectionView.frame.width - flow.sectionInset.horizontal)
            return postCell
        }

        return PostCell()
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension MyPostsVC: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let insets: CGFloat
        if let flow = collectionViewLayout as? UICollectionViewFlowLayout {
            insets = flow.sectionInset.horizontal
        } else {
            insets = 0
        }
        return CGSize(width: collectionView.bounds.width - insets,
                      height: Layout.cellHeight)
    }
}

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
        var index = -1
        posts = data.posts.map { post in
            // Where is the picture?
            // https://gitlab.com/bitmads/mtp/issues/238
            let photo: Photo? = nil
            let location = data.get(location: post.locationId)
            index += 1
            return PostCellModel(
                index: index,
                photo: photo,
                location: location,
                date: dateFormatter.string(from: post.updatedAt).uppercased(),
                title: location?.placeTitle ?? Localized.unknown(),
                body: post.post,
                isExpanded: false
            )
        }

        collectionView.reloadData()
    }

    func observe() {
        guard postsObserver == nil else { return }

        postsObserver = data.observer(of: .posts) { [weak self] _ in
            self?.update()
        }
    }

    var flow: UICollectionViewFlowLayout? {
        return collectionView.collectionViewLayout as? UICollectionViewFlowLayout
    }
}

extension MyPostsVC: Injectable {

    typealias Model = ()

    @discardableResult func inject(model: Model) -> MyPostsVC {
        return self
    }

    func requireInjections() {
    }
}
