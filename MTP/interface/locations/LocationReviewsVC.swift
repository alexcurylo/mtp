// @copyright Trollwerks Inc.

import Anchorage

final class LocationReviewsVC: UICollectionViewController, ServiceProvider {

    private enum Layout {
        static let cellHeight = CGFloat(100)
    }

    private var place: PlaceAnnotation?

    private var posts: [LocationPostCellModel] = []

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

        observe()
        update()
        if let place = place {
            mtp.loadPosts(location: place.id) { _ in }
        }
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

extension LocationReviewsVC {

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: R.reuseIdentifier.locationPostCell,
            for: indexPath)

        if let postCell = cell,
           let flow = flow {
            postCell.set(model: posts[indexPath.row],
                         width: collectionView.frame.width - flow.sectionInset.horizontal)
            return postCell
        }

        return LocationPostCell()
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension LocationReviewsVC: UICollectionViewDelegateFlowLayout {

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

private extension LocationReviewsVC {

    func update() {
        guard let place = place else { return }

        let locationPosts = data.get(locationPosts: place.id)

        posts = locationPosts.map { post in
            //let photos = data.get(user: nil, photos: post.locationId)
            let location = data.get(location: post.locationId)
            return LocationPostCellModel(
                photo: nil, //photos.first,
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

        postsObserver = data.observer(of: .locationPosts) { [weak self] _ in
            self?.update()
        }
    }

    var flow: UICollectionViewFlowLayout? {
        return collectionView.collectionViewLayout as? UICollectionViewFlowLayout
    }
}

extension LocationReviewsVC: Injectable {

    typealias Model = PlaceAnnotation

    @discardableResult func inject(model: Model) -> LocationReviewsVC {
        place = model
        return self
    }

    func requireInjections() {
        place.require()
    }
}

struct LocationPostCellModel {

    let photo: Photo?
    let location: Location?
    let date: String
    let title: String
    let body: String
}

final class LocationPostCell: UICollectionViewCell {

    @IBOutlet private var imageView: UIImageView?
    @IBOutlet private var imageViewWidthConstraint: NSLayoutConstraint?

    @IBOutlet private var dateLabel: UILabel?
    @IBOutlet private var titleLabel: UILabel?
    @IBOutlet private var bodyLabel: UILabel?

    private var widthConstraint: NSLayoutConstraint?

    let imageWidth = (displayed: CGFloat(100),
                      empty: CGFloat(0))

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.centerAnchors == centerAnchors
        widthConstraint = contentView.widthAnchor == 0
    }

    fileprivate func set(model: LocationPostCellModel,
                         width: CGFloat) {
        if let photo = model.photo {
            imageView?.set(thumbnail: photo)
            imageViewWidthConstraint?.constant = imageWidth.displayed
        } else {
            imageView?.image = nil
            imageViewWidthConstraint?.constant = imageWidth.empty
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
