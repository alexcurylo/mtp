// @copyright Trollwerks Inc.

extension Array {

    /// Extract members of types
    ///
    /// - Parameter type: Desired type
    /// - Returns: Array of all members of type
    func of<T>(type: T.Type) -> [T] {
        return lazy.compactMap { $0 as? T }
    }

    /// Extract first member of types
    ///
    /// - Parameter type: Desired type
    /// - Returns: First member of type if any
    func firstOf<T>(type: T.Type) -> T? {
        return lazy.compactMap { $0 as? T }.first
    }
}

extension Set {

    /// Extract members of types
    ///
    /// - Parameter type: Desired type
    /// - Returns: Array of all members of type
    func of<T>(type: T.Type) -> [T] {
        return lazy.compactMap { $0 as? T }
    }
}
