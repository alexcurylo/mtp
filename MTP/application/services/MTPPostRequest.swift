// @copyright Trollwerks Inc.

import Foundation

/// Queued visit state operation
final class MTPPostRequest: NSObject, OfflineRequest, ServiceProvider {

    private let post: PostPayload

    /// Description for Network Status tab
    var title: String

    /// Information for Network Status tab
    var subtitle: String

    /// Number of times request has failed
    var failures: Int

    /// Memberwise initializer
    ///
    /// - Parameters:
    ///   - post: Post to publish
    ///   - title: Title if deserialized
    ///   - subtitle: Subtitle if deserialized
    ///   - failures: Falures if deserialized
    init(post: PostPayload,
         title: String? = nil,
         subtitle: String? = nil,
         failures: Int = 0) {
        self.post = post
        self.title = L.publishingPost()
        self.subtitle = subtitle ?? L.queued()
        self.failures = failures
        super.init()
    }

    /// Dictionary methods are required for saving to disk in the case of app termination
    required convenience init?(dictionary: [String: Any]) {
        guard let post = dictionary[Note.ChecklistItemInfo.post.key] as? PostPayload else {
            return nil
        }

        let title = dictionary[Note.ChecklistItemInfo.title.key] as? String
        let subtitle = dictionary[Note.ChecklistItemInfo.subtitle.key] as? String
        let failures = dictionary[Note.ChecklistItemInfo.failures.key] as? Int ?? 0
        self.init(post: post,
                  title: title,
                  subtitle: subtitle,
                  failures: failures)
    }

    var dictionary: [String: Any] {
        let info: NotificationService.Info = [
            Note.ChecklistItemInfo.post.key: post,
            Note.ChecklistItemInfo.title.key: title,
            Note.ChecklistItemInfo.subtitle.key: subtitle,
            Note.ChecklistItemInfo.failures.key: failures
        ]
        return info
    }

    func perform(completion: @escaping (Error?) -> Void) {
        net.mtp.postPublish(payload: post) { [weak self] result in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                switch error {
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
            note.message(error: L.serverRetryError(L.publishPost()))
        }
        failures += 1
    }

    func shouldAttemptResubmission(forError error: Error) -> Bool {
        return true
    }
}
