// @copyright Trollwerks Inc.

import Foundation

struct PostReply: Codable {

    let id: Int
    let location: LocationJSON
    let locationId: Int
    let owner: UserJSON
    let post: String
    let status: String
    let userId: Int
}

extension PostReply: CustomStringConvertible {

    public var description: String {
        return "post \(id): \(post)"
    }
}

struct PostPayload: Codable, Hashable {

    var post = ""
    var location = LocationPayload()
    var location_id: Int = 0
    var status = "A"

    mutating func set(location place: Location?) {
        if let place = place {
            location = LocationPayload(location: place)
        } else {
            location = LocationPayload()
        }
        location_id = location.id
    }

    mutating func set(country place: Country?) {
        if let place = place, !place.hasChildren {
            location = LocationPayload(country: place)
        } else {
            location = LocationPayload()
        }
        location_id = location.id
    }
}
