// @copyright Trollwerks Inc.

// from https://github.com/inket/DateHelper/commit/b19234efe4d0ebc14acdce2506c5ab14f2f98c33

//
//  AFDateHelper.swift
//  https://github.com/melvitax/DateHelper
//  Version 4.2.8
//
//  Created by Melvin Rivera on 7/15/14.
//  Copyright (c) 2014. All rights reserved.
//

import Rswift

// swiftlint:disable file_length

extension Date {

    // MARK: Convert from String

    /// Initializes a new Date() objext based on a date string, format, optional timezone and optional locale
    ///
    /// - Parameters:
    ///   - string: Source to format
    ///   - format: Format to apply
    ///   - zone: Time zone
    ///   - locale: Locale
    init?(fromString string: String,
          format: DateFormat,
          zone: TimeZoneType = .current,
          locale: Locale = .current) {
        guard !string.isEmpty else { return nil }

        var string = string
        switch format {
        case .dotNet:
            let pattern = "\\\\?/Date\\((\\d+)(([+-]\\d{2})(\\d{2}))?\\)\\\\?/"
            //swiftlint:disable:next force_try
            let regex = try! NSRegularExpression(pattern: pattern)
            guard let match = regex.firstMatch(in: string,
                                               range: NSRange(location: 0,
                                                              length: string.utf16.count)) else {
                return nil
            }
            let dateString = (string as NSString).substring(with: match.range(at: 1))
            let interval = (Double(dateString) ?? 0) / 1_000.0
            self.init(timeIntervalSince1970: interval)
            return
        case .rss, .altRSS:
            if string.hasSuffix("Z") {
                string = string[..<string.index(string.endIndex, offsetBy: -1)].appending("GMT")
            }
        default:
            break
        }
        let formatter = Date.cachedFormatter(format: format,
                                             zone: zone,
                                             locale: locale)
        guard let date = formatter.date(from: string) else {
            return nil
        }
        self.init(timeInterval: 0, since: date)
    }

    // MARK: Convert to String

    /// Converts the date to string using the short date and time style.
    ///
    /// - Parameter style: DateStyleType
    /// - Returns: Formatted string
    func toString(style: DateStyle = .short) -> String {
        switch style {
        case .short:
            return self.toString(dateStyle: .short, timeStyle: .short, isRelative: false)
        case .medium:
            return self.toString(dateStyle: .medium, timeStyle: .medium, isRelative: false)
        case .long:
            return self.toString(dateStyle: .long, timeStyle: .long, isRelative: false)
        case .full:
            return self.toString(dateStyle: .full, timeStyle: .full, isRelative: false)
        case .ordinalDay:
            let formatter = Date.cachedOrdinalNumberFormatter
            formatter.numberStyle = .ordinal
            return formatter.string(from: (component(.day) ?? 0) as NSNumber) ?? ""
        case .weekday:
            guard let weekday = component(.weekday),
                  let weekdaySymbols = Date.cachedFormatter().weekdaySymbols else { return "" }
            return weekdaySymbols[weekday - 1]
        case .shortWeekday:
            guard let weekday = component(.weekday),
                  let shortWeekdaySymbols = Date.cachedFormatter().shortWeekdaySymbols else { return "" }
            return shortWeekdaySymbols[weekday - 1]
        case .veryShortWeekday:
            guard let weekday = component(.weekday),
                  let veryShortWeekdaySymbols = Date.cachedFormatter().veryShortWeekdaySymbols else { return "" }
            return veryShortWeekdaySymbols[weekday - 1]
        case .month:
            guard let month = component(.month),
                  let monthSymbols = Date.cachedFormatter().monthSymbols else { return "" }
            return monthSymbols[month - 1]
        case .shortMonth:
            guard let month = component(.month),
                  let shortMonthSymbols = Date.cachedFormatter().shortMonthSymbols else { return "" }
            return shortMonthSymbols[month - 1]
        case .veryShortMonth:
            guard let month = component(.month),
                  let veryShortMonthSymbols = Date.cachedFormatter().veryShortMonthSymbols else { return "" }
            return veryShortMonthSymbols[month - 1]
        }
    }

