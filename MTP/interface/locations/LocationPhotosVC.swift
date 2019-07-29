// @copyright Trollwerks Inc.

import UIKit

final class LocationPhotosVC: PhotosVC {

    private typealias Segues = R.segue.locationPhotosVC

    private var mappable: Mappable?
    private var photos: [Photo] = []

    private var photosObserver: Observer?
    private var updated = false

    override var canCreate: Bool {
        return isImplemented
    }
    private var isImplemented: Bool {
        return mappable?.checklist == .locations
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

        update()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.addPhoto.identifier:
            if let add = Segues.addPhoto(segue: segue)?.destination {
                add.inject(model: (mappable: mappable, delegate: self))
            }
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

// MARK: AddPhotoDelegate

extension LocationPhotosVC: AddPhotoDelegate {

    var isLocatable: Bool { return true }

    func addPhoto(controller: AddPhotoVC,
                  didAdd reply: PhotoReply) {
        refresh(reload: true)
    }
}

// MARK: Private

private extension LocationPhotosVC {

    func loaded() {
        updated = true
        update()
        observe()
    }

    func refresh(reload: Bool) {
        guard let mappable = mappable, isImplemented else { return }

        net.loadPhotos(location: mappable.checklistId,
                       reload: reload) { [weak self] _ in
            self?.loaded()
        }
    }

    func update() {
        guard let mappable = mappable else { return }

        if isImplemented {
            photos = data.get(locationPhotos: mappable.checklistId)
        }
        collectionView.reloadData()

        if photoCount > 0 {
            contentState = .data
        } else if !isImplemented {
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
                  let mappable = self.mappable,
                  let updated = info[StatusKey.value.rawValue] as? Int,
                  updated == mappable.checklistId else { return }
            self.updated = true
            self.update()
        }
    }
}

extension LocationPhotosVC: Injectable {

    typealias Model = Mappable

    @discardableResult func inject(model: Model) -> Self {
        mappable = model

        refresh(reload: false)

        return self
    }

    func requireInjections() {
        mappable.require()
    }
}
