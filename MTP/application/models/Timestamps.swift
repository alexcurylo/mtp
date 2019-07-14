// @copyright Trollwerks Inc.

import Foundation

typealias Timestamps = [Mappable.Key: Date]

extension Timestamps {

    func stamp(item: Checklist.Item) -> Date? {
        return self[Mappable.key(item: item)]
    }

    func isStamped(item: Checklist.Item) -> Bool {
        return stamp(item: item) != nil
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
}