    /// Converts the date to string based on a date format, optional timezone and optional locale.
    ///
    /// - Parameters:
    ///   - format: Format
    ///   - zone: Time zone
    ///   - locale: Locale
    /// - Returns: Formatted string
    func toString(format: DateFormat,
                  zone: TimeZoneType = .current,
                  locale: Locale = .current) -> String {
        switch format {
        case .dotNet:
            let offset = TimeZoneType.default.timeZone.secondsFromGMT() / 3_600
            let nowMillis = 1_000 * self.timeIntervalSince1970
            return String(format: format.stringFormat, nowMillis, offset)
        default:
            break
        }
        let formatter = Date.cachedFormatter(format: format,
                                             zone: zone,
                                             locale: locale)
        return formatter.string(from: self)
    }

    /// Converts the date to string based on DateFormatter's date style and
    /// time style with optional relative date formatting, optional time zone
    /// and optional locale.
    ///
    /// - Parameters:
    ///   - dateStyle: Date style
    ///   - timeStyle: Time style
    ///   - isRelative: Format with relative strings?
    ///   - zone: Time zone
    ///   - locale: Locale
    /// - Returns: Formatted string
    func toString(dateStyle: DateFormatter.Style,
                  timeStyle: DateFormatter.Style,
                  isRelative: Bool = false,
                  zone: TimeZoneType = .current,
                  locale: Locale = .current) -> String {
        let formatter = Date.cachedFormatter(dateStyle,
                                             timeStyle: timeStyle,
                                             relative: isRelative,
                                             zone: zone,
                                             locale: locale)
        return formatter.string(from: self)
    }

    /// Converts the date to string based on a relative time language. i.e. just now, 1 minute ago etc...
    ///
    /// - Parameter style: Time style
    /// - Returns: Formatted string
    func toStringWithRelativeTime(style: RelativeTimeStyle = .regular) -> String {
        // swiftlint:disable:previous cyclomatic_complexity function_body_length
        let time = self.timeIntervalSince1970
        let now = Date().timeIntervalSince1970
        let isPast = now - time > 0

        let sec: Double = abs(now - time)
        let min: Double = round(sec / 60)
        let hr: Double = round(min / 60)
        let d: Double = round(hr / 24)

        func format(for type: RelativeTime) -> String {
            if let resource = style.formats[type] {
                //swiftlint:disable:next nslocalizedstring_key
                return NSLocalizedString(resource.key,
                                         bundle: resource.bundle,
                                         comment: resource.comment ?? "")
            }
            return ""
        }

        if sec < 60 {
            if sec < 10 {
                return String(format: format(for: isPast ? .nowPast : .nowFuture), sec)
            } else {
                return String(format: format(for: isPast ? .secondsPast : .secondsFuture), sec)
            }
        }
        if min < 60 {
            if min == 1 {
                return String(format: format(for: isPast ? .oneMinutePast : .oneMinuteFuture), min)
            } else {
                return String(format: format(for: isPast ? .minutesPast : .minutesFuture), min)
            }
        }
        if hr < 24 {
            if hr == 1 {
                return String(format: format(for: isPast ? .oneHourPast : .oneHourFuture), hr)
            } else {
                return String(format: format(for: isPast ? .hoursPast : .hoursFuture), hr)
            }
        }
        if d < 7 {
            if d == 1 {
                return String(format: format(for: isPast ? .oneDayPast : .oneDayFuture), d)
            } else {
                return String(format: format(for: isPast ? .daysPast : .daysFuture), d)
            }
        }
        if d < 28 {
            if isPast {
                let formatString = format(for: compare(.isLastWeek) ? .oneWeekPast : .weeksPast)
                return String(format: formatString, Double(abs(since(Date(), in: .week))))
            } else {
                let formatString = format(for: compare(.isNextWeek) ? .oneWeekFuture : .weeksFuture)
                return String(format: formatString, Double(abs(since(Date(), in: .week))))
            }
        }
        if compare(.isThisYear) {
            if isPast {
                let formatString = format(for: compare(.isLastMonth) ? .oneMonthPast : .monthsPast)
                return String(format: formatString, Double(abs(since(Date(), in: .month))))
            } else {
                let formatString = format(for: compare(.isNextMonth) ? .oneMonthFuture : .monthsFuture)
                return String(format: formatString, Double(abs(since(Date(), in: .month))))
            }
        }
        if isPast {
            let formatString = format(for: compare(.isLastYear) ? .oneYearPast : .yearsPast)
            return String(format: formatString, Double(abs(since(Date(), in: .year))))
        } else {
            let formatString = format(for: compare(.isNextYear) ? .oneYearFuture : .yearsFuture)
            return String(format: formatString, Double(abs(since(Date(), in: .year))))
        }
    }

