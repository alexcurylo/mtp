// @copyright Trollwerks Inc.

/// Queued upload photo operation
final class MTPPhotoRequest: NSObject, OfflineRequest, ServiceProvider {

    private var data: Data?
    private let file: String
    private let caption: String?
    /// Location to reload if any
    let location: Int?

    /// Description for Network Status tab
    var title: String

    /// Information for Network Status tab
    var subtitle: String

    /// Number of times request has failed
    var failures: Int

    /// convenience filter for location photos status
    func isAbout(location id: Int) -> Bool {
        id == location
    }

    /// Memberwise initializer
    /// - Parameters:
    ///   - photo: Photo to publish
    ///   - caption: Caption if any
    ///   - location: Location ID if any
    ///   - title: Title if deserialized
    ///   - subtitle: Subtitle if deserialized
    ///   - failures: Falures if deserialized
    init(photo: Data?,
         file: String?,
         caption: String?,
         location id: Int?,
         title: String? = nil,
         subtitle: String? = nil,
         failures: Int = 0) {
        self.data = photo
        if let file = file {
            self.file = file
            if photo == nil {
                self.data = Data(cache: file)
            }
        } else {
            let name = "MTPPhotoRequest_" + ProcessInfo().globallyUniqueString
            self.file = name
            if let photo = photo {
                photo.save(cache: name)
            }
        }
        self.caption = caption
        self.location = id
        let description = caption?.truncate(length: 15) ?? L.none()
        self.title = L.publishingPhoto(description)
        self.subtitle = subtitle ?? L.queued()
        self.failures = failures
        super.init()
    }

    /// Initialize from dictionary
    /// - Parameter dictionary: Dictionary with keys
    required convenience init?(dictionary: [String: Any]) {
        guard let file = dictionary[Key.photo.key] as? String else {
            return nil
        }

        let caption = dictionary[Key.caption.key] as? String
        let location = dictionary[Key.location.key] as? Int
        let title = dictionary[Key.title.key] as? String
        let subtitle = dictionary[Key.subtitle.key] as? String
        let failures = dictionary[Key.failures.key] as? Int ?? 0
        self.init(photo: nil,
                  file: file,
                  caption: caption,
                  location: location,
                  title: title,
                  subtitle: subtitle,
                  failures: failures)
    }

    /// NSCoding compliant dictionary for writing to disk
    var dictionary: [String: Any] {
        var info: NotificationService.Info = [
            Key.photo.key: file,
            Key.title.key: title,
            Key.subtitle.key: subtitle,
            Key.failures.key: failures,
        ]
        if let caption = caption {
            info[Key.caption.key] = caption
        }
        if let location = location {
            info[Key.location.key] = location
        }
        return info
    }

    /// Perform operation
    /// - Parameter completion: Completion handler
    func perform(completion: @escaping (Error?) -> Void) {
        guard let data = data else {
            // silently fail
            completion(nil)
            return
        }

        net.mtp.upload(photo: data,
                       caption: caption,
                       location: location) { [weak self, file] result in
            switch result {
            case .success:
                data.delete(cache: file)
                completion(nil)
            case .failure(let error):
                switch error {
                case .parameter:
                    // pretend is success
                    data.delete(cache: file)
                    completion(nil)
                default:
                     self?.failed()
                    completion(error)
                }
            }
        }
    }

    /// Show message if first failure
    func failed() {
        if failures == 0 {
            note.message(error: L.networkRetry(L.photoPublish()))
        }
        failures += 1
    }

    /// :nodoc:
    func shouldAttemptResubmission(forError error: Error) -> Bool {
        true
    }
}
