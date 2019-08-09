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

    var description: String {
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

    var description: String {
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
