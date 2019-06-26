// @copyright Trollwerks Inc.

import UIKit

final class LocationPostsVC: PostsVC {

    private typealias Segues = R.segue.locationPostsVC

    override var canCreate: Bool {
        return place?.list == .locations
    }

    override var posts: [Post] {
        guard let place = place,
              place.list == .locations else { return [] }

        return data.get(locationPosts: place.id)
    }

    override var source: DataServiceChange {
        return .locationPosts
    }

    //swiftlint:disable:next implicitly_unwrapped_optional
    private var place: PlaceAnnotation!

     override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        if place.list == .locations {
            mtp.loadPosts(location: place.id) { _ in }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.addPost.identifier:
            if let edit = Segues.addPost(segue: segue)?.destination {
                edit.inject(model: place)
            }
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }

    override func createPost() {
        performSegue(withIdentifier: Segues.addPost,
                     sender: self)
    }
}

extension LocationPostsVC: Injectable {

    typealias Model = PlaceAnnotation

    @discardableResult func inject(model: Model) -> Self {
        place = model
        return self
    }

    func requireInjections() {
        place.require()
    }
}
