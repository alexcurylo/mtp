// @copyright Trollwerks Inc.

import Nuke
import RealmSwift

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

struct PhotoJSON: Codable {

    struct PivotJSON: Codable {
        let fileId: Int
        let userId: Int
    }

    let createdAt: Date
    let desc: String
    let id: Int
    let location: LocationJSON? // still has 30 items
    let locationId: Int?
    let mime: String
    let name: String
    let pivot: PivotJSON
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
        desc: \(desc)
        id: \(id)
        location: \(String(describing: location))
        locationId: \(String(describing: locationId))
        mime: \(mime)
        name: \(name)
        pivot: \(pivot)
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
    dynamic var queryKey: String = ""
    dynamic var dbKey: String = ""
    let photoIds = List<Int>()

    override static func primaryKey() -> String? {
        return "dbKey"
    }

    convenience init(info: PhotosPageInfoJSON) {
        self.init()

        page = info.paging.currentPage
        lastPage = info.paging.lastPage

        queryKey = "me"
        dbKey = "userId=\(queryKey)?page=\(page)"

        info.data.forEach { photoIds.append($0.id) }
    }
}

@objcMembers final class Photo: Object {

    dynamic var id: Int = 0
    dynamic var updatedAt = Date()
    dynamic var uuid: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(from: PhotoJSON) {
        self.init()

        id = from.id
        updatedAt = from.updatedAt
        uuid = from.uuid
    }

    var imageUrl: URL? {
        guard !uuid.isEmpty else { return nil }
        let link = "https://mtp.travel/api/files/preview?uuid=\(uuid)"
        return URL(string: link)
    }
}

extension UIImageView {

    func set(thumbnail photo: Photo?) {
        let placeholder = R.image.placeholderThumb()
        guard let url = photo?.imageUrl else {
            image = placeholder
            return
        }

        Nuke.loadImage(
            with: url,
            options: ImageLoadingOptions(
                placeholder: placeholder,
                transition: .fadeIn(duration: 0.2)
            ),
            into: self
        )
    }
}
