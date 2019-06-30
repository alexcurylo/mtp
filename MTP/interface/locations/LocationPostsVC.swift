// @copyright Trollwerks Inc.

import UIKit

final class LocationPostsVC: PostsVC {

    private typealias Segues = R.segue.locationPostsVC

    override var canCreate: Bool {
        return isImplemented
    }
    private var isImplemented: Bool {
        return place?.list == .locations
    }

    override var presenter: Presenter {
        return .location
    }

    private var postsObserver: Observer?
    private var updated = false

    private var profileModel: UserProfileVC.Model?

    //swiftlint:disable:next implicitly_unwrapped_optional
    private var place: PlaceAnnotation!

     override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        update()
   }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.addPost.identifier:
            if let edit = Segues.addPost(segue: segue)?.destination {
                edit.inject(model: place)
            }
        case Segues.showUserProfile.identifier:
            if let profile = Segues.showUserProfile(segue: segue)?.destination,
                let profileModel = profileModel {
                profile.inject(model: profileModel)
            }
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }

    override func createPost() {
        performSegue(withIdentifier: Segues.addPost,
                     sender: self)
    }

    override func show(user: User) {
        profileModel = user
        performSegue(withIdentifier: Segues.showUserProfile, sender: self)
    }
}

private extension LocationPostsVC {

    func loaded() {
        updated = true
        update()
        observe()
    }

    func update() {
        guard let place = place else { return }

        guard isImplemented else {
            contentState = .unimplemented
            tableView.set(message: contentState, color: .darkText)
            return
        }

        let posts = data.get(locationPosts: place.id)
        models = cellModels(from: posts)
        tableView.reloadData()

        if !models.isEmpty {
            contentState = .data
        } else if !isImplemented {
            contentState = .unimplemented
        } else {
            contentState = updated ? .empty : .loading
        }
        tableView.set(message: contentState, color: .darkText)
    }

    func observe() {
        guard postsObserver == nil else { return }

        postsObserver = data.observer(of: .locationPosts) { [weak self] _ in
            self?.update()
        }
    }
}

extension LocationPostsVC: Injectable {

    typealias Model = PlaceAnnotation

    @discardableResult func inject(model: Model) -> Self {
        place = model

        log.todo("implement non-MTP location posting")
        if isImplemented {
            mtp.loadPosts(location: place.id) { [weak self] _ in
                self?.loaded()
            }
        }

        return self
    }

    func requireInjections() {
        place.require()
    }
}
