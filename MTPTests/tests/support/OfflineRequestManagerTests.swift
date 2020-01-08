// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

// swiftlint:disable file_length

// swiftlint:disable type_body_length
final class OfflineRequestManagerTests: TestCase {

    private let testFileName = "test_manager"
    private var sut: OfflineRequestManager?
    private var listener: OfflineRequestManagerListener?

    override func setUp() {
        super.setUp()

        let manager = OfflineRequestManager.manager(withFileName: testFileName)
        sut = manager
        manager.clearAllRequests()
        manager.simultaneousRequestCap = 1
        manager.submissionInterval = 0.2
        manager.connectivity?.stopNotifier()
        manager.connectivity = nil
        manager.saveToDisk()
        let delegate = OfflineRequestManagerListener()
        manager.delegate = delegate
        listener = delegate
    }

    override func tearDown() {
        listener = nil
        sut?.clearAllRequests()
        sut = nil

        super.tearDown()
    }

    func testShouldReadArchivedManagerFromDisk() throws {
        // given
        let key = "test"
        let value = "value"
        let manager = try XCTUnwrap(sut)
        manager.queueRequest(MockRequest())
        manager.queueRequest(MockRequest())

        // when
        let archive1 = try XCTUnwrap(OfflineRequestManager.archivedManager(fileName: testFileName))
        archive1.connectivity?.stopNotifier()
        archive1.connectivity = nil

        archive1.delegate = OfflineRequestManagerListener()
        XCTAssertEqual(archive1.totalRequestCount, 2)
        archive1.attemptNextOperation()

        let request = try XCTUnwrap(archive1.ongoingRequests.first as? MockRequest)
         XCTAssertNil(request.dictionary[key])
        request.mock[key] = value
        request.save()

        let archive2 = try XCTUnwrap(OfflineRequestManager.archivedManager(fileName: testFileName))
        archive2.connectivity?.stopNotifier()
        archive2.connectivity = nil
        archive2.delegate = OfflineRequestManagerListener()
        XCTAssertEqual(archive2.totalRequestCount, 2)
        archive2.attemptNextOperation()

        // then
        let adjustedRequest = try XCTUnwrap(archive2.ongoingRequests.first as? MockRequest)
        XCTAssertEqual(adjustedRequest.dictionary[key] as? String, value)
    }

