// @copyright Trollwerks Inc.

import Foundation

/// Queued visit state operation
final class MTPVisitedRequest: NSObject, OfflineRequest, ServiceProvider {

    private let item: Checklist.Item
    private let visited: Bool

    /// Description for Network Status tab
    var title: String

    /// Information for Network Status tab
    var subtitle: String

    /// Information for clearing rankings
    var checklist: Checklist { return item.list }

    /// Test for rank changes pending
    func changes(list: Checklist) -> Bool {
        return item.list == list
    }

    /// Number of times request has failed
    var failures: Int

    /// Memberwise initializer
    ///
    /// - Parameters:
    ///   - item: Place changing status
    ///   - visited: Visited or not
    ///   - title: Title if deserialized
    ///   - subtitle: Subtitle if deserialized
    ///   - failures: Falures if deserialized
    init(item: Checklist.Item,
         visited: Bool,
         title: String? = nil,
         subtitle: String? = nil,
         failures: Int = 0) {
        self.item = item
        self.visited = visited
        self.title = L.unknown()
        self.subtitle = subtitle ?? L.queued()
        self.failures = failures
        super.init()

        self.title = title ?? {
            let operation = visited ? L.visited() : L.notVisited()
            let name: String
            if let mappable = data.get(mappable: item) {
                name = mappable.title
            } else {
                name = L.unknown()
            }
            return L.visitedRequest(operation, name)
        }()
    }

    /// Dictionary methods are required for saving to disk in the case of app termination
    required convenience init?(dictionary: [String: Any]) {
        guard let listValue = dictionary[Key.list.key] as? Int,
              let list = Checklist(rawValue: listValue),
              let id = dictionary[Key.id.key] as? Int,
              let visited = dictionary[Key.visited.key] as? Bool else {
            return nil
        }

        let title = dictionary[Key.title.key] as? String
        let subtitle = dictionary[Key.subtitle.key] as? String
        let failures = dictionary[Key.failures.key] as? Int ?? 0
        self.init(item: (list, id),
                  visited: visited,
                  title: title,
                  subtitle: subtitle,
                  failures: failures)
    }

    var dictionary: [String: Any] {
        let info: NotificationService.Info = [
            Key.list.key: item.list.rawValue,
            Key.id.key: item.id,
            Key.visited.key: visited,
            Key.title.key: title,
            Key.subtitle.key: subtitle,
            Key.failures.key: failures
        ]
        return info
    }

    func perform(completion: @escaping (Error?) -> Void) {
        net.mtp.set(items: [item], visited: visited) { [weak self] result in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                switch error {
                case NetworkError.status(500):
                    // ignore - expect it's duplicate setting
                    // as it returns an HTML error page not a JSON result
                    completion(nil)
                case .parameter:
                    // pretend is success
                    completion(nil)
                default:
                     self?.failed()
                    completion(error)
                }
            }
        }
    }

    func failed() {
        if failures == 0 {
            note.message(error: L.serverRetryError(L.updateVisit()))
        }
        failures += 1
    }

    func shouldAttemptResubmission(forError error: Error) -> Bool {
        return true
    }
}
