// @copyright Trollwerks Inc.

import RealmSwift

/// Settings info received from MTP endpoints
struct SettingsJSON: Codable {

    private enum CodingKeys: String, CodingKey {
        //case accident = "fill-it-later-accedintal-added-by-pitt"
        //case defaultEmails = "default-emails"
        //case locationMap = "location-map"
        case milestoneThresholds = "milestone-thresholds"
        //case rssFeeds = "rss-feeds"
        //case worldMap = "world-map"
    }

    //let accident: String?
    //let defaultEmails: DefaultEmailsJSON?
    //let locationMap: MapRenderJSON?
    fileprivate let milestoneThresholds: MilestonesJSON
    //let rssFeeds: RSSFeedsJSON?
    //let worldMap: MapRenderJSON?
}

extension SettingsJSON: CustomStringConvertible {

    var description: String {
        return "Settings"
    }
}

extension SettingsJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < Settings: \(description):
        milestoneThresholds: \(milestoneThresholds)
        /SettingsJSON >
        """
    }
}

private struct DefaultEmailsJSON: Codable, CustomStringConvertible, CustomDebugStringConvertible {

    private enum CodingKeys: String, CodingKey {
        case verificationRequest = "verification-request"
    }

    struct EmailJSON: Codable {

        let message: String
        let name: String
        let subject: String
    }

    let verificationRequest: EmailJSON

    var description: String {
        return "DefaultEmailsJSON: [verification-request]"
    }

    var debugDescription: String {
        return """
        < DefaultEmailsJSON: \(description):
        message: \(verificationRequest.message))
        name: \(verificationRequest.name)
        subject: \(verificationRequest.subject)
        /DefaultEmailsJSON >
        """
    }
}

private struct MapRenderJSON: Codable, CustomStringConvertible, CustomDebugStringConvertible {

    private enum CodingKeys: String, CodingKey {
        case fillColors = "fill-colors"
        case fillOpacities = "fill-opacities"
        case outlineColors = "outline-colors"
    }

    let fillColors: ColorsJSON
    let fillOpacities: OpacitiesJSON
    let outlineColors: ColorsJSON

    var description: String {
        return "MapRenderJSON"
    }

    var debugDescription: String {
        return """
        < MapRenderJSON: \(description):
        fillColors: \(fillColors))
        fillOpacities: \(fillOpacities)
        outlineColors: \(outlineColors)
        /MapRenderJSON >
        """
    }
}

private struct ColorsJSON: Codable, CustomStringConvertible, CustomDebugStringConvertible {

    private enum CodingKeys: String, CodingKey {
        case remainingPolygon = "remaining-polygon"
        case visitedPolygon = "visited-polygon"
    }

    let remainingPolygon: String
    let visitedPolygon: String

    var description: String {
        return "ColorsJSON"
    }

    var debugDescription: String {
        return """
        < ColorsJSON: \(description):
        remainingPolygon: \(remainingPolygon))
        visitedPolygon: \(visitedPolygon)
        /ColorsJSON >
        """
    }
}

private struct OpacitiesJSON: Codable, CustomStringConvertible, CustomDebugStringConvertible {

    private enum CodingKeys: String, CodingKey {
        case remainingPolygon = "remaining-polygon"
        case visitedPolygon = "visited-polygon"
    }

    let remainingPolygon: Int
    let visitedPolygon: Int

    var description: String {
        return "OpacitiesJSON"
    }

    var debugDescription: String {
        return """
        < OpacitiesJSON: \(description):
        remainingPolygon: \(remainingPolygon))
        visitedPolygon: \(visitedPolygon)
        /OpacitiesJSON >
        """
    }
}

private struct MilestonesJSON: Codable, CustomStringConvertible, CustomDebugStringConvertible {

    struct ThresholdsJSON: Codable {

        //let $$hashKey: String
        let min: Int
        let max: Int
        let name: String
    }

    let beaches: [ThresholdsJSON]
    let divesites: [ThresholdsJSON]
    let golfcourses: [ThresholdsJSON]
    let locations: [ThresholdsJSON]
    let restaurants: [ThresholdsJSON]
    let uncountries: [ThresholdsJSON]
    let whss: [ThresholdsJSON]

    func thresholds(list: Checklist) -> [ThresholdsJSON] {
        switch list {
        case .locations:
            return locations
        case .uncountries:
            return uncountries
        case .whss:
            return whss
        case .beaches:
            return beaches
        case .golfcourses:
            return golfcourses
        case .divesites:
            return divesites
        case .restaurants:
            return restaurants
        }
    }

    var description: String {
        return "MilestonesJSON"
    }

    var debugDescription: String {
        return """
        < MilestonesJSON: \(description):
        beaches: \(beaches.count))
        divesites: \(divesites.count))
        golfcourses: \(golfcourses.count))
        locations: \(locations.count))
        restaurants: \(restaurants.count))
        uncountries: \(uncountries.count))
        whss: \(whss.count))
        /MilestonesJSON >
        """
    }
}

private struct RSSFeedsJSON: Codable, CustomStringConvertible, CustomDebugStringConvertible {

    private enum CodingKeys: String, CodingKey {
        case travelNews = "travel-news"
    }

    struct FeedJSON: Codable {

        //let $$hashKey: String
        let icon: String
        let url: String
    }

    let travelNews: [FeedJSON]

    var description: String {
        return "RSSFeedsJSON: [travel-news]"
    }

    var debugDescription: String {
        return """
        < RSSFeedsJSON: \(description):
        feeds: \(travelNews.count))
        /RSSFeedsJSON >
        """
    }
}

/// Realm representation of a milestone message
@objcMembers final class Threshold: Object {

    /// min
    dynamic var min: Int = 0
    /// max
    dynamic var max: Int = 0
    /// name
    dynamic var name: String = ""

    /// checklistValue
    dynamic var checklistValue: Int = Checklist.beaches.rawValue
    /// index
    dynamic var index: Int = 0
    /// dbKey
    dynamic var dbKey: String = ""

    /// Realm unique identifier
    ///
    /// - Returns: unique identifier
    override static func primaryKey() -> String? {
        return "dbKey"
    }

    fileprivate convenience init(from: MilestonesJSON.ThresholdsJSON,
                                 list: Checklist,
                                 index: Int) {
        self.init()

        min = from.min
        max = from.max
        name = from.name

        checklistValue = list.rawValue
        self.index = index
        dbKey = "list=\(checklistValue)?index=\(index)"
    }
}

/// Realm representation of a collection of Thresholds
@objcMembers final class Milestones: Object {

    /// checklistValue
    dynamic var checklistValue: Int = Checklist.beaches.rawValue
    /// checklist
    var checklist: Checklist {
        //swiftlint:disable:next force_unwrapping
        get { return Checklist(rawValue: checklistValue)! }
        set { checklistValue = newValue.rawValue }
    }

    /// thresholds
    let thresholds = List<Threshold>()

    /// Realm unique identifier
    ///
    /// - Returns: unique identifier
    override static func primaryKey() -> String? {
        return "checklistValue"
    }

    /// Constructor from MTP endpoint data
    convenience init(from: SettingsJSON,
                     list: Checklist) {
        self.init()

        checklist = list
        let jsons = from.milestoneThresholds.thresholds(list: list)
        for (index, json) in jsons.enumerated() {
            let threshold = Threshold(from: json,
                                      list: list,
                                      index: index)
            thresholds.append(threshold)
        }
    }

    /// Milestone text if any
    ///
    /// - Parameter count: New count
    /// - Returns: Milestone text if appropriate
    func milestone(count: Int) -> String {
        // swiftlint:disable:next first_where
        guard let threshold = thresholds.filter("min = \(count)").first else {
            return ""
        }
        return L.milestone(threshold.name)
    }
}
