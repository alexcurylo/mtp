// @copyright Trollwerks Inc.

import RealmSwift

struct PostsJSON: Codable {

    let code: Int
    let data: [PostJSON]
    let paging: Bool
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
        paging: \(paging)
        data: \(data.debugDescription)
        /PostsJSON >
        """
    }
}

struct PostJSON: Codable {

    let createdAt: Date
    let id: Int
    let location: LocationJSON // still has 30 items
    let locationId: Int
    let post: String
    let status: String
    let updatedAt: Date
    let owner: UserJSON
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
        post: \(post)
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

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(from: PostJSON) {
        self.init()

        id = from.id
        locationId = from.locationId
        post = from.post
        updatedAt = from.updatedAt
    }
}
