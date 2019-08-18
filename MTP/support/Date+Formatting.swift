// @copyright Trollwerks Inc.

import Foundation

extension Date {

    /// Convert to current time zone
    var toLocalTime: Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }

    /// Convert to UTC time zone
    var toUTC: Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
}

extension DateFormatter {

    /// Format dates like Facebook API
    static let fbDay = DateFormatter {
        $0.dateFormat = "MM/dd/yyyy"
        $0.calendar = Calendar(identifier: .iso8601)
        $0.timeZone = TimeZone(secondsFromGMT: 0)
        $0.locale = Locale(identifier: "en_US_POSIX")
    }

    /// Format UTC dates like MTP API
    static let mtpDay = DateFormatter {
        $0.dateFormat = "yyyy-MM-dd"
        $0.calendar = Calendar(identifier: .iso8601)
        $0.timeZone = TimeZone(secondsFromGMT: 0)
        $0.locale = Locale(identifier: "en_US_POSIX")
    }

    /// Format local dates like Facebook API
    static let mtpLocalDay = DateFormatter {
        $0.dateFormat = "yyyy-MM-dd"
        $0.calendar = Calendar(identifier: .iso8601)
        $0.timeZone = TimeZone.current
        $0.locale = Locale(identifier: "en_US_POSIX")
    }

    /// Format UTC times like MTP API
    static let mtpTime = DateFormatter {
        $0.dateFormat = "yyyy-MM-dd HH:mm:ss"
        $0.calendar = Calendar(identifier: .iso8601)
        $0.timeZone = TimeZone(secondsFromGMT: 0)
        $0.locale = Locale(identifier: "en_US_POSIX")
    }

    /// Format local times like Facebook API
    static var stampTime = DateFormatter {
        $0.dateFormat = "yy.MM.dd HH:mm:ss.SSS"
        $0.calendar = Calendar(identifier: .iso8601)
        $0.timeZone = TimeZone.current
        $0.locale = Locale(identifier: "en_US_POSIX")
    }

    /// Format UTC times for birthday
    static let mtpBirthday = DateFormatter(mtp: .medium)

    /// Format UTC times for post
    static let mtpPost = DateFormatter(mtp: .long)

    private convenience init(mtp style: DateFormatter.Style) {
        self.init()
        dateStyle = style
        timeStyle = .none
        timeZone = TimeZone(secondsFromGMT: 0)
    }
}

extension JSONDecoder {

    /// JSONDecoder that handles MTP format dates and times
    static let mtp: JSONDecoder = {
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            if let date = DateFormatter.mtpDay.date(from: dateString) {
                return date
            }
            if let date = DateFormatter.mtpTime.date(from: dateString) {
                return date
            }
            if dateString == "0000-00-00 00:00:00" {
                return Date()
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date: '\(dateString)'")
        }
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return decoder
    }()
}
