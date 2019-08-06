// @copyright Trollwerks Inc.

import Foundation

/// Handle JSON values that may be different values
/// Such as possibly quoted numbers
struct UncertainValue<T: Codable, U: Codable>: Codable {

    /// First possible value
    var tValue: T?
    /// Second possible value
    var uValue: U?

    private var value: Any? {
        return tValue ?? uValue
    }

    /// Convenience access to Int if present
    var intValue: Int? {
        switch value {
        case let intValue as Int:
            return intValue
        case let stringValue as String:
            return Int(stringValue)
        default:
            return nil
        }
    }

    /// Convenience access to Double if present
    var doubleValue: Double? {
        switch value {
        case let doubleValue as Double:
            return doubleValue
        case let stringValue as String:
            return Double(stringValue)
        default:
            return nil
        }
    }

    /// Initalize with first type
    ///
    /// - Parameter value: Value
    init(with value: T) {
        tValue = value
    }

    /// Initalize with second type
    ///
    /// - Parameter value: Value
    init(with value: U) {
        uValue = value
    }

    /// Initialize with decoder
    ///
    /// - Parameter decoder: Decoder
    /// - Throws: Decoding error
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        guard !container.decodeNil() else { return }
        tValue = try? container.decode(T.self)
        guard tValue == nil else { return }
        uValue = try? container.decode(U.self)
        guard uValue == nil else { return }
        let context = DecodingError.Context(
            codingPath: decoder.codingPath,
            debugDescription: "expected a \(T.self) or \(U.self)")
        throw DecodingError.typeMismatch(type(of: self), context)
    }

    /// Encode to encoder
    ///
    /// - Parameter encoder: Encoder
    /// - Throws: Encoding error
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let tValue = tValue {
            try container.encode(tValue)
        } else if let uValue = uValue {
            try container.encode(uValue)
        } else {
            try container.encodeNil()
        }
    }
}

/// Add Codable compliance to null
struct JSONNull: Codable {

    /// Initialize with decoder
    ///
    /// - Parameter decoder: Decoder
    /// - Throws: Decoding error
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            let context = DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "JSONNull expected nil")
            throw DecodingError.typeMismatch(type(of: self), context)
        }
    }

    /// Encode to encoder
    ///
    /// - Parameter encoder: Encoder
    /// - Throws: Encoding error
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
