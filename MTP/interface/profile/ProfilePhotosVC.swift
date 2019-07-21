// @copyright Trollwerks Inc.

import RealmSwift

final class ProfilePhotosVC: PhotosVC {

    private typealias Segues = R.segue.profilePhotosVC

    private var photosPages: Results<PhotosPageInfo>?

    private var pagesObserver: Observer?
    private var updated = false

    private var user: User?
    private var isSelf: Bool = false

    override var canCreate: Bool {
        return isSelf
    }

    override var photoCount: Int {
        return photosPages?.first?.total ?? 0
    }

    override func photo(at index: Int) -> Photo {
        let pageIndex = (index / PhotosPageInfo.perPage) + 1
        let photoIndex = index % PhotosPageInfo.perPage
        // swiftlint:disable:next first_where
        guard let page = photosPages?.filter("page = \(pageIndex)").first else {
            refresh(page: pageIndex, reload: true)
            return Photo()
        }

        let photoId = page.photoIds[photoIndex]
        return data.get(photo: photoId)
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
                add.inject(model: (mappable: nil, delegate: self))
            }
        case Segues.cancelChoose.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

// MARK: AddPhotoDelegate

extension ProfilePhotosVC: AddPhotoDelegate {

    func addPhoto(controller: AddPhotoVC,
                  didAdd reply: PhotoReply) {
        refresh(page: 1, reload: true)
    }
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
        } else if let user = user {
            net.loadPhotos(profile: user.userId,
                           page: page,
                           reload: reload) { [weak self] _ in
                self?.loaded()
            }
        }
    }

    func update() {
        guard let user = user else { return }

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

    func observe() {
        guard pagesObserver == nil else { return }

        pagesObserver = data.observer(of: .photoPages) { [weak self] _ in
            self?.update()
        }
    }

    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        broadcastSelection()
        performSegue(withIdentifier: Segues.cancelChoose.identifier, sender: self)
    }
}

extension ProfilePhotosVC: UserInjectable {

    typealias Model = User

    @discardableResult func inject(model: Model) -> Self {
        user = model
        isSelf = model.isSelf

        refresh(page: 1, reload: false)

        return self
    }

    func requireInjections() {
        user.require()
    }
}
