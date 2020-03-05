// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class DateTests: TestCase {

    func testTimeConversion() {
        // given
        let sut = Date()
        let when = sut.timeIntervalSinceReferenceDate
        let diff = TimeInterval(TimeZone.current.secondsFromGMT(for: sut))

        // when
        let local = sut.toLocalTime.timeIntervalSinceReferenceDate
        let utc = sut.toUTC.timeIntervalSinceReferenceDate

        // then
        XCTAssertEqual(when - utc, diff)
        XCTAssertEqual(when - local, -diff)
    }

    func testStampTime() throws {
        // given
        let sut = DateFormatter.stampTime
        let date = Date(timeIntervalSinceReferenceDate: 0).toUTC

        // when
        let actual = sut.string(from: date)

        // then
        XCTAssertEqual(actual, "01.01.01 00:00:00.000")
    }

    func testRelativeStrings() {
        // given
        let minute: Double = 60
        let hour: Double = 3600
        let day: Double = 86_400
        let week: Double = 604_800
        let year: Double = 31_556_926

        // then
        [
            (-1, "just now"), // .nowPast
            (1, "in a few seconds"), // .nowFuture
            (-10, "10 seconds ago"), // .secondsPast
            (11, "in 11 seconds"), // .secondsFuture
            (-minute - 1, "1 minute ago"), // .oneMinutePast
            (minute + 1, "in 1 minute"), // .oneMinuteFuture
            (-minute * 10, "10 minutes ago"), // .minutesPast
            (minute * 11, "in 11 minutes"), // .minutesFuture
            (-hour, "last hour"), // .oneHourPast
            (hour, "next hour"), // .oneHourFuture
            (-hour * 10, "10 hours ago"), // .hoursPast
            (hour * 10, "in 10 hours"), // .hoursFuture
            (-day, "yesterday"), // .oneDayPast
            (day, "tomorrow"), // .oneDayFuture
            (-day * 5, "5 days ago"), // .daysPast
            (day * 5, "in 5 days"), // .daysFuture
            (-week, "last week"), // .oneWeekPast
            (week, "next week"), // .oneWeekFuture
            (-week * 2, "2 weeks ago"), // .weeksPast
            (week * 2, "in 2 weeks"), // .weeksFuture
            // in January returns "last year"
            //(-week * 4, "last month"), // .oneMonthPast
            // in December returns "next year"
            (week * 4, "next month"), // .oneMonthFuture
            // in January returns "last year"
            //(-day * 55, "2 months ago"), // .monthsPast
            // in November returns "next year"
            (day * 60, "in 2 months"), // .monthsFuture
            (-year * 1, "last year"), // .oneYearPast
            (year * 1, "next year"), // .oneYearFuture
            (-year * 10, "10 years ago"), // .yearsPast
            (year * 10, "in 10 years"), // .yearsFuture
        ].forEach {
            verify(time: $0.0, expected: $0.1)
        }
    }

    private func verify(time: TimeInterval,
                        expected: String) {
        // given
        let date = Date().addingTimeInterval(time)

        // when
        let result = date.relative

        // then
        result.assert(equal: expected)
    }
}
