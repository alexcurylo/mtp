// @copyright Trollwerks Inc.

import UIKit

final class LocationReviewsVC: PostsVC {

    override var posts: [Post] {
        guard let place = place else { return [] }

        return data.get(locationPosts: place.id)
    }

    override var source: DataServiceChange {
        return .locationPosts
    }

    private var place: PlaceAnnotation?

     override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        if let place = place {
            mtp.loadPosts(location: place.id) { _ in }
        }
    }
}

extension LocationReviewsVC: Injectable {

    typealias Model = PlaceAnnotation

    @discardableResult func inject(model: Model) -> Self {
        place = model
        return self
    }

    func requireInjections() {
        place.require()
    }
}
