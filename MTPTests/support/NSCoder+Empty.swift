// @copyright Trollwerks Inc.

import Foundation

extension NSCoder {

    /// For use in NSCoder constructor unit tests
    class var empty: NSCoder {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.finishEncoding()
        return NSKeyedUnarchiver(forReadingWith: data as Data)
    }
}
