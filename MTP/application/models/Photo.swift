// @copyright Trollwerks Inc.

import RealmSwift

/// Reply from the photos endpoints
struct PhotoReply: Codable {

    fileprivate let desc: String?
    fileprivate let id: Int
    fileprivate let location: LocationJSON?
    fileprivate let locationId: UncertainValue<Int, String>?
    fileprivate let mime: String
    fileprivate let name: String
    fileprivate let type: String
    fileprivate let uploaded: Int
    fileprivate let url: String
    fileprivate let userId: Int
    fileprivate let uuid: String
}

extension PhotoReply: CustomStringConvertible {

    var description: String {
        return "photo \(id) - \(uuid)"
    }
}

extension PhotoReply: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < PhotoReply: \(description):
        desc: \(String(describing: desc))
        id: \(id)
        location: \(String(describing: location))
        locationId: \(String(describing: locationId))
        mime: \(mime)
        name: \(name.isEmpty ? "empty" : name)
        type: \(type)
        uploaded: \(uploaded)
        url: \(url)
        userId: \(userId)
        uuid: \(uuid)
        /PhotoReply >
        """
    }
}

/// Photos endpoints reply
struct PhotosInfoJSON: Codable {

    /// HTTP result code
    let code: Int
    /// List of photos
    let data: [PhotoJSON]
}

extension PhotosInfoJSON: CustomStringConvertible {

    var description: String {
        return "PhotosInfoJSON (\(data.count))"
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

/// Photos page info received from MTP endpoints
struct PhotosPageInfoJSON: Codable {

    /// HTTP result code
    let code: Int
    /// List of photos
    let data: [PhotoJSON]
    /// Paging info
    let paging: PhotosPageJSON
}

extension PhotosPageInfoJSON: CustomStringConvertible {

    var description: String {
        return "PhotosPageInfoJSON: \(paging.currentPage)"
    }
}

extension PhotosPageInfoJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < PhotosPageInfoJSON: \(description):
        code: \(code)
        paging: \(paging.debugDescription)
        data: \(data.debugDescription)
        /PhotosPageInfoJSON >
        """
    }
}

/// Photos page info received from MTP endpoints
struct PhotosPageJSON: Codable {

    fileprivate let currentPage: Int
    fileprivate let lastPage: Int
    /// perPage
    let perPage: Int
    fileprivate let total: Int
    // let links: [] -- appears always empty
}

extension PhotosPageJSON: CustomStringConvertible {

    var description: String {
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

/// Post or photo owner info received from MTP endpoints
struct OwnerJSON: Codable {
    //let country: String? // UserJSON in user endpoints, null in location
    fileprivate let firstName: String
    /// fullName
    let fullName: String
    /// id
    let id: Int
    fileprivate let lastName: String
    //let location: String? // LocationJSON in user endpoint, null in location
    fileprivate let role: Int
}

/// Photo info received from MTP endpoints
struct PhotoJSON: Codable {

    //private struct PivotJSON: Codable {
        //let fileId: Int
        //let userId: Int
    //}

    fileprivate let createdAt: Date
    fileprivate let desc: String?
    fileprivate let id: Int
    fileprivate let location: LocationJSON? // still has 30 items
    fileprivate let locationId: Int?
    fileprivate let mime: String
    fileprivate let name: String
    fileprivate let owner: OwnerJSON? // only in location photos
    //private let pivot: PivotJSON? // not in location photos
    fileprivate let type: String
    fileprivate let updatedAt: Date
    fileprivate let userId: Int
    fileprivate let uuid: String
}

extension PhotoJSON: CustomStringConvertible {

    var description: String {
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
        name: \(name.isEmpty ? "empty" : name)
        type: \(type)
        updatedAt: \(updatedAt)
        userId: \(userId)
        uuid: \(uuid.isEmpty ? "empty" : uuid)
        /PhotoJSON >
        """
    }
}

/// Realm representation of a page of photos
@objcMembers final class PhotosPageInfo: Object {

    /// Expected items per page
    static let perPage = 25

    /// lastPage
    dynamic var lastPage: Int = 0
    /// page
    dynamic var page: Int = 0
    /// total
    dynamic var total: Int = 0
    /// userId
    dynamic var userId: Int = 0

    /// dbKey
    dynamic var dbKey: String = ""

    /// photoIds
    let photoIds = List<Int>()

    /// Realm unique identifier
    ///
    /// - Returns: unique identifier
    override static func primaryKey() -> String? {
        return "dbKey"
    }

    /// Constructor from MTP endpoint data
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

/// Realm representation of a photo
@objcMembers final class Photo: Object {

    /// desc
    dynamic var desc: String = ""
    /// locationId
    dynamic var locationId: Int = 0
    /// photoId
    dynamic var photoId: Int = 0
    /// updatedAt
    dynamic var updatedAt = Date()
    /// userId
    dynamic var userId: Int = 0
    /// uuid
    dynamic var uuid: String = ""

    /// Realm unique identifier
    ///
    /// - Returns: unique identifier
    override static func primaryKey() -> String? {
        return "photoId"
    }

    /// Constructor from MTP endpoint data
    convenience init(from: PhotoJSON) {
        self.init()

        desc = from.desc ?? ""
        locationId = from.locationId ?? 0
        photoId = from.id
        updatedAt = from.updatedAt
        userId = from.userId
        uuid = from.uuid
    }

    /// Constructor from MTP endpoint data
    convenience init(from: PhotoReply) {
        self.init()

        desc = from.desc ?? ""
        locationId = from.locationId?.intValue ?? 0
        photoId = from.id
        userId = from.userId
        uuid = from.uuid
    }

    /// Image URL if available
    var imageUrl: URL? {
        guard !uuid.isEmpty else { return nil }
        let target = MTP.picture(uuid: uuid, size: .any)
        return target.requestUrl
    }

    /// Attributed title string if available
    var attributedTitle: NSAttributedString? {
        guard !desc.isEmpty else { return nil }
        let attributes = NSAttributedString.attributes(
            color: .white,
            font: Avenir.heavy.of(size: 16)
        )
        return NSAttributedString(string: desc,
                                  attributes: attributes)
    }
}
