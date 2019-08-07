// @copyright Trollwerks Inc.

import UIKit

final class LocationPhotosVC: PhotosVC {

    private typealias Segues = R.segue.locationPhotosVC

    private var mappable: Mappable?
    private var photos: [Photo] = []

    private var photosObserver: Observer?
    private var blockedUsersObserver: Observer?
    private var blockedPhotosObserver: Observer?
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

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        update()
    }

    /// Instrument and inject navigation
    ///
    /// - Parameters:
    ///   - segue: Navigation action
    ///   - sender: Action originator
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

    /// Enable Location selection
    var isLocatable: Bool { return true }

    /// Handle photo addition
    ///
    /// - Parameters:
    ///   - controller: Add Photo controller
    ///   - reply: Selection description
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

        update(photos: mappable)
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
                  let mappable = self.mappable,
                  let updated = info[StatusKey.value.rawValue] as? Int,
                  updated == mappable.checklistId else { return }
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
    /// - Returns: Chainable self
    @discardableResult func inject(model: Model) -> Self {
        mappable = model

        refresh(reload: false)

        return self
    }

    /// Enforce dependency injection
    func requireInjections() {
        mappable.require()
    }
}
