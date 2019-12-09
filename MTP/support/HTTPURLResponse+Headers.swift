// @copyright Trollwerks Inc.

import Foundation

extension HTTPURLResponse {

    /// Find header
    /// - Parameter header: Header to find
    /// - Returns: Value if found
    func find(header: String) -> String? {
        let keyValues = allHeaderFields.map {
            (String(describing: $0.key).lowercased(), String(describing: $0.value))
        }

        if let headerValue = keyValues.first(where: { $0.0 == header.lowercased() }) {
            return headerValue.1
        }
        return nil
    }
}
