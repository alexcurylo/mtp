// @copyright Trollwerks Inc.

import Foundation

struct OperationInfo: Codable {

    let code: Int
    let message: String

    var isSuccess: Bool {
        return code == 200
    }
}

extension OperationInfo: CustomStringConvertible {

    public var description: String {
        return "code \(code): \(message)"
    }
}

enum MessageType: String {
    case error
    case success
}

struct PasswordResetInfo: Codable {

    let code: Int
    let data: String?
    let message: String
    let messageType: String

    var isSuccess: Bool {
        return messageType == MessageType.success.rawValue
    }
}

extension PasswordResetInfo: CustomStringConvertible {

    public var description: String {
        return "code \(code): \(message)"
    }
}

extension PasswordResetInfo: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < PasswordResetInfo: \(description):
        code: \(code)
        data: \(String(describing: data))
        message: \(message)
        messageType: \(messageType)
        /PasswordResetInfo >
        """
    }
}

struct UploadImageInfo: Codable {

    let code: Int
    let message: String

    var isSuccess: Bool {
        return code == 200
    }
}

extension UploadImageInfo: CustomStringConvertible {

    public var description: String {
        return "code \(code): \(message)"
    }
}
