// @copyright Trollwerks Inc.

import RealmSwift

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
    let milestoneThresholds: MilestonesJSON
    //let rssFeeds: RSSFeedsJSON?
    //let worldMap: MapRenderJSON?
}

extension SettingsJSON: CustomStringConvertible {

    public var description: String {
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

struct DefaultEmailsJSON: Codable {

    private enum CodingKeys: String, CodingKey {
        case verificationRequest = "verification-request"
    }

    struct EmailJSON: Codable {

        let message: String
        let name: String
        let subject: String
    }

    let verificationRequest: EmailJSON
}

extension DefaultEmailsJSON: CustomStringConvertible {

    public var description: String {
        return "DefaultEmailsJSON: [verification-request]"
    }
}

extension DefaultEmailsJSON: CustomDebugStringConvertible {

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

struct MapRenderJSON: Codable {

    private enum CodingKeys: String, CodingKey {
        case fillColors = "fill-colors"
        case fillOpacities = "fill-opacities"
        case outlineColors = "outline-colors"
    }

    let fillColors: ColorsJSON
    let fillOpacities: OpacitiesJSON
    let outlineColors: ColorsJSON
}

extension MapRenderJSON: CustomStringConvertible {

    public var description: String {
        return "MapRenderJSON"
    }
}

extension MapRenderJSON: CustomDebugStringConvertible {

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

struct ColorsJSON: Codable {

    private enum CodingKeys: String, CodingKey {
        case remainingPolygon = "remaining-polygon"
        case visitedPolygon = "visited-polygon"
    }

    let remainingPolygon: String
    let visitedPolygon: String
}

extension ColorsJSON: CustomStringConvertible {

    public var description: String {
        return "ColorsJSON"
    }
}

extension ColorsJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < ColorsJSON: \(description):
        remainingPolygon: \(remainingPolygon))
        visitedPolygon: \(visitedPolygon)
        /ColorsJSON >
        """
    }
}

struct OpacitiesJSON: Codable {

    private enum CodingKeys: String, CodingKey {
        case remainingPolygon = "remaining-polygon"
        case visitedPolygon = "visited-polygon"
    }

    let remainingPolygon: Int
    let visitedPolygon: Int
}

extension OpacitiesJSON: CustomStringConvertible {

    public var description: String {
        return "OpacitiesJSON"
    }
}

extension OpacitiesJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < OpacitiesJSON: \(description):
        remainingPolygon: \(remainingPolygon))
        visitedPolygon: \(visitedPolygon)
        /OpacitiesJSON >
        """
    }
}

struct MilestonesJSON: Codable {

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
}

extension MilestonesJSON: CustomStringConvertible {

    public var description: String {
        return "MilestonesJSON"
    }
}

extension MilestonesJSON: CustomDebugStringConvertible {

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
struct RSSFeedsJSON: Codable {

    private enum CodingKeys: String, CodingKey {
        case travelNews = "travel-news"
    }

    struct FeedJSON: Codable {

        //let $$hashKey: String
        let icon: String
        let url: String
    }

    let travelNews: [FeedJSON]
}

extension RSSFeedsJSON: CustomStringConvertible {

    public var description: String {
        return "RSSFeedsJSON: [travel-news]"
    }
}

extension RSSFeedsJSON: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < RSSFeedsJSON: \(description):
        feeds: \(travelNews.count))
        /RSSFeedsJSON >
        """
    }
}

@objcMembers final class Threshold: Object {

    dynamic var min: Int = 0
    dynamic var max: Int = 0
    dynamic var name: String = ""

    dynamic var checklistValue: Int = Checklist.beaches.rawValue
    dynamic var index: Int = 0
    dynamic var dbKey: String = ""

    override static func primaryKey() -> String? {
        return "dbKey"
    }

    convenience init(from: MilestonesJSON.ThresholdsJSON,
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

@objcMembers final class Milestones: Object {

    dynamic var checklistValue: Int = Checklist.beaches.rawValue
    var checklist: Checklist {
        //swiftlint:disable:next force_unwrapping
        get { return Checklist(rawValue: checklistValue)! }
        set { checklistValue = newValue.rawValue }
    }

    let thresholds = List<Threshold>()

    override static func primaryKey() -> String? {
        return "checklistValue"
    }

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

    func milestone(count: Int) -> String {
        // swiftlint:disable:next first_where
        guard let threshold = thresholds.filter("min = \(count)").first else {
            return ""
        }
        return L.milestone(threshold.name)
    }
}
