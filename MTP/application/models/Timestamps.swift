// @copyright Trollwerks Inc.

import Foundation

/// Track last time data was changed
typealias Timestamps = [Mappable.Key: Date]

extension Timestamps {

    enum Info: Int {
        case rankings = -1
        case scorecard = -2
    }

    struct UpdateStatus {

        let isCurrent: Bool
        let wait: Int

        init() {
            isCurrent = true
            wait = 0
        }

        init(wait: Int) {
            isCurrent = false
            self.wait = wait
        }

        var isPending: Bool {
            return !isCurrent && wait < 1
        }
        var isWaiting: Bool {
            return !isCurrent && wait > 0
        }
    }

    static var rankUpdateMinutes = 60

    func stamp(item: Checklist.Item) -> Date? {
        return self[Mappable.key(item: item)]
    }

    func isStamped(item: Checklist.Item) -> Bool {
        return stamp(item: item) != nil
    }

    mutating func set(list: Checklist,
                      stamped: Bool) {
        set(item: list.rankingsItem, stamped: stamped)
        set(item: list.scorecardItem, stamped: stamped)
    }

    mutating func set(item: Checklist.Item,
                      stamped: Bool,
                      update: Bool = true) {
        let key = Mappable.key(item: item)
        set(key: key, stamped: stamped, update: update)
    }

    mutating func set(key: Mappable.Key,
                      stamped: Bool,
                      update: Bool = true) {
        if !stamped {
            self[key] = nil
        } else if update || self[key] == nil {
            self[key] = Date()
        }
    }

    func waiting(rankings: Checklist) -> Bool {
        return stamp(item: rankings.rankingsItem) != nil
    }

    func wait(rankings: Checklist) -> Int {
        guard let stamp = stamp(item: rankings.rankingsItem) else { return 0 }

        let countdown = Timestamps.rankUpdateMinutes
        let remaining = Int(-stamp.timeIntervalSinceNow / 60)
        let minutes = Swift.max(0, countdown - remaining)
        return minutes
    }

    func updateStatus(rankings: Checklist) -> UpdateStatus {
        guard waiting(rankings: rankings) else { return UpdateStatus() }
        return UpdateStatus(wait: wait(rankings: rankings))
    }

    mutating func clear(rankings: Checklist) -> Bool {
        guard updateStatus(rankings: rankings).isPending else { return false }

        set(item: rankings.rankingsItem, stamped: false)
        return true
    }

    func waiting(scorecard: Checklist) -> Bool {
        return stamp(item: scorecard.scorecardItem) != nil
    }

    func wait(scorecard: Checklist) -> Int {
        guard let stamp = stamp(item: scorecard.scorecardItem) else { return 0 }

        let countdown = Timestamps.rankUpdateMinutes
        let remaining = Int(-stamp.timeIntervalSinceNow / 60)
        let minutes = Swift.max(0, countdown - remaining)
        return minutes
    }

    func updateStatus(scorecard: Checklist) -> UpdateStatus {
        guard waiting(scorecard: scorecard) else { return UpdateStatus() }
        return UpdateStatus(wait: wait(scorecard: scorecard))
    }

    mutating func clear(scorecard: Checklist) -> Bool {
        guard updateStatus(scorecard: scorecard).isPending else { return false }

        set(item: scorecard.scorecardItem, stamped: false)
        return true
    }
}
