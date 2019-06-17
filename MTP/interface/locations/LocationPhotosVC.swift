// @copyright Trollwerks Inc.

import RealmSwift

final class LocationPhotosVC: PhotosVC {

    private var place: PlaceAnnotation?
    private var photos: [Photo] = []

    private var photosObserver: Observer?
    private var updated = false

    override var photoCount: Int {
        return photos.count
    }

    override func photo(at index: Int) -> Photo {
        return photos[index]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        observe()
        update()
        if let place = place {
            mtp.loadPhotos(location: place.id) { [weak self] _ in
                guard let self = self,
                      !self.updated else { return }

                self.updated = true
                self.update()
            }
        }
    }
}

// MARK: Private

private extension LocationPhotosVC {

    func update() {
        guard let place = place else { return }

        photos = data.get(locationPhotos: place.id)
        collectionView.reloadData()

        if photoCount > 0 {
            contentState = .data
        } else {
            contentState = updated ? .empty : .loading
        }
        collectionView.set(message: contentState, color: .darkText)
    }

    func observe() {
        guard photosObserver == nil else { return }

        photosObserver = data.observer(of: .locationPhotos) { [weak self] info in
            guard let self = self,
                  let place = self.place,
                  let updated = info[StatusKey.value.rawValue] as? Int,
                  updated == place.id else { return }
            self.updated = true
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
