// @copyright Trollwerks Inc.

import Foundation

/// Post API endpoint reply
struct PostReply: Codable {

    fileprivate let id: Int
    fileprivate let location: LocationJSON
    fileprivate let locationId: Int
    fileprivate let owner: UserJSON
    fileprivate let post: String
    fileprivate let status: String
    fileprivate let userId: Int
}

extension PostReply: CustomStringConvertible {

    var description: String {
        return "post \(id): \(post)"
    }
}

/// Payload sent to API endpoint
struct PostPayload: Codable, Hashable {

    /// post
    var post = ""
    /// location
    var location = LocationPayload()
    /// location_id
    var location_id: Int = 0
    /// status
    var status = "A"

    /// Set Location
    ///
    /// - Parameter place: Location
    mutating func set(location place: Location?) {
        if let place = place {
            location = LocationPayload(location: place)
        } else {
            location = LocationPayload()
        }
        location_id = location.id
    }

    /// Set Country
    ///
    /// - Parameter place: Country
    mutating func set(country place: Country?) {
        if let place = place, !place.hasChildren {
            location = LocationPayload(country: place)
        } else {
            location = LocationPayload()
        }
        location_id = location.id
    }
}

extension PostPayload: CustomStringConvertible {

    var description: String {
        return "post for \(location_id): \(post)"
    }
}

extension Post {

    /// Constructor from MTP endpoint data
    convenience init?(from: PostReply) {
        self.init()

        locationId = from.locationId
        post = from.post
        postId = from.id
        userId = from.userId
    }
}
