// @copyright Trollwerks Inc.

import Foundation

struct UncertainValue<T: Codable, U: Codable>: Codable {

    var tValue: T?
    var uValue: U?

    var value: Any? {
        return tValue ?? uValue
    }

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

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        guard !container.decodeNil() else { return }
        tValue = try? container.decode(T.self)
        guard tValue == nil else { return }
        uValue = try? container.decode(U.self)
        guard uValue == nil else { return }
        let context = DecodingError.Context(codingPath: decoder.codingPath,
                                            debugDescription: "expected a \(T.self) or \(U.self)")
        throw DecodingError.typeMismatch(type(of: self), context)
    }

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
