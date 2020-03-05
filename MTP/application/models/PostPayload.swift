// @copyright Trollwerks Inc.

import Foundation

/// Post API endpoint reply
struct PostReply: Codable {

    fileprivate let id: Int
    fileprivate let location: PlaceLocation
    fileprivate let locationId: Int
    fileprivate let owner: UserJSON
    fileprivate let post: String
    fileprivate let status: String
    fileprivate let userId: Int
}

extension PostReply: CustomStringConvertible {

    var description: String {
        "post \(id): \(post)"
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
    private var status = "A"

    /// :nodoc:
    init() { }

    /// :nodoc:
    init(info: PostPayloadInfo) {
        post = info.post
        location = info.location
        location_id = location.id
    }

    /// Set Location
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
        "post for \(location_id): \(post)"
    }
}

/// Payload sent to API endpoint
struct PostUpdatePayload: Codable, Hashable {

    /// Post ID being updated
    let id: Int
    private let location: LocationPayload
    private let location_id: Int
    private let post: String
    private let status = "A"
    private let user_id: Int

    /// :nodoc:
    init(from: PostCellModel,
         with: PostPayload) {
        id = from.postId
        location = with.location
        location_id = with.location_id
        post = with.post
        user_id = from.user?.userId ?? 0
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

/// Payload stored in queue
final class PostPayloadInfo: NSObject, NSCoding {

    fileprivate let post: String
    fileprivate let location: LocationPayload

    private static let keys = (post: "post",
                               location: "location")

    /// :nodoc:
    init(post: String,
         location: LocationPayload) {
        self.post = post
        self.location = location
    }

    /// :nodoc:
    init(payload: PostPayload) {
        post = payload.post
        location = payload.location
    }

    /// :nodoc:
    required convenience init?(coder decoder: NSCoder) {
        guard let post = decoder.decodeObject(forKey: PostPayloadInfo.keys.post),
              let info = decoder.decodeObject(forKey: PostPayloadInfo.keys.location) else {
          return nil
        }
        // swiftlint:disable:next force_cast
        let location = LocationPayload(info: info as! LocationPayloadInfo)
        self.init(
            // swiftlint:disable:next force_cast
            post: post as! String,
            location: location
        )
    }

    /// :nodoc:
    func encode(with coder: NSCoder) {
        coder.encode(post, forKey: PostPayloadInfo.keys.post)
        let info = LocationPayloadInfo(payload: location)
        coder.encode(info, forKey: PostPayloadInfo.keys.location)
    }
}
