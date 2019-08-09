// @copyright Trollwerks Inc.

import Foundation

/// FAQ info received from MTP endpoints
private struct FaqJSON: Codable {

    let id: Int
    //let userID: Int
    let title: String
    let category: Int
    let status: String
    let slug: String
    let content: String
    let featuredImg: String
    let createdAt: String
    let updatedAt: String
    let headerImg: String?
    //let author: UserJSON
}

extension FaqJSON: CustomStringConvertible {

    var description: String {
        return "Faq"
    }
}

extension FaqJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < Faq: \(description):
        title: \(title))
        content: \(content)
        /FaqJSON >
        """
    }
}