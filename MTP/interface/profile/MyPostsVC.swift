// @copyright Trollwerks Inc.

import Anchorage

final class MyPostsVC: UICollectionViewController, ServiceProvider {

    private enum Layout {
        static let cellHeight = CGFloat(100)
    }

    private var posts: [MyPostCellModel] = []

    private let dateFormatter = DateFormatter {
        $0.dateStyle = .long
        $0.timeStyle = .none
    }

    private var postsObserver: Observer?

    override func viewDidLoad() {
        super.viewDidLoad()

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
            withReuseIdentifier: R.reuseIdentifier.myPostCell,
            for: indexPath)

        if let postCell = cell,
           let flow = flow {
            postCell.set(model: posts[indexPath.row],
                         width: collectionView.frame.width - flow.sectionInset.horizontal)
            return postCell
        }

        return MyPostCell()
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

// MARK: Data management

private extension MyPostsVC {

    func update() {
        posts = data.posts.map { post in
            let photos = data.get(user: nil, photos: post.locationId)
            let location = data.get(location: post.locationId)
            return MyPostCellModel(
                photo: photos.first,
                location: location,
                date: dateFormatter.string(from: post.updatedAt).uppercased(),
                title: location?.placeTitle ?? Localized.unknown(),
                body: post.post
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

struct MyPostCellModel {

    let photo: Photo?
    let location: Location?
    let date: String
    let title: String
    let body: String
}

final class MyPostCell: UICollectionViewCell {

    @IBOutlet private var imageView: UIImageView?
    @IBOutlet private var dateLabel: UILabel?
    @IBOutlet private var titleLabel: UILabel?
    @IBOutlet private var bodyLabel: UILabel?
    private var widthConstraint: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.centerAnchors == centerAnchors
        widthConstraint = contentView.widthAnchor == 0
    }

    fileprivate func set(model: MyPostCellModel,
                         width: CGFloat) {
        if let photo = model.photo {
            imageView?.set(thumbnail: photo)
        } else {
            imageView?.set(thumbnail: model.location)
        }
        dateLabel?.text = model.date
        titleLabel?.text = model.title
        bodyLabel?.text = model.body

        widthConstraint?.constant = width
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView?.prepareForReuse()
        dateLabel?.text = nil
        titleLabel?.text = nil
        bodyLabel?.text = nil
    }
}