    // MARK: Compare Dates

    /// Compares dates to see if they are equal while ignoring time.
    ///
    /// - Parameter comparison: Comparison type
    /// - Returns: Equality
    func compare(_ comparison: DateComparison) -> Bool {
        // swiftlint:disable:previous function_body_length
        switch comparison {
        case .isToday:
            return compare(.isSameDay(as: Date()))
        case .isTomorrow:
            let comparison = Date().adjust(.day, offset: 1)
            return compare(.isSameDay(as: comparison))
        case .isYesterday:
            let comparison = Date().adjust(.day, offset: -1)
            return compare(.isSameDay(as: comparison))
        case .isSameDay(let date):
            return component(.year) == date.component(.year)
                && component(.month) == date.component(.month)
                && component(.day) == date.component(.day)
        case .isThisWeek:
            return self.compare(.isSameWeek(as: Date()))
        case .isNextWeek:
            let comparison = Date().adjust(.week, offset: 1)
            return compare(.isSameWeek(as: comparison))
        case .isLastWeek:
            let comparison = Date().adjust(.week, offset: -1)
            return compare(.isSameWeek(as: comparison))
        case .isSameWeek(let date):
            if component(.week) != date.component(.week) {
                return false
            }
            // Ensure time interval is under 1 week
            return abs(self.timeIntervalSince(date)) < Date.weekInSeconds
        case .isThisMonth:
            return self.compare(.isSameMonth(as: Date()))
        case .isNextMonth:
            let comparison = Date().adjust(.month, offset: 1)
            return compare(.isSameMonth(as: comparison))
        case .isLastMonth:
            let comparison = Date().adjust(.month, offset: -1)
            return compare(.isSameMonth(as: comparison))
        case .isSameMonth(let date):
            return component(.year) == date.component(.year) && component(.month) == date.component(.month)
        case .isThisYear:
            return self.compare(.isSameYear(as: Date()))
        case .isNextYear:
            let comparison = Date().adjust(.year, offset: 1)
            return compare(.isSameYear(as: comparison))
        case .isLastYear:
            let comparison = Date().adjust(.year, offset: -1)
            return compare(.isSameYear(as: comparison))
        case .isSameYear(let date):
            return component(.year) == date.component(.year)
        case .isInTheFuture:
            return self.compare(.isLater(than: Date()))
        case .isInThePast:
            return self.compare(.isEarlier(than: Date()))
        case .isEarlier(let date):
            return (self as NSDate).earlierDate(date) == self
        case .isLater(let date):
            return (self as NSDate).laterDate(date) == self
        case .isWeekday:
            return !compare(.isWeekend)
        case .isWeekend:
            guard let range = Calendar.current.maximumRange(of: .weekday) else { return false }
            return (component(.weekday) == range.lowerBound ||
                   component(.weekday) == range.upperBound - range.lowerBound)
        }
    }

    // MARK: Adjust dates

    /// Creates a new date with adjusted components
    ///
    /// - Parameters:
    ///   - component: Component to adjust
    ///   - offset: Adjust offset
    /// - Returns: New date
    func adjust(_ component: DateComponent, offset: Int) -> Date {
        var dateComp = DateComponents()
        switch component {
        case .second:
            dateComp.second = offset
        case .minute:
            dateComp.minute = offset
        case .hour:
            dateComp.hour = offset
        case .day:
            dateComp.day = offset
        case .weekday:
            dateComp.weekday = offset
        case .nthWeekday:
            dateComp.weekdayOrdinal = offset
        case .week:
            dateComp.weekOfYear = offset
        case .month:
            dateComp.month = offset
        case .year:
            dateComp.year = offset
        }
        return Calendar.current.date(byAdding: dateComp, to: self) ?? self
    }

