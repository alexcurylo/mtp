// @copyright Trollwerks Inc.

import Photos

final class MyPhotosVC: UICollectionViewController, ServiceProvider {

    private enum Layout {
        static let minItemSize = CGFloat(100)
    }

    private var photos: [Photo] = []
    private var devicePhotos: PHFetchResult<PHAsset>?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refreshPhotos()
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

extension MyPhotosVC {

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: R.reuseIdentifier.myPhotoCell,
            for: indexPath)

        if let cell = cell {
            cell.set(photo: photos[indexPath.item])
            return cell
        }

        return MyPhotoCell()
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension MyPhotosVC: UICollectionViewDelegateFlowLayout {

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

private extension MyPhotosVC {

    func refreshPhotos() {
        photos = data.photos
        collectionView.reloadData()
    }

    func refreshDevicePhotos() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        devicePhotos = PHAsset.fetchAssets(with: options)
    }

    func setDevicePhoto(cell: MyPhotoCell, indexPath: IndexPath) {
        guard let photo = devicePhotos?[indexPath.item] else { return }

        let size = self.collectionView(
            collectionView,
            layout: collectionView.collectionViewLayout,
            sizeForItemAt: indexPath)
        PHImageManager.default().requestImage(
            for: photo,
            targetSize: size,
            contentMode: .aspectFill,
            options: nil) { result, _ in
                cell.set(image: result)
        }
    }
}

final class MyPhotoCell: UICollectionViewCell {

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
