// @copyright Trollwerks Inc.

import Foundation

/// Reply from the search endpoint
struct SearchResultJSON: Codable {

    /// returned copy of request
    struct Request: Codable {

        /// query
        let query: String
    }

    /// returned copy of request
    let request: Request
    /// results
    let data: [SearchResultItemJSON]
}

extension SearchResultJSON: CustomStringConvertible {

    var description: String {
        "SearchResultJSON: \(request.query)"
    }
}

extension SearchResultJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        """
        < SearchResultJSON: \(request.query):
        data: \(data.debugDescription)
        /SearchResultJSON >
        """
    }
}

/// Reply from the search endpoint
struct SearchResultItemJSON: Codable {

    fileprivate let country: String?
    fileprivate let firstName: String?
    fileprivate let fullName: String?
    /// id
    let id: Int
    /// label - treated as full name for display
    let label: String
    fileprivate let lastName: String?
    fileprivate let link: String
    fileprivate let location: String?
    fileprivate let locationName: String?
    fileprivate let type: String

    /// Is this a location search result?
    var isLocation: Bool { type == "locations" }
    /// Is this a user search result?
    var isUser: Bool { type == "users" }
 }

extension SearchResultItemJSON: CustomStringConvertible {

    var description: String {
        "SearchResultItemJSON \(id)"
    }
}

extension SearchResultItemJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        """
        < SearchResultItemJSON: \(description):
        country: \(String(describing: country))
        firstName: \(String(describing: firstName))
        fullName: \(String(describing: fullName))
        id: \(id)
        label: \(label)
        lastName: \(String(describing: lastName))
        link: \(link)
        location: \(String(describing: location))
        locationName: \(String(describing: locationName))
        type: \(type)
        /SearchResultItemJSON >
        """
    }
}