    /// Return a new Date object with the new hour, minute and seconds values.
    ///
    /// - Parameters:
    ///   - hour: Hour
    ///   - minute: Minute
    ///   - second: Second
    ///   - day: Day
    ///   - month: Month
    /// - Returns: New date
    func adjust(hour: Int?, minute: Int?, second: Int?, day: Int? = nil, month: Int? = nil) -> Date {
        var comp = Date.components(self)
        comp.month = month ?? comp.month
        comp.day = day ?? comp.day
        comp.hour = hour ?? comp.hour
        comp.minute = minute ?? comp.minute
        comp.second = second ?? comp.second
        return Calendar.current.date(from: comp) ?? self
    }

    // MARK: Date for...

    /// Create date for type
    ///
    /// - Parameters:
    ///   - type: DateForType
    ///   - calendar: Calendar
    /// - Returns: New date
    func dateFor(_ type: DateFor, calendar: Calendar = .current) -> Date {
        switch type {
        case .startOfDay:
            return adjust(hour: 0, minute: 0, second: 0)
        case .endOfDay:
            return adjust(hour: 23, minute: 59, second: 59)
        case .startOfWeek:
            let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
            return calendar.date(from: components) ?? self
        case .endOfWeek:
            let weekBeginDate = self.dateFor(.startOfWeek, calendar: calendar)
            return weekBeginDate.adjust(.day, offset: 6)
        case .startOfMonth:
            return adjust(hour: 0, minute: 0, second: 0, day: 1)
        case .endOfMonth:
            let month = (component(.month) ?? 0) + 1
            return adjust(hour: 0, minute: 0, second: 0, day: 0, month: month)
        case .tomorrow:
            return adjust(.day, offset: 1)
        case .yesterday:
            return adjust(.day, offset: -1)
        case .nearestMinute(let nearest):
            guard let minute = component(.minute) else { return self }
            let minutes = (minute + nearest / 2) / nearest * nearest
            return adjust(hour: nil, minute: minutes, second: nil)
        case .nearestHour(let nearest):
            guard let hour = component(.hour) else { return self }
            let hours = (hour + nearest / 2) / nearest * nearest
            return adjust(hour: hours, minute: 0, second: nil)
        }
    }

    // MARK: Time since...

    /// Time components since date
    ///
    /// - Parameters:
    ///   - date: Date
    ///   - component: Component
    /// - Returns: Number of components elapsed
    func since(_ date: Date, in component: DateComponent) -> Int64 {
        let calendar = Calendar.current
        let end: Int
        let start: Int
        switch component {
        case .second:
            return Int64(timeIntervalSince(date))
        case .minute:
            let interval = timeIntervalSince(date)
            return Int64(interval / Date.minuteInSeconds)
        case .hour:
            let interval = timeIntervalSince(date)
            return Int64(interval / Date.hourInSeconds)
        case .day:
            end = calendar.ordinality(of: .day, in: .era, for: self) ?? 0
            start = calendar.ordinality(of: .day, in: .era, for: date) ?? 0
        case .weekday:
            end = calendar.ordinality(of: .weekday, in: .era, for: self) ?? 0
            start = calendar.ordinality(of: .weekday, in: .era, for: date) ?? 0
        case .nthWeekday:
            end = calendar.ordinality(of: .weekdayOrdinal, in: .era, for: self) ?? 0
            start = calendar.ordinality(of: .weekdayOrdinal, in: .era, for: date) ?? 0
        case .week:
            end = calendar.ordinality(of: .weekOfYear, in: .era, for: self) ?? 0
            start = calendar.ordinality(of: .weekOfYear, in: .era, for: date) ?? 0
        case .month:
            end = calendar.ordinality(of: .month, in: .era, for: self) ?? 0
            start = calendar.ordinality(of: .month, in: .era, for: date) ?? 0
        case .year:
            end = calendar.ordinality(of: .year, in: .era, for: self) ?? 0
            start = calendar.ordinality(of: .year, in: .era, for: date) ?? 0
        }
        return Int64(end - start)
    }

