// @copyright Trollwerks Inc.

#if USE_ALAMOFIRE
import Alamofire
#else
import Connectivity
#endif
import UIKit

// swiftlint:disable file_length

/// Protocol for objects that can be converted to and from Dictionaries
protocol DictionaryRepresentable {

    /// Optional initializer that is necessary for recovering outstanding requests from disk when restarting the app
    init?(dictionary: [String: Any])

    /// Provides a dictionary to be written to disk;
    /// This dictionary is what will be passed to the initializer above
    ///
    /// - Returns: Dictionary containing information to retry if the app is terminated
    var dictionary: [String: Any] { get }
}

private extension DictionaryRepresentable {

    init?(dictionary: [String: Any]) { return nil }

    var dictionary: [String: Any] { return [:] }
}

/// Protocol for objects enqueued in OfflineRequestManager to perform operations
protocol OfflineRequest: AnyObject, DictionaryRepresentable {

    /// Called whenever the request manager instructs the object to perform its network request
    ///
    /// - Parameter completion: completion fired when done, either with an Error or nothing in the case of success
    func perform(completion: @escaping (Error?) -> Swift.Void)

    /// Allows the OfflineRequest object to recover from an error if desired
    /// Only called if the error is not network related
    ///
    /// - Parameter error: Should be equal to what was passed back in the perform(completion:) call
    /// - Returns: Bool indicating whether perform(completion:) should be called again or the request should be dropped
    func shouldAttemptResubmission(forError error: Error) -> Bool

    /// Description for Network Status tab
    var title: String { get }

    /// Information for Network Status tab
    var subtitle: String { get set }
}

private var requestIdKey: UInt8 = 0
private var requestDelegateKey: UInt8 = 0
private var requestProgressKey: UInt8 = 0

private extension OfflineRequest {

