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
        code == 200
    }
}

extension OperationReply: CustomStringConvertible {

    var description: String {
        "code \(code): \(message)"
    }
}

private enum MessageType: String {
    case error
    case success
}

/// Reply from delete photo endpoint
struct QuietOperationReply: Codable {

    /// HTTP result code
    let code: Int

    /// Whether operation succeeded
    var isSuccess: Bool {
        code == 200
    }
}

/// Reply from delete photo endpoint
struct CodelessOperationReply: Codable {

    /// Result message
    let message: String

    /// Whether operation succeeded
    var isSuccess: Bool {
        !message.isEmpty
    }
}

/// Reply from the payssword reset and contact form endpoints
struct OperationMessageReply: Codable {

    /// HTTP result code
    let code: Int
    /// Result message
    let message: String
    // "Password reset mail sent!"
    // "Messages have been sent!"
    /// Message type
    private let messageType: String

    // private let data: String? or Int?
    // string "passwords.sent" in password reset
    // int 1 in contact form

    /// Whether operation succeeded
    var isSuccess: Bool {
        messageType == MessageType.success.rawValue
    }
}

extension OperationMessageReply: CustomStringConvertible {

    var description: String {
        "code \(code): \(message)"
    }
}

extension OperationMessageReply: CustomDebugStringConvertible {

    var debugDescription: String {
        """
        < OperationMessageReply: \(description):
        code: \(code)
        message: \(message)
        messageType: \(messageType)
        /OperationMessageReply >
        """
    }
}
