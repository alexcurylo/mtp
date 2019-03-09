// @copyright Trollwerks Inc.

import Foundation

extension Date {

    var toLocalTime: Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }

    var toUTC: Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
}

extension DateFormatter {

    static let fbDay = DateFormatter {
        $0.dateFormat = "MM/dd/yyyy"
        $0.calendar = Calendar(identifier: .iso8601)
        $0.timeZone = TimeZone(secondsFromGMT: 0)
        $0.locale = Locale(identifier: "en_US_POSIX")
    }

    static let mtpDay = DateFormatter {
        $0.dateFormat = "yyyy-MM-dd"
        $0.calendar = Calendar(identifier: .iso8601)
        $0.timeZone = TimeZone(secondsFromGMT: 0)
        $0.locale = Locale(identifier: "en_US_POSIX")
    }

    static let mtpTime = DateFormatter {
        $0.dateFormat = "yyyy-MM-dd HH:mm:ss"
        $0.calendar = Calendar(identifier: .iso8601)
        $0.timeZone = TimeZone(secondsFromGMT: 0)
        $0.locale = Locale(identifier: "en_US_POSIX")
    }
}

extension JSONDecoder {

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
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date: '\(dateString)'")
        }
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return decoder
    }()
}