    var id: String {
        get {
            guard let id = objc_getAssociatedObject(self, &requestIdKey) as? String else {
                let id = UUID().uuidString
                self.id = id
                return id
            }
            return id
        }
        set { objc_setAssociatedObject(self, &requestIdKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var delegate: OfflineRequestDelegate? {
        get { return objc_getAssociatedObject(self, &requestDelegateKey) as? OfflineRequestDelegate }
        set { objc_setAssociatedObject(self, &requestDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var progress: Double {
        get { return objc_getAssociatedObject(self, &requestProgressKey) as? Double ?? 0.0 }
        set { objc_setAssociatedObject(self, &requestProgressKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

extension OfflineRequest {

    func shouldAttemptResubmission(forError error: Error) -> Bool {
        return false
    }

    /// Prompts the OfflineRequestManager to save to disk
    /// Used to persist any data changes over the course of a request if needed
    func save() {
        delegate?.requestNeedsSave(self)
    }

    /// Resets the timeout on the request; Useful for long requests that have multiple steps
    func sendHeartbeat() {
        delegate?.requestSentHeartbeat(self)
    }

    /// Provides the current progress (0 to 1) on the ongoing request
    ///
    /// - Parameter progress: current request progress
    func updateProgress(to progress: Double) {
        delegate?.request(self, didUpdateTo: progress)
    }
}

/// Convenience methods for generating and working with dictionaries
private extension OfflineRequest where Self: NSObject {

    /// Generates a dictionary using the values associated with the given key paths
    ///
    /// - Parameter keyPaths: key paths of the properties to include in the dictionary
    /// - Returns: dictionary of the key paths and their associated values
    func dictionary(withKeyPaths keyPaths: [String]) -> [String: Any] {
        var dictionary = [String: Any]()
        keyPaths.forEach { dictionary[$0] = self.value(forKey: $0) }
        return dictionary
    }

    /// Parses through the provided dictionary and sets the appropriate values if they are found
    ///
    /// - Parameters:
    ///   - dictionary: dictionary containing values for the key paths
    ///   - keyPaths: array of key paths
    func sync(withDictionary dictionary: [String: Any], usingKeyPaths keyPaths: [String]) {
        keyPaths.forEach { path in
            guard let value = dictionary[path] else { return }
            self.setValue(value, forKey: path)
        }
    }
}

/// Protocol for receiving callbacaks from OfflineRequestManager
/// and reconfiguring a new OfflineRequestManager
/// from dictionaries saved to disk in the case of
/// previous requests that never completed
protocol OfflineRequestManagerDelegate: AnyObject {

    /// Method that the delegate uses to generate OfflineRequest objects from dictionaries written to disk
    ///
    /// - Parameter dictionary: dictionary saved to disk associated with an unfinished request
    /// - Returns: OfflineRequest object to be queued
    func offlineRequest(withDictionary dictionary: [String: Any]) -> OfflineRequest?

    /// Callback indicating the OfflineRequestManager's current progress
    ///
    /// - Parameters:
    ///   - manager: OfflineRequestManager instance
    ///   - progress: current progress for all ongoing requests (ranges from 0 to 1)
    func offlineRequestManager(_ manager: OfflineRequestManager,
                               didUpdateProgress progress: Double)

    /// Callback indicating the OfflineRequestManager's current connection status
    ///
    /// - Parameters:
    ///   - manager: OfflineRequestManager instance
    ///   - connected: value indicating whether there is currently connectivity
    func offlineRequestManager(_ manager: OfflineRequestManager,
                               didUpdateConnectionStatus connected: Bool)

    /// Callback that can be used to block a request attempt
    ///
    ///   - manager: OfflineRequestManager instance
    ///   - request: OfflineRequest to be performed
    /// - Returns: value indicating whether the OfflineRequestManager should move forward with the request attempt
    func offlineRequestManager(_ manager: OfflineRequestManager,
                               shouldAttemptRequest request: OfflineRequest) -> Bool

    /// Callback to reconfigure and reattempt an OfflineRequest
    /// after a failure not related to connectivity issues
    ///
    /// - Parameters:
    ///   - manager: OfflineRequestManager instance
    ///   - request: OfflineRequest that failed
    ///   - error: NSError associated with the failure
    /// - Returns: value indicating whether the OfflineRequestManager should reattempt the OfflineRequest action
    func offlineRequestManager(_ manager: OfflineRequestManager,
                               shouldReattemptRequest request: OfflineRequest,
                               withError error: Error) -> Bool

    /// Callback indicating that the OfflineRequest action has started
    ///
    /// - Parameters:
    ///   - manager: OfflineRequestManager instance
    ///   - request: OfflineRequest that started its action
    func offlineRequestManager(_ manager: OfflineRequestManager,
                               didStartRequest request: OfflineRequest)

    /// Callback indicating that the OfflineRequest status has changed
    ///
    /// - Parameters:
    ///   - manager: OfflineRequestManager instance
    ///   - request: OfflineRequest that changed its subtitle
    func offlineRequestManager(_ manager: OfflineRequestManager,
                               didUpdateRequest request: OfflineRequest)

    /// Callback indicating that the OfflineRequest action has successfully finished
    ///
    /// - Parameters:
    ///   - manager: OfflineRequestManager instance
    ///   - request: OfflineRequest that finished its action
    func offlineRequestManager(_ manager: OfflineRequestManager,
                               didFinishRequest request: OfflineRequest)

    /// Callback indicating that the OfflineRequest action has failed for reasons unrelated to connectivity
    ///
    /// - Parameters:
    ///   - manager: OfflineRequestManager instance
    ///   - request: OfflineRequest that failed
    ///   - error: NSError associated with the failure
    func offlineRequestManager(_ manager: OfflineRequestManager,
                               requestDidFail request: OfflineRequest,
                               withError error: Error)
}

extension OfflineRequestManagerDelegate {

    func offlineRequest(withDictionary dictionary: [String: Any]) -> OfflineRequest? { return nil }
    func offlineRequestManager(_ manager: OfflineRequestManager,
                               didUpdateProgress progress: Double) { }
    func offlineRequestManager(_ manager: OfflineRequestManager,
                               didUpdateConnectionStatus connected: Bool) { }
    func offlineRequestManager(_ manager: OfflineRequestManager,
                               shouldAttemptRequest request: OfflineRequest) -> Bool { return true }
    func offlineRequestManager(_ manager: OfflineRequestManager,
                               shouldReattemptRequest request: OfflineRequest,
                               withError error: Error) -> Bool { return false }
    func offlineRequestManager(_ manager: OfflineRequestManager,
                               didStartRequest request: OfflineRequest) { }
    func offlineRequestManager(_ manager: OfflineRequestManager,
                               didFinishRequest request: OfflineRequest) { }
    func offlineRequestManager(_ manager: OfflineRequestManager,
                               requestDidFail request: OfflineRequest,
                               withError error: Error) { }
}

/// Listen for callbacks from the currently processing OfflineRequest object
private protocol OfflineRequestDelegate: AnyObject {

    /// Callback indicating the OfflineRequest's current progress
    ///
    /// - Parameters:
    ///   - request: OfflineRequest instance
    ///   - progress: current progress (ranges from 0 to 1)
    func request(_ request: OfflineRequest, didUpdateTo progress: Double)

    /// Callback to save the current state of incomplete requests to disk
    ///
    /// - Parameter request: OfflineRequest that has updated and needs to be rewritten to disk
    func requestNeedsSave(_ request: OfflineRequest)

    /// Callback indicating that the OfflineRequestManager should give the request more time to complete
    ///
    /// - Parameter request: OfflineRequest that is continuing to process and needs more time to complete
    func requestSentHeartbeat(_ request: OfflineRequest)
}

/// Class for handling outstanding network requests; all data is written to disk in the case of app termination
final class OfflineRequestManager: NSObject, NSCoding, ServiceProvider {
    // swiftlint:disable:previous type_body_length

    /// Object listening to all callbacks from the OfflineRequestManager.
    /// Must implement either delegate or requestInstantiationBlock to send archived requests
    /// when recovering from app termination
    var delegate: OfflineRequestManagerDelegate? {
        didSet {
            if let delegate = delegate {
                instantiateInitialRequests { delegate.offlineRequest(withDictionary: $0) }
            }
        }
    }

    /// Alternative means that allows instantiation of
    /// OfflineRequest objects from the dictionaries saved to disk
    /// without requiring a dedicated delegate
    var requestInstantiationBlock: (([String: Any]) -> OfflineRequest?)? {
        didSet {
            if let block = requestInstantiationBlock {
                instantiateInitialRequests(withBlock: block)
            }
        }
    }

    private func instantiateInitialRequests(withBlock block: (([String: Any]) -> OfflineRequest?)) {
        guard incompleteRequests.isEmpty else { return }
        let requests = incompleteRequestDictionaries.compactMap { block($0) }
        if !requests.isEmpty {
            addRequests(requests)
        }
    }

    /// Property indicating whether there is currently an internet connection
    private(set) var connected: Bool = true {
        didSet {
            delegate?.offlineRequestManager(self, didUpdateConnectionStatus: connected)

            if connected {
                attemptSubmission()
            }
        }
    }

    /// Total number of ongoing requests
    private(set) var totalRequestCount = 0
    /// Index of current request within the currently ongoing requests
    private(set) var completedRequestCount = 0

    /// Description for displaying in alert or table
    typealias Task = (title: String, subtitle: String)

    /// Current task list
    var tasks: [Task] {
        return incompleteRequests.map { (title: $0.title, subtitle: $0.subtitle) }
    }

    /// NetworkReachabilityManager used to observe connectivity status.
    /// Can be set to nil to allow requests to be attempted when offline
    #if USE_ALAMOFIRE
    var reachabilityManager = NetworkReachabilityManager()
    #else
    var reachabilityManager: Connectivity?
    #endif

    /// Time limit in seconds before OfflineRequestManager will kill an ongoing OfflineRequest
    var requestTimeLimit: TimeInterval = 120

    /// Maximum number of simultaneous requests allowed
    var simultaneousRequestCap: Int = 10

    /// Time between submission attempts
    var submissionInterval: TimeInterval = 10 {
        didSet {
            setup()
        }
    }

    /// Name of file in Documents directory to which OfflineRequestManager object is archived by default
    static let defaultFileName = "offline_request_manager"

    /// Default singleton OfflineRequestManager
    static var defaultManager: OfflineRequestManager {
        return manager(withFileName: defaultFileName)
    }

    private static var managers = [String: OfflineRequestManager]()

    /// Current progress for all ongoing requests (ranges from 0 to 1)
    private(set) var progress: Double = 1.0 {
        didSet {
            delegate?.offlineRequestManager(self, didUpdateProgress: progress)
        }
    }

    /// Request actions currently being executed
    private(set) var ongoingRequests = [OfflineRequest]()
    private(set) var incompleteRequests = [OfflineRequest]()
    private var incompleteRequestDictionaries = [[String: Any]]()
    private var pendingRequests: [OfflineRequest] {
        return incompleteRequests.filter { request in
            !ongoingRequests.contains { $0.id == request.id }
        }
    }

    private static let codingKey = "pendingRequestDictionaries"

    private var backgroundTask: UIBackgroundTaskIdentifier?
    private var submissionTimer: Timer?

    private var fileName = ""

    override init() {
        super.init()
        setup()
    }

    required convenience init?(coder aDecoder: NSCoder) {
        let decoded = aDecoder.decodeObject(forKey: OfflineRequestManager.codingKey)
        guard let requestDicts = decoded as? [[String: Any]] else {
            print(" error decoding offline request dictionaries")
            return nil
        }

        self.init()
        self.incompleteRequestDictionaries = requestDicts
    }

    deinit {
        submissionTimer?.invalidate()

        #if USE_ALAMOFIRE
        reachabilityManager?.listener = nil
        reachabilityManager?.stopListening()
        #else
        reachabilityManager?.stopNotifier()
        #endif
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(incompleteRequestDictionaries, forKey: OfflineRequestManager.codingKey)
    }

    /// Generates a OfflineRequestManager instance tied to a file name in the Documents directory
    /// Creates a new object or pulls up the object written to disk if possible
    static func manager(withFileName fileName: String) -> OfflineRequestManager {
        guard let manager = managers[fileName] else {
            let manager = archivedManager(fileName: fileName) ?? OfflineRequestManager()
            manager.fileName = fileName
            managers[fileName] = manager
            return manager
        }

        return manager
    }

    /// Instantiates the OfflineRequestManager already written to disk if possible
    static func archivedManager(fileName: String = defaultFileName) -> OfflineRequestManager? {
        do {
            guard let fileURL = fileURL(fileName: fileName),
                  let unarchived = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(Data(contentsOf: fileURL)),
                  let archivedManager = unarchived as? OfflineRequestManager else {
                    return nil
            }

            archivedManager.fileName = fileName
            return archivedManager
        } catch {
            return nil
        }
    }

    private static func fileURL(fileName: String) -> URL? {
        do {
            return try FileManager.default
                                  .url(for: .documentDirectory,
                                       in: .userDomainMask,
                                       appropriateFor: nil,
                                       create: false)
                                  .appendingPathComponent(fileName)
        } catch { return nil }
    }

    private func setup() {
        #if USE_ALAMOFIRE
        reachabilityManager?.listener = { [weak self] status in
            self?.update(connectivity: status)
        }
        reachabilityManager?.startListening()
        #else
        let connectivity = Connectivity(shouldUseHTTPS: true)
        connectivity.framework = .network
        connectivity.checkConnectivity { [weak self] connectivity in
            self?.update(connectivity: connectivity.status)
        }
        let connectivityChanged: (Connectivity) -> Void = { [weak self] connectivity in
            self?.update(connectivity: connectivity.status)
        }
        connectivity.whenConnected = connectivityChanged
        connectivity.whenDisconnected = connectivityChanged
        connectivity.startNotifier()
        reachabilityManager = connectivity
        #endif

        submissionTimer?.invalidate()
        submissionTimer = Timer.scheduledTimer(timeInterval: submissionInterval,
                                               target: self,
                                               selector: #selector(attemptSubmission),
                                               userInfo: nil,
                                               repeats: true)
        submissionTimer?.fire()
    }

    #if USE_ALAMOFIRE
    func update(connectivity status: NetworkReachabilityManager.NetworkReachabilityStatus) {
        connected = status != .notReachable
    }
    #else
    func update(connectivity status: Connectivity.Status) {
        switch status {
        case .connected,
             .connectedViaCellular,
             .connectedViaWiFi:
            connected = true
        case .connectedViaCellularWithoutInternet,
             .connectedViaWiFiWithoutInternet,
             .determining,
             .notConnected:
            connected = false
        }
    }
    #endif

    private func registerBackgroundTask() {
        if backgroundTask == nil {
            backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        }
    }

    private func endBackgroundTask() {
        if let task = backgroundTask {
            UIApplication.shared.endBackgroundTask(task)
            backgroundTask = nil
        }
    }

    /// attempts to perform the next OfflineRequest action in the queue
    @objc func attemptSubmission() {
        // swiftlint:disable:previous function_body_length
        guard let request = incompleteRequests.first(where: { incompleteRequest in
                !ongoingRequests.contains(where: { $0.id == incompleteRequest.id })
              }),
              ongoingRequests.count < simultaneousRequestCap,
              shouldAttemptRequest(request) else {
            return
        }

        registerBackgroundTask()

        ongoingRequests.append(request)
        updateProgress()

        request.subtitle = L.connecting()
        request.delegate = self

        delegate?.offlineRequestManager(self, didStartRequest: request)

        // swiftlint:disable:next closure_body_length
        request.perform { [weak self] error in
            guard let self = self,
                  let request = self.ongoingRequests.first(where: { $0.id == request.id }) else {
                    return // ignore if we have cleared requests
            }

            request.subtitle = L.completed()
            self.removeOngoingRequest(request)
            NSObject.cancelPreviousPerformRequests(withTarget: self,
                                                   selector: #selector(OfflineRequestManager.killRequest(_:)),
                                                   object: request.id)

            if let error = error {
                let nsError = error as NSError
                if nsError.isNetworkError {
                    // keep at front of queue for next attemptSubmission
                    request.subtitle = L.failedNetwork((error as NSError).code)
                    self.saveToDisk()
                    self.delegate?.offlineRequestManager(self, didUpdateRequest: request)
                    return
                } else if case NetworkError.status(500) = error {
                    // ignore Internal Server Error for now - hope it's duplicate setting
                    // as it returns an HTML error page not a JSON result
                    self.completeRequest(request, error: nil)
                    return
                } else if request.shouldAttemptResubmission(forError: error) == true ||
                          self.delegate?.offlineRequestManager(self,
                                                               shouldReattemptRequest: request,
                                                               withError: error) == true {
                    request.subtitle = L.failedError(nsError.code, nsError.localizedDescription)
                    self.saveToDisk()
                    self.delegate?.offlineRequestManager(self, didUpdateRequest: request)
                    return
                }
            }

            self.completeRequest(request, error: error)
        }

        perform(#selector(killRequest(_:)), with: request.id, afterDelay: requestTimeLimit)
        attemptSubmission()
    }

    @objc func killRequest(_ requestID: String?) {
        guard let request = ongoingRequests.first(where: { $0.id == requestID }) else { return }
        self.removeOngoingRequest(request)
        request.subtitle = L.failedTimeout()
        completeRequest(request, error: NSError.timeOutError)
    }

    private func removeOngoingRequest(_ request: OfflineRequest) {
        guard let index = ongoingRequests.firstIndex(where: { $0.id == request.id }) else { return }
        ongoingRequests.remove(at: index)
    }

    private func completeRequest(_ request: OfflineRequest, error: Error?) {
        self.popRequest(request)

        if let error = error {
            delegate?.offlineRequestManager(self, requestDidFail: request, withError: error)
        } else {
            delegate?.offlineRequestManager(self, didFinishRequest: request)
        }
    }

    private func shouldAttemptRequest(_ request: OfflineRequest) -> Bool {
        let reachable: Bool
        if let manager = reachabilityManager {
            #if USE_ALAMOFIRE
            reachable = manager.networkReachabilityStatus != .notReachable
            #else
            switch manager.status {
            case .connected,
                 .connectedViaCellular,
                 .connectedViaWiFi:
                reachable = true
            case .connectedViaCellularWithoutInternet,
                 .connectedViaWiFiWithoutInternet,
                 .determining,
                 .notConnected:
                reachable = false
            }
            #endif
        } else {
            reachable = connected
        }

        let delegateAllowed = (delegate?.offlineRequestManager(self, shouldAttemptRequest: request) ?? true)

        return reachable && delegateAllowed
    }

    private func popRequest(_ request: OfflineRequest) {
        guard let index = incompleteRequests.firstIndex(where: { $0.id == request.id }) else { return }
        incompleteRequests.remove(at: index)

        if incompleteRequests.isEmpty {
            endBackgroundTask()
            clearAllRequests()
        } else {
            completedRequestCount += 1
            updateProgress()
            attemptSubmission()
        }

        saveToDisk()
    }

    /// Clears out the current OfflineRequest queue and returns to a neutral state
    func clearAllRequests() {
        ongoingRequests.forEach { $0.delegate = nil }
        incompleteRequests.removeAll()
        ongoingRequests.removeAll()
        completedRequestCount = 0
        totalRequestCount = 0
        progress = 1
        saveToDisk()
    }

    /// Enqueues a single OfflineRequest
    ///
    /// - Parameters:
    ///   - request: OfflineRequest to be queued
    ///   - startImmediately: indicates whether an attempt should be made immediately or deferred until the next timer
    func queueRequest(_ request: OfflineRequest,
                      startImmediately: Bool = true) {
        queueRequests([request], startImmediately: startImmediately)
    }

    /// Enqueues an array of OfflineRequest objects
    ///
    /// - Parameters:
    ///   - request: Array of OfflineRequest objects to be queued
    ///   - startImmediately: indicates whether an attempt should be made immediately or deferred until the next timer
    func queueRequests(_ requests: [OfflineRequest],
                       startImmediately: Bool = true) {
        addRequests(requests)

        if requests.contains(where: { !$0.dictionary.isEmpty }) {
            saveToDisk()
        }

        if startImmediately {
            attemptSubmission()
        }
    }

    /// Allows for adjustment to pending requests before they are executed
    ///
    /// - Parameter modifyBlock: block making any necessary adjustments to the array of pending requests
    func modifyPendingRequests(_ modifyBlock: (([OfflineRequest]) -> [OfflineRequest])) {
        incompleteRequests = ongoingRequests + modifyBlock(pendingRequests)
        saveToDisk()
    }

    private func addRequests(_ requests: [OfflineRequest]) {
        incompleteRequests.append(contentsOf: requests)
        totalRequestCount = incompleteRequests.count + completedRequestCount
    }

    /// Writes the OfflineRequestManager instances to the Documents directory
    func saveToDisk() {
        guard let path = OfflineRequestManager.fileURL(fileName: fileName)?.path else { return }

        incompleteRequestDictionaries = incompleteRequests.compactMap {
            let dictionary = $0.dictionary
            return dictionary.isEmpty ? nil : dictionary
        }
        NSKeyedArchiver.archiveRootObject(self, toFile: path)
    }

    fileprivate func updateProgress() {
        let uploadUnit = 1 / max(1.0, Double(totalRequestCount))

        let ongoingProgress = ongoingRequests.reduce(0.0) { $0 + $1.progress }
        let newProgressValue = (Double(self.completedRequestCount) + ongoingProgress) * uploadUnit

        let totalProgress = min(1, max(0, newProgressValue))
        progress = totalProgress
    }
}

extension OfflineRequestManager: OfflineRequestDelegate {

    func request(_ request: OfflineRequest, didUpdateTo progress: Double) {
        guard let request = ongoingRequests.first(where: { $0.id == request.id }) else { return }
        request.progress = progress
        updateProgress()
    }

    func requestNeedsSave(_ request: OfflineRequest) {
        saveToDisk()
    }

    func requestSentHeartbeat(_ request: OfflineRequest) {
        NSObject.cancelPreviousPerformRequests(withTarget: self,
                                               selector: #selector(killRequest(_:)),
                                               object: request.id)
        perform(#selector(killRequest(_:)), with: request.id, afterDelay: requestTimeLimit)
    }
}

private extension NSError {

    var isNetworkError: Bool {
        switch code {
        case NSURLErrorTimedOut,
             NSURLErrorNotConnectedToInternet,
             NSURLErrorNetworkConnectionLost:
            return true
        default:
            return false
        }
    }

    static var timeOutError: NSError {
        return NSError(domain: "offlineRequestManager",
                       code: -1,
                       userInfo: [NSLocalizedDescriptionKey: "Offline Request Timed Out"])
    }
}
