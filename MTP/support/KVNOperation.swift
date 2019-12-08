// @copyright Trollwerks Inc.

import Foundation

/// Operation with KVN support for isExecuting and isFinished
class KVNOperation: Operation {

    private var _executing = false {
        willSet { willChangeValue(forKey: "isExecuting") }
        didSet { didChangeValue(forKey: "isExecuting") }
    }
    /// Executing state of operation
    override var isExecuting: Bool { return _executing }

    /// Set executing state
    /// - Parameter executing: Executing state
    func execute(_ executing: Bool) {
        _executing = executing
    }

    private var _finished = false {
        willSet { willChangeValue(forKey: "isFinished") }
        didSet { didChangeValue(forKey: "isFinished") }
    }
    /// Finished state of operation
    override var isFinished: Bool { return _finished }

    /// Set finished state
    /// - Parameter finished: Finished state
    func finish(_ finished: Bool) {
        _finished = finished
    }

    /// Perform task - must be overridden
    func operate() {
        // override to implement
    }

    /// Send completion notification
    func complete() {
        if _executing {
            execute(false)
        }
        if !_finished {
            finish(true)
        }
    }

    /// Completion override point
    func operated() {
        complete()
    }

    /// Operation execution
    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }

        execute(true)

        autoreleasepool {
            operate()
        }

        operated()
    }
}

/// A KVNOperation for blocks
final class AsyncBlockOperation: KVNOperation {

    /// The block to execute
    typealias Operation = (@escaping () -> Void) -> Void

    private let operation: Operation

    /// Initialize with block
    /// - Parameter operation: Block to execute
    init(operation: @escaping Operation) {
        self.operation = operation
        super.init()
    }

    /// Asynchronously completing execution
    override func operate() {
        operation {
            self.complete()
        }
    }

    /// Stubbed override for block to complete
    override func operated() { }
}
