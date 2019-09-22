// @copyright Trollwerks Inc.

import UIKit

/// Displays location photos
final class LocationPhotosVC: PhotosVC {

    private typealias Segues = R.segue.locationPhotosVC

    // verified in requireInjection
    private var mappable: Mappable!
    // swiftlint:disable:previous implicitly_unwrapped_optional

    private var photos: [Photo] = []

    private var photosObserver: Observer?
    private var blockedUsersObserver: Observer?
    private var blockedPhotosObserver: Observer?
    private var updated = false

    /// Can create new content
    override var canCreate: Bool {
        return isImplemented
    }
    private var isImplemented: Bool {
        return mappable.checklist == .locations
    }

    /// How many photos in collection
    override var photoCount: Int {
        return photos.count
    }

    /// Retrieve an indexed photo
    ///
    /// - Parameter index: Index
    /// - Returns: Photo
    override func photo(at index: Int) -> Photo {
        return photos[index]
    }

    /// Create a new Photo
    override func createPhoto() {
        performSegue(withIdentifier: Segues.addPhoto,
                     sender: self)
    }

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjection()

        update()
    }

    /// Instrument and inject navigation
    ///
    /// - Parameters:
    ///   - segue: Navigation action
    ///   - sender: Action originator
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let add = Segues.addPhoto(segue: segue)?
                           .destination {
            add.inject(model: (mappable: mappable, delegate: self))
        }
    }
}

// MARK: AddPhotoDelegate

extension LocationPhotosVC: AddPhotoDelegate {

    /// Enable Location selection
    var isLocatable: Bool { return true }
}

// MARK: Private

private extension LocationPhotosVC {

    func loaded() {
        updated = true
        update()
        observe()
    }

    func refresh(reload: Bool) {
        guard isImplemented else { return }

        net.loadPhotos(location: mappable.checklistId,
                       reload: reload) { [weak self] _ in
            self?.loaded()
        }
    }

    func update() {
        guard isImplemented else {
            contentState = .unknown
            collectionView.set(message: L.unimplemented(), color: .darkText)
            return
        }

        update(photos: mappable)
        collectionView.reloadData()

        if photoCount > 0 {
            contentState = .data
        } else {
            contentState = updated ? .empty : .loading
        }
        collectionView.set(message: contentState, color: .darkText)
    }

    func update(photos mappable: Mappable) {
        guard isImplemented else { return }

        let blockedPhotos = data.blockedPhotos
        let blockedUsers = data.blockedUsers
        let allPhotos = data.get(locationPhotos: mappable.checklistId)
        if blockedPhotos.isEmpty && blockedUsers.isEmpty {
            photos = allPhotos
        } else {
            photos = allPhotos.compactMap {
                guard !blockedPhotos.contains($0.photoId),
                      !blockedUsers.contains($0.userId) else { return nil }
                return $0
            }
        }
    }

    func observe() {
        guard photosObserver == nil else { return }

        photosObserver = data.observer(of: .locationPhotos) { [weak self] info in
            guard let self = self,
                  let updated = info[StatusKey.value.rawValue] as? Int,
                  updated == self.mappable.checklistId else { return }
            self.updated = true
            self.update()
        }

        blockedPhotosObserver = data.observer(of: .blockedPhotos) { [weak self] _ in
            self?.update()
        }
        blockedUsersObserver = data.observer(of: .blockedUsers) { [weak self] _ in
            self?.update()
        }
    }
}

// MARK: - Injectable

extension LocationPhotosVC: Injectable {

    /// Injected dependencies
    typealias Model = Mappable

    /// Handle dependency injection
    ///
    /// - Parameter model: Dependencies
    func inject(model: Model) {
        mappable = model

        refresh(reload: false)
    }

    /// Enforce dependency injection
    func requireInjection() {
        mappable.require()
    }
}
