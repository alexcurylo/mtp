// @copyright Trollwerks Inc.

import Foundation

/// Track last time data was changed
typealias Timestamps = [Mappable.Key: Date]

extension Timestamps {

    /// Checklist.Item IDs for non-places
    enum Info: Int {

        /// rankings
        case rankings = -1
        /// scorecard
        case scorecard = -2
    }

    /// Status of a timestamp
    struct UpdateStatus {

        /// Is it currently valid?
        let isCurrent: Bool

        /// Wait until it should be valid
        let wait: Int

        /// Default constructor
        init() {
            isCurrent = true
            wait = 0
        }

        /// Constructor with wait
        init(wait: Int) {
            isCurrent = false
            self.wait = wait
        }

        /// Has wait expired?
        var isPending: Bool {
            return !isCurrent && wait < 1
        }
        /// Has wait not expired?
        var isWaiting: Bool {
            return !isCurrent && wait > 0
        }
    }

    /// Expected maximum wait time for rank update
    static var rankUpdateMinutes = 60

    /// Get item's timestamp
    ///
    /// - Parameter item: Item
    /// - Returns: Timestamp if found
    func stamp(item: Checklist.Item) -> Date? {
        return self[Mappable.key(item: item)]
    }

    /// Convenience timestamp check
    ///
    /// - Parameter item: Item
    /// - Returns: Whether timestamped
    func isStamped(item: Checklist.Item) -> Bool {
        return stamp(item: item) != nil
    }

    /// Set timestamps for checklist
    ///
    /// - Parameters:
    ///   - list: Checklist
    ///   - stamped: Whether timestampled
    mutating func set(list: Checklist,
                      stamped: Bool) {
        set(item: list.rankingsItem, stamped: stamped)
        set(item: list.scorecardItem, stamped: stamped)
    }

    /// Set timestamps for item
    ///
    /// - Parameters:
    ///   - item: Item
    ///   - stamped: Whether stamped
    ///   - update: Whether to update stamp
    mutating func set(item: Checklist.Item,
                      stamped: Bool,
                      update: Bool = true) {
        let key = Mappable.key(item: item)
        set(key: key, stamped: stamped, update: update)
    }

    /// Set specific key stamp
    ///
    /// - Parameters:
    ///   - key: Item key
    ///   - stamped: Whether stamped
    ///   - update: Whether to update stamp
    mutating func set(key: Mappable.Key,
                      stamped: Bool,
                      update: Bool = true) {
        if !stamped {
            self[key] = nil
        } else if update || self[key] == nil {
            self[key] = Date()
        }
    }

    /// Are rankings waiting for an update?
    ///
    /// - Parameter rankings: Checklist
    /// - Returns: Whether waiting
    func waiting(rankings: Checklist) -> Bool {
        return stamp(item: rankings.rankingsItem) != nil
    }

    /// How many minutes to wait
    ///
    /// - Parameter rankings: Checklist
    /// - Returns: Minutes to wait
    func wait(rankings: Checklist) -> Int {
        guard let stamp = stamp(item: rankings.rankingsItem) else { return 0 }

        let countdown = Timestamps.rankUpdateMinutes
        let remaining = Int(-stamp.timeIntervalSinceNow / 60)
        let minutes = Swift.max(0, countdown - remaining)
        return minutes
    }

    /// Fetch current status
    ///
    /// - Parameter rankings: Checklist
    /// - Returns: UpdateStatus
    func updateStatus(rankings: Checklist) -> UpdateStatus {
        guard waiting(rankings: rankings) else { return UpdateStatus() }
        return UpdateStatus(wait: wait(rankings: rankings))
    }

    /// Clear waiting state if expired
    ///
    /// - Parameter rankings: Checklist
    /// - Returns: Whether cleared
    mutating func clear(rankings: Checklist) -> Bool {
        guard updateStatus(rankings: rankings).isPending else { return false }

        set(item: rankings.rankingsItem, stamped: false)
        return true
    }

    /// Are scorecards waiting for an update?
    ///
    /// - Parameter scorecard: Checklist
    /// - Returns: Whether waiting
    func waiting(scorecard: Checklist) -> Bool {
        return stamp(item: scorecard.scorecardItem) != nil
    }

    /// How many minutes to wait
    ///
    /// - Parameter scorecard: Checklist
    /// - Returns: Minutes to wait
    func wait(scorecard: Checklist) -> Int {
        guard let stamp = stamp(item: scorecard.scorecardItem) else { return 0 }

        let countdown = Timestamps.rankUpdateMinutes
        let remaining = Int(-stamp.timeIntervalSinceNow / 60)
        let minutes = Swift.max(0, countdown - remaining)
        return minutes
    }

    /// Fetch current status
    ///
    /// - Parameter scorecard: Checklist
    /// - Returns: UpdateStatus
    func updateStatus(scorecard: Checklist) -> UpdateStatus {
        guard waiting(scorecard: scorecard) else { return UpdateStatus() }
        return UpdateStatus(wait: wait(scorecard: scorecard))
    }

    /// Clear waiting state if expired
    ///
    /// - Parameter scorecard: Checklist
    /// - Returns: Whether cleared
    mutating func clear(scorecard: Checklist) -> Bool {
        guard updateStatus(scorecard: scorecard).isPending else { return false }

        set(item: scorecard.scorecardItem, stamped: false)
        return true
    }
}
