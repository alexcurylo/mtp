// @copyright Trollwerks Inc.

import Foundation

/// Payload sent to API endpoint
struct ContactPayload: Codable, Hashable {

    /// category
    let category: String
    /// client_email
    let client_email: String
    /// client_name
    let client_name: String
    /// client_phone
    let client_phone: String
    /// message
    let message: String
}

/*
POST /api/send-message/contact-form
{
"category":"Report a Problem",
"client_name":"Test User",
"client_email":"test@user.com",
"client_phone":"111-222-333",
"attachments":[
{
"name":"",
"uuid":"6QvXKzIstmTf8ZIp0kocw9",
"mime":"image/png",
"type":"image",
"user_id":41184,
"uploaded":1,
"url":"/api/files/preview?uuid=6QvXKzIstmTf8ZIp0kocw9",
"id":66893
}
],
"message":"Test Message"
}
Attachments:
You can upload the photo to the server and use the response. The id (not the uuid) is that the backend will use.
*/