    // MARK: Extracting components

    /// Extract component
    ///
    /// - Parameter component: Component
    /// - Returns: Value if present
    func component(_ component: DateComponent) -> Int? {
        let components = Date.components(self)
        switch component {
        case .second:
            return components.second
        case .minute:
            return components.minute
        case .hour:
            return components.hour
        case .day:
            return components.day
        case .weekday:
            return components.weekday
        case .nthWeekday:
            return components.weekdayOrdinal
        case .week:
            return components.weekOfYear
        case .month:
            return components.month
        case .year:
            return components.year
        }
    }

    /// Number of days in current month
    ///
    /// - Returns: Int
    func numberOfDaysInMonth() -> Int {
        guard let range = Calendar.current.range(of: .day, in: .month, for: self) else { return 0 }
        return range.upperBound - range.lowerBound
    }

    /// First day of week
    ///
    /// - Returns: Int
    func firstDayOfWeek() -> Int {
        guard let weekday = component(.weekday) else { return 0 }
        let distanceToStartOfWeek = Date.dayInSeconds * Double(weekday - 1)
        let interval: TimeInterval = self.timeIntervalSinceReferenceDate - distanceToStartOfWeek
        return Date(timeIntervalSinceReferenceDate: interval).component(.day) ?? 0
    }

    /// Last day of week
    ///
    /// - Returns: Int
    func lastDayOfWeek() -> Int {
        guard let weekday = component(.weekday) else { return 0 }
        let distanceToStartOfWeek = Date.dayInSeconds * Double(weekday - 1)
        let distanceToEndOfWeek = Date.dayInSeconds * Double(7)
        let interval: TimeInterval = self.timeIntervalSinceReferenceDate - distanceToStartOfWeek + distanceToEndOfWeek
        return Date(timeIntervalSinceReferenceDate: interval).component(.day) ?? 0
    }

    // MARK: Private Components

    private static func componentFlags() -> Set<Calendar.Component> {
        return [ .year,
                 .month,
                 .day,
                 .weekOfYear,
                 .hour,
                 .minute,
                 .second,
                 .weekday,
                 .weekdayOrdinal,
                 .weekOfYear] }
    private static func components(_ fromDate: Date) -> DateComponents {
        return Calendar.current.dateComponents(Date.componentFlags(), from: fromDate)
    }

    // MARK: Static Cached Formatters

    /// A cached static array of DateFormatters so that thy are only created once.
    private static var cachedDateFormatters = [String: DateFormatter]()
    private static var cachedOrdinalNumberFormatter = NumberFormatter()

    /// Generates a cached formatter based on the specified format, timeZone and locale.
    /// Formatters are cached in a singleton array using hashkeys.
    private static func cachedFormatter(
        format: DateFormat = .standard,
        zone: TimeZoneType = .current,
        locale: Locale = .current
    ) -> DateFormatter {
        let key = "\(format)\(zone)\(locale)"
        guard let cached = Date.cachedDateFormatters[key] else {
            let formatter = DateFormatter {
                $0.dateFormat = format.stringFormat
                $0.timeZone = zone.timeZone
                $0.locale = locale
                $0.isLenient = true
            }
            Date.cachedDateFormatters[key] = formatter
            return formatter
        }
        return cached
    }

    /// Generates a cached formatter based on the provided date style, time style and relative date.
    /// Formatters are cached in a singleton array using hashkeys.
    private static func cachedFormatter(
        _ dateStyle: DateFormatter.Style,
        timeStyle: DateFormatter.Style,
        relative: Bool,
        zone: TimeZoneType = .current,
        locale: Locale = .current
    ) -> DateFormatter {
        let key = "\(dateStyle)\(timeStyle)\(relative)\(zone)\(locale)"
        guard let cached = Date.cachedDateFormatters[key] else {
            let formatter = DateFormatter {
                $0.dateStyle = dateStyle
                $0.timeStyle = timeStyle
                $0.doesRelativeDateFormatting = relative
                $0.timeZone = zone.timeZone
                $0.locale = locale
                $0.isLenient = true
            }
            Date.cachedDateFormatters[key] = formatter
            return formatter
        }
        return cached
    }

