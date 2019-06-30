// @copyright Trollwerks Inc.

import RealmSwift

struct PhotosInfoJSON: Codable {

    let code: Int
    let data: [PhotoJSON]
}

extension PhotosInfoJSON: CustomStringConvertible {

    public var description: String {
        return "PhotosInfoJSON"
    }
}

extension PhotosInfoJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < PhotosInfoJSON: \(description):
        code: \(code)
        data: \(data.debugDescription))
        /PhotosInfoJSON >
        """
    }
}

struct PhotosPageInfoJSON: Codable {

    let code: Int
    let data: [PhotoJSON]
    let paging: PhotosPageJSON
}

extension PhotosPageInfoJSON: CustomStringConvertible {

    public var description: String {
        return "PhotosPageInfoJSON: \(paging.currentPage)"
    }
}

extension PhotosPageInfoJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < PhotosPageInfoJSON: \(description):
        code: \(code)
        data: \(data.debugDescription))
        paging: \(paging.debugDescription))
        /PhotosPageInfoJSON >
        """
    }
}

struct PhotosPageJSON: Codable {

    let currentPage: Int
    let lastPage: Int
    let perPage: Int
    let total: Int
    // let links: [] -- appears always empty
}

extension PhotosPageJSON: CustomStringConvertible {

    public var description: String {
        return "PhotosPageJSON: \(currentPage) \(lastPage)"
    }
}

extension PhotosPageJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < PhotosPageJSON: \(description):
        currentPage: \(currentPage)
        lastPage: \(lastPage)
        perPage: \(perPage)
        total: \(total)
        /PhotosPageJSON >
        """
    }
}

struct OwnerJSON: Codable {
    //let country: String? // UserJSON in user endpoints, null in location
    let firstName: String
    let fullName: String
    let id: Int
    let lastName: String
    //let location: String? // LocationJSON in user endpoint, null in location
    let role: Int
}

struct PhotoJSON: Codable {

    struct PivotJSON: Codable {
        let fileId: Int
        let userId: Int
    }

    let createdAt: Date
    let desc: String?
    let id: Int
    let location: LocationJSON? // still has 30 items
    let locationId: Int?
    let mime: String
    let name: String
    let owner: OwnerJSON? // only in location photos
    let pivot: PivotJSON? // not in location photos
    let type: String
    let updatedAt: Date
    let userId: Int
    let uuid: String
}

extension PhotoJSON: CustomStringConvertible {

    public var description: String {
        return "PhotoJSON: \(id) \(name)"
    }
}

extension PhotoJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < PhotoJSON: \(description):
        createdAt: \(createdAt)
        desc: \(String(describing: desc))
        id: \(id)
        location: \(String(describing: location))
        locationId: \(String(describing: locationId))
        mime: \(mime)
        name: \(name)
        pivot: \(String(describing: pivot))
        type: \(type)
        updatedAt: \(updatedAt)
        userId: \(userId)
        uuid: \(uuid)
        /PhotoJSON >
        """
    }
}

@objcMembers final class PhotosPageInfo: Object {

    static let perPage = 25

    dynamic var lastPage: Int = 0
    dynamic var page: Int = 0
    dynamic var total: Int = 0
    dynamic var userId: Int = 0

    dynamic var dbKey: String = ""

    let photoIds = List<Int>()

    override static func primaryKey() -> String? {
        return "dbKey"
    }

    convenience init(user id: Int,
                     info: PhotosPageInfoJSON) {
        self.init()

        userId = id
        page = info.paging.currentPage
        lastPage = info.paging.lastPage
        total = info.paging.total

        dbKey = "userId=\(userId)?page=\(page)"

        info.data.forEach { photoIds.append($0.id) }
    }
}

@objcMembers final class Photo: Object {

    dynamic var desc: String = ""
    dynamic var id: Int = 0
    dynamic var locationId: Int = 0
    dynamic var updatedAt = Date()
    dynamic var userId: Int = 0
    dynamic var uuid: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(from: PhotoJSON) {
        self.init()

        desc = from.desc ?? ""
        id = from.id
        locationId = from.locationId ?? 0
        updatedAt = from.updatedAt
        userId = from.userId
        uuid = from.uuid
    }

    convenience init(from: PhotoReply) {
        self.init()

        desc = from.desc ?? ""
        id = from.id
        locationId = from.locationId ?? 0
        userId = from.userId
        uuid = from.uuid
    }

    var imageUrl: URL? {
        guard !uuid.isEmpty else { return nil }
        let target = MTP.picture(uuid: uuid, size: .any)
        return target.requestUrl
    }
}
