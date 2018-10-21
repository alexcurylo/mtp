// @copyright Trollwerks Inc.

import Photos
import UIKit

final class MyPhotosVC: UICollectionViewController {

    private enum Layout {
        static let minItemSize = CGFloat(100)
    }

    private var photos: PHFetchResult<PHAsset>?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refreshPhotos()
        collectionView.reloadData()
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
        return photos?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MyPhotoCell.reuseIdentifier,
            for: indexPath)

        if let photoCell = cell as? MyPhotoCell,
           let photo = photos?[indexPath.item] {
            let size = self.collectionView(collectionView,
                                           layout: collectionView.collectionViewLayout,
                                           sizeForItemAt: indexPath)
            PHImageManager.default().requestImage(for: photo,
                                                  targetSize: size,
                                                  contentMode: .aspectFill,
                                                  options: nil) { result, _ in
                photoCell.set(image: result)
            }
        }

        return cell
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
        log.debug("My Photos should be using photos from site")
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        photos = PHAsset.fetchAssets(with: options)
    }
}

final class MyPhotoCell: UICollectionViewCell {

    fileprivate static let reuseIdentifier: String = "MyPhotoCell"

    @IBOutlet private var imageView: UIImageView?

    fileprivate func set(image: UIImage?) {
        imageView?.image = image
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView?.image = nil
    }
}