    // MARK: Intervals In Seconds

    /// Minute in seconds
    internal static let minuteInSeconds: Double = 60
    /// Hour in seconds
    internal static let hourInSeconds: Double = 3_600
    /// Day in seconds
    internal static let dayInSeconds: Double = 86_400
    /// Week in seconds
    internal static let weekInSeconds: Double = 604_800
    /// Year in seconds
    internal static let yearInSeconds: Double = 31_556_926
}

// MARK: - Enums

/// The string format used for date string conversion
enum DateFormat: Hashable {

    /// The ISO8601 formatted year "yyyy" i.e. 1997
    case isoYear

    /// The ISO8601 formatted year and month "yyyy-MM" i.e. 1997-07
    case isoYearMonth

    /// The ISO8601 formatted date "yyyy-MM-dd" i.e. 1997-07-16
    case isoDate

    /// The ISO8601 formatted date and time "yyyy-MM-dd'T'HH:mmZ" i.e. 1997-07-16T19:20+01:00
    case isoDateTime

    /// The ISO8601 formatted date, time and sec "yyyy-MM-dd'T'HH:mm:ssZ" i.e. 1997-07-16T19:20:30+01:00
    case isoDateTimeSec

    /// The ISO8601 formatted date, time and millisec "yyyy-MM-dd'T'HH:mm:ss.SSSZ" i.e. 1997-07-16T19:20:30.45+01:00
    case isoDateTimeMilliSec

    /// The dotNet formatted date "/Date(%d%d)/" i.e. "/Date(1268123281843)/"
    case dotNet

    /// The RSS formatted date "EEE, d MMM yyyy HH:mm:ss ZZZ" i.e. "Fri, 09 Sep 2011 15:26:08 +0200"
    case rss

    /// The Alternative RSS formatted date "d MMM yyyy HH:mm:ss ZZZ" i.e. "09 Sep 2011 15:26:08 +0200"
    case altRSS

    /// The http header formatted date "EEE, dd MM yyyy HH:mm:ss ZZZ" i.e. "Tue, 15 Nov 1994 12:45:26 GMT"
    case httpHeader

    /// A generic standard format date i.e. "EEE MMM dd HH:mm:ss Z yyyy"
    case standard

    /// A custom date format string
    case custom(String)

    /// Format provider
    var stringFormat: String {
        switch self {
        case .isoYear: return "yyyy"
        case .isoYearMonth: return "yyyy-MM"
        case .isoDate: return "yyyy-MM-dd"
        case .isoDateTime: return "yyyy-MM-dd'T'HH:mmZ"
        case .isoDateTimeSec: return "yyyy-MM-dd'T'HH:mm:ssZ"
        case .isoDateTimeMilliSec: return "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        case .dotNet: return "/Date(%d%f)/"
        case .rss: return "EEE, d MMM yyyy HH:mm:ss ZZZ"
        case .altRSS: return "d MMM yyyy HH:mm:ss ZZZ"
        case .httpHeader: return "EEE, dd MM yyyy HH:mm:ss ZZZ"
        case .standard: return "EEE MMM dd HH:mm:ss Z yyyy"
        case .custom(let customFormat): return customFormat
        }
    }
}

extension DateFormat: Equatable {

    /// Equality operator
    ///
    /// - Parameters:
    ///   - lhs: A thing
    ///   - rhs: Another thing
    /// - Returns: Equality
    static func == (lhs: DateFormat, rhs: DateFormat) -> Bool {
        switch (lhs, rhs) {
        case let (.custom(lhsString), .custom(rhsString)):
            return lhsString == rhsString
        default:
            return lhs == rhs
        }
    }
}

/// The time zone to be used for date conversion
enum TimeZoneType: Hashable {

    /// Current time zone aka local in 11+
    case current
    /// Default time zone
    case `default`
    /// System time zone
    case system
    /// UTC time zone
    case utc
    /// Custom time zone
    case custom(Int)

