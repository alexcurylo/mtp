// @copyright Trollwerks Inc.

import RealmSwift

struct PostsJSON: Codable {

    let code: Int
    let data: [PostJSON]
    // swiftlint:disable:next discouraged_optional_boolean
    let paging: Bool? // not in locations, always false for user
}

extension PostsJSON: CustomStringConvertible {

    public var description: String {
        return "PostsJSON: \(data.count)"
    }
}

extension PostsJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < PostsJSON: \(description):
        code: \(code)
        paging: \(String(describing: paging))
        data: \(data.debugDescription)
        /PostsJSON >
        """
    }
}

struct PostJSON: Codable {

    let createdAt: Date
    let id: Int
    let location: PlaceLocation // LocationJSON in user endpoint
    let locationId: Int
    let post: String?
    let status: String
    let updatedAt: Date
    let owner: OwnerJSON // UserJSON in user endpoint
    let userId: Int
}

extension PostJSON: CustomStringConvertible {

    public var description: String {
        return "PostJSON: \(locationId), \(id)"
    }
}

extension PostJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < PostJSON: \(description):
        createdAt: \(createdAt)
        id: \(id)
        location: \(location)
        locationId: \(locationId)
        post: \(String(describing: post))
        status: \(status)
        updatedAt: \(updatedAt)
        owner: \(owner)
        userId: \(userId)
        /PostJSON >
        """
    }
}

@objcMembers final class Post: Object {

    dynamic var id: Int = 0
    dynamic var locationId: Int = 0
    dynamic var post: String = ""
    dynamic var updatedAt = Date()
    dynamic var userId: Int = 0

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init?(from: PostJSON) {
        guard let text = from.post,
              !text.isEmpty,
              from.status == MTP.Status.published.rawValue else {
            return nil
        }

        self.init()

        id = from.id
        locationId = from.locationId
        post = text
        updatedAt = from.updatedAt
        userId = from.userId
    }

    convenience init?(from: PostReply) {
        self.init()

        id = from.id
        locationId = from.locationId
        post = from.post
        userId = from.userId
    }
}
