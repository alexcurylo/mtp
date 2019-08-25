// @copyright Trollwerks Inc.

import Rswift

extension Date {

    /// Descriptrion of time relative to now
    var relative: String {
        let now = Date().timeIntervalSince1970
        let then = timeIntervalSince1970
        let isPast = now - then > 0

        let seconds: Double = abs(now - then)
        let minutes: Double = round(seconds / 60)
        let hours: Double = round(minutes / 60)
        let days: Double = round(hours / 24)

        let time: RelativeTime
        let amount: Double
        if seconds < 60 {
            amount = seconds
            if seconds < 10 {
                time = isPast ? .nowPast : .nowFuture
            } else {
                time = isPast ? .secondsPast : .secondsFuture
            }
        } else if minutes < 60 {
            amount = minutes
            if minutes == 1 {
                time = isPast ? .oneMinutePast : .oneMinuteFuture
            } else {
                time = isPast ? .minutesPast : .minutesFuture
            }
        } else if hours < 24 {
            amount = hours
            if hours == 1 {
                time = isPast ? .oneHourPast : .oneHourFuture
            } else {
                time = isPast ? .hoursPast : .hoursFuture
            }
        } else if days < 7 {
            amount = days
            if days == 1 {
                time = isPast ? .oneDayPast : .oneDayFuture
            } else {
                time = isPast ? .daysPast : .daysFuture
            }
        } else if days < 28 {
            amount = Double(abs(since(Date(), in: .week)))
            if isPast {
                time = compare(.isLastWeek) ? .oneWeekPast : .weeksPast
            } else {
                time = compare(.isNextWeek) ? .oneWeekFuture : .weeksFuture
            }
        } else if compare(.isThisYear) {
            amount = Double(abs(since(Date(), in: .month)))
            if isPast {
                time = compare(.isLastMonth) ? .oneMonthPast : .monthsPast
            } else {
                time = compare(.isNextMonth) ? .oneMonthFuture : .monthsFuture
            }
        } else if isPast {
            amount = Double(abs(since(Date(), in: .year)))
            time = compare(.isLastYear) ? .oneYearPast : .yearsPast
        } else {
            amount = Double(abs(since(Date(), in: .year)))
            time = compare(.isNextYear) ? .oneYearFuture : .yearsFuture
        }
        return String(format: time.format, amount)
    }
}

private extension Date {

    func compare(_ comparison: DateComparison) -> Bool {
        switch comparison {
//        case .isToday:
//            return compare(.isSameDay(as: Date()))
//        case .isTomorrow:
//            let comparison = Date().adjust(.day, offset: 1)
//            return compare(.isSameDay(as: comparison))
//        case .isYesterday:
//            let comparison = Date().adjust(.day, offset: -1)
//            return compare(.isSameDay(as: comparison))
//        case .isSameDay(let date):
//            return component(.year) == date.component(.year)
//                && component(.month) == date.component(.month)
//                && component(.day) == date.component(.day)
//        case .isThisWeek:
//            return self.compare(.isSameWeek(as: Date()))
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
            return abs(self.timeIntervalSince(date)) < 604_800
//        case .isThisMonth:
//            return self.compare(.isSameMonth(as: Date()))
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
//        case .isInTheFuture:
//            return self.compare(.isLater(than: Date()))
//        case .isInThePast:
//            return self.compare(.isEarlier(than: Date()))
//        case .isEarlier(let date):
//            return (self as NSDate).earlierDate(date) == self
//        case .isLater(let date):
//            return (self as NSDate).laterDate(date) == self
//        case .isWeekday:
//            return !compare(.isWeekend)
//        case .isWeekend:
//            guard let range = Calendar.current.maximumRange(of: .weekday) else { return false }
//            return (component(.weekday) == range.lowerBound ||
//                   component(.weekday) == range.upperBound - range.lowerBound)
        }
    }

    func adjust(_ component: DateComponent,
                offset: Int) -> Date {
        var dateComp = DateComponents()
        switch component {
//        case .second:
//            dateComp.second = offset
//        case .minute:
//            dateComp.minute = offset
//        case .hour:
//            dateComp.hour = offset
//        case .day:
//            dateComp.day = offset
//        case .weekday:
//            dateComp.weekday = offset
//        case .nthWeekday:
//            dateComp.weekdayOrdinal = offset
        case .week:
            dateComp.weekOfYear = offset
        case .month:
            dateComp.month = offset
        case .year:
            dateComp.year = offset
        }
        //swiftlint:disable:next force_unwrapping
        return Calendar.current.date(byAdding: dateComp, to: self)!
    }

