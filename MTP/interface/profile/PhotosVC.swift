// @copyright Trollwerks Inc.

import RealmSwift

class PhotosVC: UICollectionViewController, ServiceProvider {

    private enum Layout {
        static let minItemSize = CGFloat(100)
    }

    var contentState: ContentState = .loading

    var photoCount: Int {
        fatalError("photoCount has not been overridden")
    }

    //swiftlint:disable:next unavailable_function
    func photo(at index: Int) -> Photo {
        fatalError("photo(at:) has not been overridden")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundView = UIView { $0.backgroundColor = .clear }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

// MARK: UICollectionViewDataSource

extension PhotosVC {

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return photoCount
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: R.reuseIdentifier.photoCell,
            for: indexPath)

        if let cell = cell {
            cell.set(photo: photo(at: indexPath.item))
            return cell
        }

        return PhotoCell()
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension PhotosVC: UICollectionViewDelegateFlowLayout {

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

final class PhotoCell: UICollectionViewCell {

    @IBOutlet private var imageView: UIImageView?

    fileprivate func set(image: UIImage?) {
        imageView?.image = image
    }

    fileprivate func set(photo: Photo?) {
        imageView?.load(image: photo)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView?.prepareForReuse()
    }
}
