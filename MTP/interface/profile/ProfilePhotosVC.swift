// @copyright Trollwerks Inc.

import RealmSwift

/// Display a user's photos
final class ProfilePhotosVC: PhotosVC {

    private typealias Segues = R.segue.profilePhotosVC

    private var photosPages: Results<PhotosPageInfo>?

    private var pagesObserver: Observer?
    private var blockedPhotosObserver: Observer?
    private var updated = false

    // verified in requireInjection
    private var user: User!
    // swiftlint:disable:previous implicitly_unwrapped_optional

    private var isSelf: Bool = false
    private var blockedPhotos: [Int] = []

    /// Whether user can add a new photo
    override var canCreate: Bool {
        return isSelf
    }

    /// Whether a new photo is queued to upload
    override var isQueued: Bool {
        return isSelf && !queuedPhotos.isEmpty
    }

    /// How many photos in collection
    override var photoCount: Int {
        return photosPages?.first?.total ?? 0
    }

    /// Retrieve an indexed photo
    ///
    /// - Parameter index: Index
    /// - Returns: Photo
    override func photo(at index: Int) -> Photo {
        let pageIndex = (index / PhotosPageInfo.perPage) + 1
        let photoIndex = index % PhotosPageInfo.perPage
        // swiftlint:disable:next first_where
        guard let page = photosPages?.filter("page = \(pageIndex)").first else {
            refresh(page: pageIndex, reload: true)
            return Photo()
        }

        let photoId = page.photoIds[photoIndex]
        if blockedPhotos.contains(photoId) {
            return Photo()
        }
        return data.get(photo: photoId)
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

    /// Prepare for reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        expose()
    }

    /// Instrument and inject navigation
    ///
    /// - Parameters:
    ///   - segue: Navigation action
    ///   - sender: Action originator
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let add = Segues.addPhoto(segue: segue)?
                           .destination {
            add.inject(model: (mappable: nil, delegate: self))
        }
    }

    override func update() {
        super.update()

        blockedPhotos = data.blockedPhotos
        let pages = data.getPhotosPages(user: user.userId)
        photosPages = pages
        collectionView.reloadData()

        if photoCount > 0 {
            contentState = .data
        } else {
            contentState = updated ? .empty : .loading
        }
        collectionView.set(message: contentState, color: .darkText)
    }
}

// MARK: AddPhotoDelegate

extension ProfilePhotosVC: AddPhotoDelegate {

    /// Enable Location selection
    var isLocatable: Bool { return mode == .browser }
}

// MARK: Private

private extension ProfilePhotosVC {

    func loaded() {
        updated = true

        update()
        observe()
    }

    func refresh(page: Int, reload: Bool) {
        if isSelf {
            net.loadPhotos(page: page,
                           reload: reload) { [weak self] _ in
                self?.loaded()
            }
        } else {
            net.loadPhotos(profile: user.userId,
                           page: page,
                           reload: reload) { [weak self] _ in
                self?.loaded()
            }
        }
    }

    func observe() {
        guard pagesObserver == nil else { return }

        pagesObserver = data.observer(of: .photoPages) { [weak self] _ in
            self?.update()
        }
        blockedPhotosObserver = data.observer(of: .blockedPhotos) { [weak self] _ in
            self?.update()
        }
    }

    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        broadcastSelection()
        performSegue(withIdentifier: Segues.cancelChoose.identifier, sender: self)
    }
}

// MARK: - Exposing

extension ProfilePhotosVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        let items = navigationItem.leftBarButtonItems
        UIProfilePhotos.close.expose(item: items?.first)
    }
}

// MARK: - UserInjectable

extension ProfilePhotosVC: UserInjectable {

    /// Injected dependencies
    typealias Model = User

    /// Handle dependency injection
    ///
    /// - Parameter model: Dependencies
    func inject(model: Model) {
        user = model
        isSelf = model.isSelf

        refresh(page: 1, reload: false)
    }

    /// Enforce dependency injection
    func requireInjection() {
        user.require()
    }
}
