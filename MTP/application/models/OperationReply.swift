// @copyright Trollwerks Inc.

import Foundation

/// Generic endpoint reply
struct OperationReply: Codable {

    /// HTTP result code
    let code: Int
    /// Result message
    let message: String

    /// Whether operation succeeded
    var isSuccess: Bool {
        return code == 200
    }
}

extension OperationReply: CustomStringConvertible {

    public var description: String {
        return "code \(code): \(message)"
    }
}

private enum MessageType: String {
    case error
    case success
}

/// Reply from the password reset endpoint
struct PasswordResetReply: Codable {

    /// HTTP result code
    let code: Int
    private let data: String?
    /// Result message
    let message: String
    private let messageType: String

    /// Whether operation succeeded
    var isSuccess: Bool {
        return messageType == MessageType.success.rawValue
    }
}

extension PasswordResetReply: CustomStringConvertible {

    public var description: String {
        return "code \(code): \(message)"
    }
}

extension PasswordResetReply: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < PasswordResetReply: \(description):
        code: \(code)
        data: \(String(describing: data))
        message: \(message)
        messageType: \(messageType)
        /PasswordResetReply >
        """
    }
}

struct PhotoReply: Codable {

    let desc: String?
    let id: Int
    let location: LocationJSON?
    let locationId: UncertainValue<Int, String>?
    let mime: String
    let name: String
    let type: String
    let uploaded: Int
    let url: String
    let userId: Int
    let uuid: String
}

extension PhotoReply: CustomStringConvertible {

    public var description: String {
        return "photo \(id) - \(uuid): \(String(describing: desc))"
    }
}

extension PhotoReply: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < PhotoReply: \(description):
        desc: \(String(describing: desc))
        id: \(id)
        location: \(String(describing: location))
        locationId: \(String(describing: locationId))
        mime: \(mime)
        name: \(name)
        type: \(type)
        uploaded: \(uploaded)
        url: \(url)
        userId: \(userId)
        uuid: \(uuid)
        /PhotoReply >
        """
    }
}
