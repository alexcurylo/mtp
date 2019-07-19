// @copyright Trollwerks Inc.

import Foundation

final class Scheduler {

    typealias Completion = () -> Void

    private var timer: Timer?
    private var then: Completion?

    deinit {
        stop()
    }

    func schedule(every seconds: TimeInterval,
                  then: @escaping Completion) {
        stop()
        self.then = then

        timer = Timer.scheduledTimer(withTimeInterval: seconds,
                                     repeats: true) { [weak self] _ in
            self?.fire()
        }
    }

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

    func start() {
        guard let timer = timer else { return }

        RunLoop.main.add(timer, forMode: .common)
        RunLoop.main.add(timer, forMode: .tracking)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func fire() {
        then?()
    }
}
