// @copyright Trollwerks Inc.

import Foundation

/// FAQ info received from MTP endpoints
struct FaqJSON: Codable {

    /// id
    let id: Int
    // let userID: Int
    /// title
    let title: String
    /// category
    let category: Int
    /// status
    let status: String
    /// slug
    let slug: String
    /// content
    let content: String
    /// featuredImg
    let featuredImg: String
    /// createdAt
    let createdAt: String
    /// updatedAt
    let updatedAt: String
    /// headerImg
    let headerImg: String?
    // let author: UserJSON
}

extension FaqJSON: CustomStringConvertible {

    var description: String { "Faq" }
}

extension FaqJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        """
        < Faq: \(description):
        title: \(title))
        content: \(content)
        /FaqJSON >
        """
    }
}
