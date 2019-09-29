// @copyright Trollwerks Inc.

import Foundation

/// Payload sent to API endpoint
struct ContactPayload: Codable, Hashable {

    private let category: String
    private let client_email: String
    private let client_name: String
    private let client_phone: String
    private let message: String
    private let attachments: [PhotoAttachment]

    init(with feedback: Feedback,
         image: PhotoReply?,
         user: UserJSON?) {
        category = feedback.subject
        message = feedback.body
        client_phone = feedback.phone ?? ""
        client_email = user?.email ?? L.unknown()
        client_name = user?.fullName ?? L.unknown()
        if let image = image {
            attachments = [PhotoAttachment(with: image)]
        } else {
            attachments = []
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(category, forKey: .category)
        try container.encode(client_email, forKey: .client_email)
        try container.encode(client_name, forKey: .client_name)
        try container.encode(message, forKey: .message)
        if !client_phone.isEmpty {
            try container.encode(client_phone, forKey: .client_phone)
        }
        if !attachments.isEmpty {
            try container.encode(attachments, forKey: .attachments)
        }
    }
}
