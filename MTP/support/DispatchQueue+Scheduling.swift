// @copyright Trollwerks Inc.

import Foundation

/// Generic closure type
typealias Closure = () -> Void

extension DispatchQueue {

    /// Execute on main queue
    /// - Parameter closure: Closure to execute
    static func toMain(_ closure: @escaping Closure) {
        if Thread.isMainThread {
            closure()
        } else {
            main.async(execute: closure)
        }
    }

    /// Execute in background
    /// - Parameter closure: Closure to execute
    static func toBackground(_ closure: @escaping Closure) {
         if Thread.isMainThread {
             DispatchQueue.global().async(execute: closure)
         } else {
             closure()
         }
     }
}