    func testShouldIndicateWhenARequestHasStarted() throws {
        // given
        let manager = try XCTUnwrap(sut)
        let request = MockRequest()
        let called = expectation(description: "called")
        listener?.triggerBlock = { type in
            switch type {
            case .started(let request):
                XCTAssertEqual(manager.progress, 0)
                XCTAssertFalse((request as? MockRequest)?.complete ?? true)
                called.fulfill()
            default:
                break
            }
        }

        // when
        manager.queueRequest(request)

        // then
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testShouldIndicateWhenARequestHasFinished() throws {
        // given
        let manager = try XCTUnwrap(sut)
        let request = MockRequest()
        let called = expectation(description: "called")
        listener?.triggerBlock = { type in
            switch type {
            case .finished(let request):
                XCTAssertEqual(manager.progress, 1)
                XCTAssertTrue((request as? MockRequest)?.complete ?? false)
                called.fulfill()
            default:
                break
            }
        }

        // when
        manager.queueRequest(request)

        // then
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testShouldIndicateWhenARequestHasFailed() throws {
        // given
        let manager = try XCTUnwrap(sut)
        let request = MockRequest()
        let result = NSError(domain: "test", code: -1, userInfo: nil)
        request.error = result
        let called = expectation(description: "called")
        listener?.triggerBlock = { type in
            switch type {
            case let .failed(request, error):
                XCTAssertEqual(manager.progress, 1)
                XCTAssertTrue((request as? MockRequest)?.complete ?? false)
                XCTAssertEqual(error as NSError, result)
                called.fulfill()
            default:
                break
            }
        }

        // when
        manager.queueRequest(request)

        // then
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testShouldUpdateSingleRequestProgress() throws {
        // given
        let manager = try XCTUnwrap(sut)
        let request = MockRequest()
        let called = expectation(description: "called")
        var i = 0.0
        let increment = MockRequest.progressIncrement
        listener?.triggerBlock = { type in
            switch type {
            case .progress(let progress):
                XCTAssertEqual(progress, i * increment)
                if progress >= 1 {
                    self.listener?.triggerBlock = nil
                    called.fulfill()
                } else {
                    i += 1
                }
            default:
                break
            }
        }

        // when
        manager.queueRequest(request)

        // then
        waitForExpectations(timeout: 2, handler: nil)
        XCTAssertEqual(manager.progress, 1)
    }

    func testShouldUpdateMultipleRequestProgressScaledToTotalRequests() throws {
        // given
        let manager = try XCTUnwrap(sut)
        let requests = [MockRequest(),
                        MockRequest(),
                        MockRequest()]
        let called = expectation(description: "called")
        listener?.triggerBlock = { type in
            switch type {
            case .progress(let progress):
                let requestProgress = requests.reduce(0.0, {
                    $0 + ($1.complete ? 0 : $1.currentProgress)
                })
                let completed = Double(manager.completedRequestCount) + requestProgress
                let diff = abs(progress - completed / Double(requests.count))
                XCTAssertLessThan(diff, 0.01)
                if progress >= 1 {
                    self.listener?.triggerBlock = nil
                    called.fulfill()
                }
            default:
                break
            }
        }

        // when
        manager.queueRequests(requests)

        // then
        waitForExpectations(timeout: 2, handler: nil)
        XCTAssertEqual(manager.progress, 1)
    }

    func testShouldNotReattempt() throws {
        // given
        let manager = try XCTUnwrap(sut)
        let request = MockRequest()
        let result = NSError(domain: "test", code: -1, userInfo: nil)
        request.error = result
        let called = expectation(description: "called")
        listener?.triggerBlock = { type in
            switch type {
            case .failed(_, let error):
                XCTAssertEqual(error as NSError, result)
                called.fulfill()
            default:
                break
            }
        }

        // when
        manager.queueRequest(request)

        // then
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testShouldReconfigureByRequestAndSucceed() throws {
        // given
        let manager = try XCTUnwrap(sut)
        let request = MockRequest()
        let result = NSError(domain: "test", code: -1, userInfo: nil)
        request.error = result
        request.shouldFixError = true
        let called = expectation(description: "called")
        listener?.triggerBlock = { type in
            switch type {
            case .finished(let request):
                XCTAssertTrue((request as? MockRequest)?.complete ?? false)
                called.fulfill()
            default:
                break
            }
        }

        // when
        manager.queueRequest(request)

        // then
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testShouldReconfigureByDelegateAndSucceed() throws {
        // given
        let manager = try XCTUnwrap(sut)
        let request = MockRequest()
        let result = NSError(domain: "test", code: -1, userInfo: nil)
        request.error = result
        listener?.reattemptBlock = { returnedRequest, _ in
            self.listener?.reattemptBlock = nil
            if let request = returnedRequest as? MockRequest {
                request.error = nil
            }
            return true
        }
        let called = expectation(description: "called")
        listener?.triggerBlock = { type in
            switch type {
            case .finished(let request):
                XCTAssertTrue((request as? MockRequest)?.complete ?? false)
                called.fulfill()
            default:
                break
            }
        }

        // when
        manager.queueRequest(request)

        // then
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testShouldKillStalledRequestAfterWaiting() throws {
        // given
        let manager = try XCTUnwrap(sut)
        manager.requestTimeLimit = 1
        let request = MockRequest()
        request.stalled = true
        let called = expectation(description: "called")
        listener?.triggerBlock = { type in
            switch type {
            case .failed(_, let error):
                let result = error as NSError
                XCTAssertEqual(result.code, -1)
                result.localizedDescription.assert(equal: "Offline Request Timed Out")
                called.fulfill()
            default:
                break
            }
        }

        // when
        manager.queueRequest(request)

        // then
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testCanAdjustQueuedRequestsUntilInProgress() throws {
        // given
        let manager = try XCTUnwrap(sut)
        manager.queueRequest(try XCTUnwrap(MockRequest(dictionary: ["name": "request1"])))
        manager.queueRequest(try XCTUnwrap(MockRequest(dictionary: ["name": "request2"])))
        manager.queueRequest(try XCTUnwrap(MockRequest(dictionary: ["name": "request3"])))

        // when
        XCTAssertEqual(manager.ongoingRequests.count, 1)
        XCTAssertEqual(manager.incompleteRequests.count, 3)
        let start2 = try XCTUnwrap(manager.incompleteRequests[1] as? MockRequest)
        XCTAssertEqual(start2.dictionary["name"] as? String, "request2")
        let start3 = try XCTUnwrap(manager.incompleteRequests[2] as? MockRequest)
        XCTAssertEqual(start3.dictionary["name"] as? String, "request3")
        manager.modifyPendingRequests { pendingRequests -> [OfflineRequest] in
            XCTAssertEqual(pendingRequests.count, 2)
            let name1 = (pendingRequests[0] as? MockRequest)?.dictionary["name"] as? String ?? "fail1"
            let name2 = (pendingRequests[1] as? MockRequest)?.dictionary["name"] as? String ?? "fail2"
            XCTAssertEqual(name1, "request2")
            XCTAssertEqual(name2, "request3")
            if let modified = MockRequest(dictionary: ["name": "\(name1) + \(name2)"]) {
                return [modified]
            }
            return []
        }

        // then
        XCTAssertEqual(manager.ongoingRequests.count, 1)
        XCTAssertEqual(manager.incompleteRequests.count, 2)
        let finish2 = try XCTUnwrap(manager.incompleteRequests[1] as? MockRequest)
        XCTAssertEqual(finish2.dictionary["name"] as? String, "request2 + request3")
    }
}

private class MockRequest: OfflineRequest {

    var error: NSError?
    var mock: [String: Any] = [:]
    var complete = false
    var title: String = "title"
    var subtitle: String = "subtitle"
    var failures: Int = 0

    static let progressIncrement = 0.2

    var currentProgress = 0.0

    var shouldFixError = false
    var stalled = false

    init() {
        mock = ["index": 1]
    }

    required init?(dictionary: [String: Any]) {
        mock = dictionary
    }

    var dictionary: [String: Any] {
        return mock
    }

    func perform(completion: @escaping (Error?) -> Void) {
        if stalled { return }

        Timer.scheduledTimer(withTimeInterval: 0.01,
                             repeats: true) { timer in
                                self.currentProgress += MockRequest.progressIncrement

                                self.updateProgress(to: self.currentProgress)

                                if self.currentProgress >= 1 {
                                    timer.invalidate()

                                    self.complete = true
                                    completion(self.error)
                                }
        }
    }

    func shouldAttemptResubmission(forError error: Error) -> Bool {
        if shouldFixError {
            self.error = nil
        }
        return shouldFixError
    }
}

private class OfflineRequestManagerListener: NSObject, OfflineRequestManagerDelegate {

    enum TriggerType {
        case progress(progress: Double)
        case connectionStatus(connected: Bool)
        case started(request: OfflineRequest)
        case updated(request: OfflineRequest)
        case finished(request: OfflineRequest)
        case failed(request: OfflineRequest, error: Error)
    }

    var triggerBlock: ((TriggerType) -> Void)?
    var reattemptBlock: ((OfflineRequest, Error) -> Bool)?

    func offlineRequest(withDictionary dictionary: [String: Any]) -> OfflineRequest? {
        return MockRequest(dictionary: dictionary)
    }

    func offlineRequestManager(_ manager: OfflineRequestManager,
                               didUpdateProgress progress: Double) {
        triggerBlock?(.progress(progress: progress))
    }

    func offlineRequestManager(_ manager: OfflineRequestManager,
                               didUpdateConnectionStatus connected: Bool) {
        triggerBlock?(.connectionStatus(connected: connected))
    }

    func offlineRequestManager(_ manager: OfflineRequestManager,
                               didStartRequest request: OfflineRequest) {
        triggerBlock?(.started(request: request))
    }

    func offlineRequestManager(_ manager: OfflineRequestManager,
                               didUpdateRequest request: OfflineRequest) {
        triggerBlock?(.updated(request: request))
    }

    func offlineRequestManager(_ manager: OfflineRequestManager,
                               requestDidFail request: OfflineRequest,
                               withError error: Error) {
        triggerBlock?(.failed(request: request, error: error))
    }

    func offlineRequestManager(_ manager: OfflineRequestManager,
                               didFinishRequest request: OfflineRequest) {
        triggerBlock?(.finished(request: request))
    }

    func offlineRequestManager(_ manager: OfflineRequestManager,
                               shouldReattemptRequest request: OfflineRequest,
                               withError error: Error) -> Bool {
        if let block = reattemptBlock {
            return block(request, error)
        }

        return false
    }
}
