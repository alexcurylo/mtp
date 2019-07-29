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
