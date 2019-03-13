// @copyright Trollwerks Inc.

extension Array {

    func of<T>(type: T.Type) -> [T] {
        return lazy.compactMap { $0 as? T }
    }

    func firstOf<T>(type: T.Type) -> T? {
        return lazy.compactMap { $0 as? T }.first
    }
}
