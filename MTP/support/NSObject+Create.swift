// @copyright Trollwerks Inc.

import Foundation

/// Streamline configuration closures/functions
///
/// - Parameter configure: configuration closure/function
/// - Returns: configured object
func create<T>(then configure: ((T) -> Void)) -> T where T: NSObject {
    let object = T()
    configure(object)
    return object
}
