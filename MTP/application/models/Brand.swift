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

    /// Key found in Hotel JSON
    let slug: String
    /// Display title for user
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

    /// :nodoc:
    override static func primaryKey() -> String? {
        "slug"
    }

    /// Constructor from MTP endpoint data
    convenience init(from: BrandJSON) {
        self.init()

        slug = from.slug
        title = from.title
    }
}
