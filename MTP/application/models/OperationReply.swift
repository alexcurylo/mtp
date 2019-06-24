// @copyright Trollwerks Inc.

import Foundation

struct OperationReply: Codable {

    let code: Int
    let message: String

    var isSuccess: Bool {
        return code == 200
    }
}

extension OperationReply: CustomStringConvertible {

    public var description: String {
        return "code \(code): \(message)"
    }
}

enum MessageType: String {
    case error
    case success
}

struct PasswordResetReply: Codable {

    let code: Int
    let data: String?
    let message: String
    let messageType: String

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

struct UploadImageReply: Codable {

    let code: Int
    let message: String

    var isSuccess: Bool {
        return code == 200
    }
}

extension UploadImageReply: CustomStringConvertible {

    public var description: String {
        return "code \(code): \(message)"
    }
}