    func since(_ date: Date,
               in component: DateComponent) -> Int64 {
        let calendar = Calendar.current
        var end = 0
        var start = 0
        switch component {
//        case .second:
//            return Int64(timeIntervalSince(date))
//        case .minute:
//            let interval = timeIntervalSince(date)
//            return Int64(interval / 60)
//        case .hour:
//            let interval = timeIntervalSince(date)
//            return Int64(interval / 3_600)
//        case .day:
//            end = calendar.ordinality(of: .day, in: .era, for: self) ?? 0
//            start = calendar.ordinality(of: .day, in: .era, for: date) ?? 0
//        case .weekday:
//            end = calendar.ordinality(of: .weekday, in: .era, for: self) ?? 0
//            start = calendar.ordinality(of: .weekday, in: .era, for: date) ?? 0
//        case .nthWeekday:
//            end = calendar.ordinality(of: .weekdayOrdinal, in: .era, for: self) ?? 0
//            start = calendar.ordinality(of: .weekdayOrdinal, in: .era, for: date) ?? 0
        case .week:
            if let last = calendar.ordinality(of: .weekOfYear, in: .era, for: self) {
               end = last
            }
            if let first = calendar.ordinality(of: .weekOfYear, in: .era, for: date) {
                start = first
            }
        case .month:
            if let last = calendar.ordinality(of: .month, in: .era, for: self) {
                end = last
            }
            if let first = calendar.ordinality(of: .month, in: .era, for: date) {
                start = first
            }
        case .year:
            if let last = calendar.ordinality(of: .year, in: .era, for: self) {
                end = last
            }
            if let first = calendar.ordinality(of: .year, in: .era, for: date) {
                start = first
            }
        }
        return Int64(end - start)
    }

    func component(_ component: DateComponent) -> Int? {
        let components = Date.components(self)
        switch component {
//        case .second:
//            return components.second
//        case .minute:
//            return components.minute
//        case .hour:
//            return components.hour
//        case .day:
//            return components.day
//        case .weekday:
//            return components.weekday
//        case .nthWeekday:
//            return components.weekdayOrdinal
        case .week:
            return components.weekOfYear
        case .month:
            return components.month
        case .year:
            return components.year
        }
    }

    static func componentFlags() -> Set<Calendar.Component> {
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

    static func components(_ fromDate: Date) -> DateComponents {
        return Calendar.current.dateComponents(Date.componentFlags(), from: fromDate)
    }
}

private enum RelativeTime {

    case nowPast
    case nowFuture
    case secondsPast
    case secondsFuture
    case oneMinutePast
    case oneMinuteFuture
    case minutesPast
    case minutesFuture
    case oneHourPast
    case oneHourFuture
    case hoursPast
    case hoursFuture
    case oneDayPast
    case oneDayFuture
    case daysPast
    case daysFuture
    case oneWeekPast
    case oneWeekFuture
    case weeksPast
    case weeksFuture
    case oneMonthPast
    case oneMonthFuture
    case monthsPast
    case monthsFuture
    case oneYearPast
    case oneYearFuture
    case yearsPast
    case yearsFuture

    var format: String {
        let resource: StringResource
        switch self {
        case .nowPast: resource = L.nowPast
        case .nowFuture: resource = L.nowFuture
        case .secondsPast: resource = L.secondsPast
        case .secondsFuture: resource = L.secondsFuture
        case .oneMinutePast: resource = L.oneMinutePast
        case .oneMinuteFuture: resource = L.oneMinuteFuture
        case .minutesPast: resource = L.minutesPast
        case .minutesFuture: resource = L.minutesFuture
        case .oneHourPast: resource = L.oneHourPast
        case .oneHourFuture: resource = L.oneHourFuture
        case .hoursPast: resource = L.hoursPast
        case .hoursFuture: resource = L.hoursFuture
        case .oneDayPast: resource = L.oneDayPast
        case .oneDayFuture: resource = L.oneDayFuture
        case .daysPast: resource = L.daysPast
        case .daysFuture: resource = L.daysFuture
        case .oneWeekPast: resource = L.oneWeekPast
        case .oneWeekFuture: resource = L.oneWeekFuture
        case .weeksPast: resource = L.weeksPast
        case .weeksFuture: resource = L.weeksFuture
        case .oneMonthPast: resource = L.oneMonthPast
        case .oneMonthFuture: resource = L.oneMonthFuture
        case .monthsPast: resource = L.monthsPast
        case .monthsFuture: resource = L.monthsFuture
        case .oneYearPast: resource = L.oneYearPast
        case .oneYearFuture: resource = L.oneYearFuture
        case .yearsPast: resource = L.yearsPast
        case .yearsFuture: resource = L.yearsFuture
        }

        //swiftlint:disable:next nslocalizedstring_key
        return NSLocalizedString(resource.key,
                                 bundle: resource.bundle,
                                 comment: "")
    }
}

private enum DateComparison {

    //case isToday
    //case isTomorrow
    //case isYesterday
    //case isSameDay(as:Date)

    //case isThisWeek
    case isNextWeek
    case isLastWeek
    case isSameWeek(as:Date)

    //case isThisMonth
    case isNextMonth
    case isLastMonth
    case isSameMonth(as:Date)

    case isThisYear
    case isNextYear
    case isLastYear
    case isSameYear(as:Date)

    //case isInTheFuture
    //case isInThePast
    //case isEarlier(than:Date)
    //case isLater(than:Date)
    //case isWeekday
    //case isWeekend
}

private enum DateComponent {

    //case second
    //case minute
    //case hour
    //case day
    //case weekday
    //case nthWeekday
    case week
    case month
    case year
}