    /// TimeZone provider
    var timeZone: TimeZone {
        switch self {
        case .current: return .current
        case .default: return TimeZone.ReferenceType.default
        case .system: return TimeZone.ReferenceType.system
        case .utc: return TimeZone(secondsFromGMT: 0) ?? .current
        case let .custom(gmt): return TimeZone(secondsFromGMT: gmt) ?? .current
        }
    }
}

/// The string keys to modify the strings in relative format
enum RelativeTime {

    /// nowPast
    case nowPast
    /// nowFuture
    case nowFuture
    /// secondsPast
    case secondsPast
    /// secondsFuture
    case secondsFuture
    /// oneMinutePast
    case oneMinutePast
    /// oneMinuteFuture
    case oneMinuteFuture
    /// minutesPast
    case minutesPast
    /// minutesFuture
    case minutesFuture
    /// oneHourPast
    case oneHourPast
    /// oneHourFuture
    case oneHourFuture
    /// hoursPast
    case hoursPast
    /// hoursFuture
    case hoursFuture
    /// oneDayPast
    case oneDayPast
    /// oneDayFuture
    case oneDayFuture
    /// daysPast
    case daysPast
    /// daysFuture
    case daysFuture
    /// oneWeekPast
    case oneWeekPast
    /// oneWeekFuture
    case oneWeekFuture
    /// weeksPast
    case weeksPast
    /// weeksFuture
    case weeksFuture
    /// oneMonthPast
    case oneMonthPast
    /// oneMonthFuture
    case oneMonthFuture
    /// monthsPast
    case monthsPast
    /// monthsFuture
    case monthsFuture
    /// oneYearPast
    case oneYearPast
    /// oneYearFuture
    case oneYearFuture
    /// yearsPast
    case yearsPast
    /// yearsFuture
    case yearsFuture
}

/// Relative time styles
enum RelativeTimeStyle {

    /// Regular
    case regular
    /// Short
    case short

    fileprivate typealias Formats = [RelativeTime: StringResource]

    fileprivate var formats: Formats {
        switch self {
        case .regular:
            return RelativeTimeStyle.regularRelativeTimeStrings
        case .short:
            return RelativeTimeStyle.shortRelativeTimeStrings
        }
    }

    private static let regularRelativeTimeStrings: Formats = [
        .nowPast: L.nowPastRegular,
        .nowFuture: L.nowFutureRegular,
        .secondsPast: L.secondsPastRegular,
        .secondsFuture: L.secondsFutureRegular,
        .oneMinutePast: L.oneMinutePastRegular,
        .oneMinuteFuture: L.oneMinuteFutureRegular,
        .minutesPast: L.minutesPastRegular,
        .minutesFuture: L.minutesFutureRegular,
        .oneHourPast: L.oneHourPastRegular,
        .oneHourFuture: L.oneHourFutureRegular,
        .hoursPast: L.hoursPastRegular,
        .hoursFuture: L.hoursFutureRegular,
        .oneDayPast: L.oneDayPastRegular,
        .oneDayFuture: L.oneDayFutureRegular,
        .daysPast: L.daysPastRegular,
        .daysFuture: L.daysFutureRegular,
        .oneWeekPast: L.oneWeekPastRegular,
        .oneWeekFuture: L.oneWeekFutureRegular,
        .weeksPast: L.weeksPastRegular,
        .weeksFuture: L.weeksFutureRegular,
        .oneMonthPast: L.oneMonthPastRegular,
        .oneMonthFuture: L.oneMonthFutureRegular,
        .monthsPast: L.monthsPastRegular,
        .monthsFuture: L.monthsFutureRegular,
        .oneYearPast: L.oneYearPastRegular,
        .oneYearFuture: L.oneYearFutureRegular,
        .yearsPast: L.yearsPastRegular,
        .yearsFuture: L.yearsFutureRegular
    ]

