// @copyright Trollwerks Inc.

import RealmSwift

final class LocationPhotosVC: UICollectionViewController, ServiceProvider {

    private enum Layout {
        static let minItemSize = CGFloat(100)
    }

    private var place: PlaceAnnotation?
    private var photos: [Photo] = []

    private var photosObserver: Observer?

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        observe()
        update()
        if let place = place {
            mtp.loadPhotos(location: place.id) { _ in }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
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

extension LocationPhotosVC {

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: R.reuseIdentifier.locationPhotoCell,
            for: indexPath)

        if let cell = cell {
            cell.set(photo: photos[indexPath.item])
            return cell
        }

        return LocationPhotoCell()
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension LocationPhotosVC: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flow = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize(width: Layout.minItemSize, height: Layout.minItemSize)
        }
        let width = collectionView.bounds.width - flow.sectionInset.horizontal
        let itemWidth = Layout.minItemSize + flow.minimumInteritemSpacing
        let items = ((width + flow.minimumInteritemSpacing) / itemWidth).rounded(.down)
        let spacing = (items - 1) * flow.minimumInteritemSpacing
        let edge = ((width - spacing) / items).rounded(.down)
        return CGSize(width: edge, height: edge)
    }
}

// MARK: Data management

private extension LocationPhotosVC {

    func update() {
        guard let place = place else { return }

        photos = data.get(locationPhotos: place.id)
        collectionView.reloadData()
    }

    func observe() {
        guard photosObserver == nil else { return }

        photosObserver = data.observer(of: .locationPhotos) { [weak self] info in
            guard let self = self,
                  let place = self.place,
                  let updated = info[StatusKey.value.rawValue] as? Int,
                  updated == place.id else { return }
            self.update()
        }
    }
}

extension LocationPhotosVC: Injectable {

    typealias Model = PlaceAnnotation

    @discardableResult func inject(model: Model) -> Self {
        place = model
        return self
    }

    func requireInjections() {
        place.require()
    }
}

final class LocationPhotoCell: UICollectionViewCell {

    @IBOutlet private var imageView: UIImageView?

    fileprivate func set(image: UIImage?) {
        imageView?.image = image
    }

    fileprivate func set(photo: Photo?) {
        imageView?.set(thumbnail: photo)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView?.prepareForReuse()
    }
}
