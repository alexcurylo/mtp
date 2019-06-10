// @copyright Trollwerks Inc.

import Foundation

class KVNOperation: Operation {

    private var _executing = false {
        willSet { willChangeValue(forKey: "isExecuting") }
        didSet { didChangeValue(forKey: "isExecuting") }
    }
    override var isExecuting: Bool { return _executing }

    func execute(_ executing: Bool) {
        _executing = executing
    }

    private var _finished = false {
        willSet { willChangeValue(forKey: "isFinished") }
        didSet { didChangeValue(forKey: "isFinished") }
    }
    override var isFinished: Bool { return _finished }

    func finish(_ finished: Bool) {
        _finished = finished
    }

    //swiftlint:disable:next unavailable_function
    func operate() {
        fatalError("operate has not been overridden")
    }

    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }

        execute(true)

        autoreleasepool {
            operate()
        }

        if _executing {
           execute(false)
        }
        if !_finished {
            finish(true)
        }
    }
}