    private static let shortRelativeTimeStrings: Formats = [
        .nowPast: L.nowPastShort,
        .nowFuture: L.nowFutureShort,
        .secondsPast: L.secondsPastShort,
        .secondsFuture: L.secondsFutureShort,
        .oneMinutePast: L.oneMinutePastShort,
        .oneMinuteFuture: L.oneMinuteFutureShort,
        .minutesPast: L.minutesPastShort,
        .minutesFuture: L.minutesFutureShort,
        .oneHourPast: L.oneHourPastShort,
        .oneHourFuture: L.oneHourFutureShort,
        .hoursPast: L.hoursPastShort,
        .hoursFuture: L.hoursFutureShort,
        .oneDayPast: L.oneDayPastShort,
        .oneDayFuture: L.oneDayFutureShort,
        .daysPast: L.daysPastShort,
        .daysFuture: L.daysFutureShort,
        .oneWeekPast: L.oneWeekPastShort,
        .oneWeekFuture: L.oneWeekFutureShort,
        .weeksPast: L.weeksPastShort,
        .weeksFuture: L.weeksFutureShort,
        .oneMonthPast: L.oneMonthPastShort,
        .oneMonthFuture: L.oneMonthFutureShort,
        .monthsPast: L.monthsPastShort,
        .monthsFuture: L.monthsFutureShort,
        .oneYearPast: L.oneYearPastShort,
        .oneYearFuture: L.oneYearFutureShort,
        .yearsPast: L.yearsPastShort,
        .yearsFuture: L.yearsFutureShort
    ]
}

/// The type of comparison to do against today's date or with the suplied date.
enum DateComparison {

    // Days

    /// Checks if date today.
    case isToday
    /// Checks if date is tomorrow.
    case isTomorrow
    /// Checks if date is yesterday.
    case isYesterday
    /// Compares date days
    case isSameDay(as:Date)

    // Weeks

    /// Checks if date is in this week.
    case isThisWeek
    /// Checks if date is in next week.
    case isNextWeek
    /// Checks if date is in last week.
    case isLastWeek
    /// Compares date weeks
    case isSameWeek(as:Date)

    // Months

    /// Checks if date is in this month.
    case isThisMonth
    /// Checks if date is in next month.
    case isNextMonth
    /// Checks if date is in last month.
    case isLastMonth
    /// Compares date months
    case isSameMonth(as:Date)

    // Years

    /// Checks if date is in this year.
    case isThisYear
    /// Checks if date is in next year.
    case isNextYear
    /// Checks if date is in last year.
    case isLastYear
    /// Compare date years
    case isSameYear(as:Date)

    // Relative Time

    /// Checks if it's a future date
    case isInTheFuture
    /// Checks if the date has passed
    case isInThePast
    /// Checks if earlier than date
    case isEarlier(than:Date)
    /// Checks if later than date
    case isLater(than:Date)
    /// Checks if it's a weekday
    case isWeekday
    /// Checks if it's a weekend
    case isWeekend
}

/// The date components available to be retrieved or modifed
enum DateComponent {

    /// second
    case second
    /// minute
    case minute
    /// hour
    case hour
    /// day
    case day
    /// weekday
    case weekday
    /// nthWeekday
    case nthWeekday
    /// week
    case week
    /// month
    case month
    /// year
    case year
}

/// The type of date that can be used for the dateFor function.
enum DateFor {

    /// startOfDay
    case startOfDay
    /// endOfDay
    case endOfDay
    /// startOfWeek
    case startOfWeek
    /// endOfWeek
    case endOfWeek
    /// startOfMonth
    case startOfMonth
    /// endOfMonth
    case endOfMonth
    /// tomorrow
    case tomorrow
    /// yesterday
    case yesterday
    /// nearestMinute
    case nearestMinute(minute:Int)
    /// nearestHour
    case nearestHour(hour:Int)
}

/// Convenience types for date to string conversion
enum DateStyle {

    /// Short style: "2/27/17, 2:22 PM"
    case short
    /// Medium style: "Feb 27, 2017, 2:22:06 PM"
    case medium
    /// Long style: "February 27, 2017 at 2:22:06 PM EST"
    case long
    /// Full style: "Monday, February 27, 2017 at 2:22:06 PM Eastern Standard Time"
    case full
    /// Ordinal day: "27th"
    case ordinalDay
    /// Weekday: "Monday"
    case weekday
    /// Short week day: "Mon"
    case shortWeekday
    /// Very short weekday: "M"
    case veryShortWeekday
    /// Month: "February"
    case month
    /// Short month: "Feb"
    case shortMonth
    /// Very short month: "F"
    case veryShortMonth
}
