// @copyright Trollwerks Inc.

import UIKit

final class LocationPhotosVC: PhotosVC {

    private typealias Segues = R.segue.locationPhotosVC

    private var place: PlaceAnnotation?
    private var photos: [Photo] = []

    private var photosObserver: Observer?
    private var updated = false

    override var canCreate: Bool {
        return place?.list == .locations
    }

    override var photoCount: Int {
        return photos.count
    }

    override func photo(at index: Int) -> Photo {
        return photos[index]
    }

    override func createPhoto() {
        performSegue(withIdentifier: Segues.addPhoto,
                     sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        observe()
        update()

        refresh()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.addPhoto.identifier:
            if let add = Segues.addPhoto(segue: segue)?.destination {
                add.inject(model: (place: place, delegate: self))
            }
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

// MARK: AddPhotoDelegate

extension LocationPhotosVC: AddPhotoDelegate {

    func addPhoto(controller: AddPhotoVC,
                  didAdd reply: PhotoReply) {
        refresh()
    }
}

// MARK: Private

private extension LocationPhotosVC {

    func refresh() {
        guard let place = place,
              place.list == .locations else { return }

        mtp.loadPhotos(location: place.id) { [weak self] _ in
            guard let self = self,
                !self.updated else { return }

            self.updated = true
            self.update()
        }
    }

    func update() {
        guard let place = place else { return }

        if place.list == .locations {
            photos = data.get(locationPhotos: place.id)
        }
        collectionView.reloadData()

        if photoCount > 0 {
            contentState = .data
        } else if place.list != .locations {
            contentState = .unimplemented
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
