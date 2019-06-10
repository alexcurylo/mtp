// @copyright Trollwerks Inc.

import Foundation

struct SearchResultJSON: Codable {

    struct Request: Codable {
        let query: String
    }

    let request: Request
    let data: [SearchResultItemJSON]
}

extension SearchResultJSON: CustomStringConvertible {

    public var description: String {
        return "SearchResultJSON: \(request.query)"
    }
}

extension SearchResultJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < SearchResultJSON: \(description):
        data: \(data.debugDescription))
        /SearchResultJSON >
        """
    }
}

struct SearchResultItemJSON: Codable {

    let country: String?
    let firstName: String?
    let fullName: String?
    let id: Int
    let label: String
    let lastName: String?
    let link: String
    let location: String?
    let locationName: String?
    let role: Int?
    let type: String

    var isLocation: Bool { return type == "locations" }
    var isUser: Bool { return type == "users" }
 }

extension SearchResultItemJSON: CustomStringConvertible {

    public var description: String {
        return "SearchResultItemJSON"
    }
}

extension SearchResultItemJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
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
        role: \(String(describing: role))
        type: \(type)
        /SearchResultItemJSON >
        """
    }
}
