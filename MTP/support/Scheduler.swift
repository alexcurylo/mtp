// @copyright Trollwerks Inc.

import Foundation

/// Convenience wrapper for Timer manipulation
final class Scheduler {

    /// Action to take on scheduling
    typealias Completion = () -> Void

    private var timer: Timer?
    private var then: Completion?

    /// Is timer active?
    var isActive: Bool {
        return timer != nil
    }

    /// :nodoc:
    deinit {
        stop()
    }

    /// Schedule repeating with immediate execution
    /// - Parameters:
    ///   - seconds: Seconds between firing
    ///   - then: Action to take on scheduling
    func fire(every seconds: TimeInterval,
              then: @escaping Completion) {
        schedule(every: seconds, then: then)
        fire()
   }

    /// Schedule repeating without immediate execution
    /// - Parameters:
    ///   - seconds: Seconds between firing
    ///   - then: Action to take on scheduling
    func schedule(every seconds: TimeInterval,
                  then: @escaping Completion) {
        stop()
        self.then = then

        timer = Timer.scheduledTimer(withTimeInterval: seconds,
                                     repeats: true) { [weak self] _ in
            self?.fire()
        }
    }

    /// Schedule once
    /// - Parameters:
    ///   - seconds: Seconds between firing
    ///   - then: Action to take on scheduling
    func schedule(at date: Date,
                  then: @escaping Completion) {
        stop()
        self.then = then

        timer = Timer(fire: date,
                      interval: 0,
                      repeats: false) { [weak self] _ in
            self?.fire()
        }
        start()
    }

    /// Begin timer
    func start() {
        guard let timer = timer else { return }

        RunLoop.main.add(timer, forMode: .common)
        RunLoop.main.add(timer, forMode: .tracking)
    }

    /// Stop timer
    func stop() {
        timer?.invalidate()
        timer = nil
    }

    /// Begin timer
    func fire() {
        then?()
    }
}
