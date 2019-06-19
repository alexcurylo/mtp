// @copyright Trollwerks Inc.

import RealmSwift

final class ProfilePhotosVC: PhotosVC {

    private var photosPages: Results<PhotosPageInfo>?

    private var pagesObserver: Observer?

    private var user: User?
    private var isSelf: Bool = false

    override var canCreate: Bool {
        return isSelf
    }

    override var photoCount: Int {
        return photosPages?.first?.total ?? 0
    }

    override func photo(at index: Int) -> Photo {
        guard let user = user else { return Photo() }

        let pageIndex = (index / PhotosPageInfo.perPage) + 1
        let photoIndex = index % PhotosPageInfo.perPage
        // swiftlint:disable:next first_where
        guard let page = photosPages?.filter("page = \(pageIndex)").first else {
            mtp.loadPhotos(user: user.id,
                           page: pageIndex) { _ in }
            return Photo()
        }

        let photoId = page.photoIds[photoIndex]
        return data.get(photo: photoId)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        update()
        observe()
    }
}

// MARK: Private

private extension ProfilePhotosVC {

    func update() {
        guard let user = user else { return }

        let pages = data.getPhotosPages(user: user.id)
        photosPages = pages
        collectionView.reloadData()

        if pages.isEmpty {
            contentState = .loading
        } else {
            contentState = photoCount == 0 ? .empty : .data
        }
        collectionView.set(message: contentState, color: .darkText)
    }

    func observe() {
        guard pagesObserver == nil else { return }

        pagesObserver = data.observer(of: .photoPages) { [weak self] _ in
            self?.update()
        }
    }

    #if BROWSE_DEVICE_PHOTOS
    private var devicePhotos: PHFetchResult<PHAsset>?

    func refreshDevicePhotos() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        devicePhotos = PHAsset.fetchAssets(with: options)
    }

    func setDevicePhoto(cell: PhotoCell, indexPath: IndexPath) {
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
    #endif
}

extension ProfilePhotosVC: UserInjectable {

    typealias Model = User

    @discardableResult func inject(model: Model) -> Self {
        user = model
        isSelf = model.id == data.user?.id

        mtp.loadPhotos(user: model.id,
                       page: 1) { _ in }

        return self
    }

    func requireInjections() {
        user.require()
    }
}
