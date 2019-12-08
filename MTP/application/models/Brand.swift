// @copyright Trollwerks Inc.

import RealmSwift

/// Brands endpoint reply
struct BrandsJSON: Codable {

    /// Brands info
    struct Info: Codable {

        // slug
        // names
        // title
        // model
        // controller
        // api_endpoint

        /// brands
        let brands: [BrandJSON]
    }

    /// Brands info
    let data: Info
}

/// Brand info
struct BrandJSON: Codable, CustomStringConvertible {

    let slug: String
    let title: String

    var description: String {
        "\(slug)=\(title)"
    }
}

/// Realm representation of a brand
@objcMembers final class Brand: Object {

    /// slug
    dynamic var slug: String = ""
    /// title
    dynamic var title: String = ""

    /// Realm unique identifier
    ///
    /// - Returns: unique identifier
    override static func primaryKey() -> String? {
        "slug"
    }

    convenience init(from: BrandJSON) {
        self.init()

        slug = from.slug
        title = from.title
    }
}
