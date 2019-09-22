// @copyright Trollwerks Inc.

import Foundation

/// Queued post state operation
final class MTPPostRequest: NSObject, OfflineRequest, ServiceProvider {

    private let payload: PostPayload

    /// Description for Network Status tab
    var title: String

    /// Information for Network Status tab
    var subtitle: String

    /// Number of times request has failed
    var failures: Int

    /// Memberwise initializer
    ///
    /// - Parameters:
    ///   - payload: Post to publish
    ///   - title: Title if deserialized
    ///   - subtitle: Subtitle if deserialized
    ///   - failures: Falures if deserialized
    init(payload: PostPayload,
         title: String? = nil,
         subtitle: String? = nil,
         failures: Int = 0) {
        self.payload = payload
        self.title = L.publishingPost(payload.location.location_name)
        self.subtitle = subtitle ?? L.queued()
        self.failures = failures
        super.init()
    }

    /// Dictionary methods are required for saving to disk in the case of app termination
    required convenience init?(dictionary: [String: Any]) {
        guard let info = dictionary[Key.post.key] as? PostPayloadInfo else {
            return nil
        }

        let payload = PostPayload(info: info)
        let title = dictionary[Key.title.key] as? String
        let subtitle = dictionary[Key.subtitle.key] as? String
        let failures = dictionary[Key.failures.key] as? Int ?? 0
        self.init(payload: payload,
                  title: title,
                  subtitle: subtitle,
                  failures: failures)
    }

    var dictionary: [String: Any] {
        let info: NotificationService.Info = [
            Key.post.key: PostPayloadInfo(payload: payload),
            Key.title.key: title,
            Key.subtitle.key: subtitle,
            Key.failures.key: failures
        ]
        return info
    }

    func perform(completion: @escaping (Error?) -> Void) {
        net.mtp.postPublish(payload: payload) { [weak self] result in
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
