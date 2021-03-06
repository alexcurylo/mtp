// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class OperationReplyTests: TestCase {

    func testDescription() {
        // given
        let expected = "code 200: ok"

        // when
        let sut = OperationReply(code: 200, message: "ok")

        // then
        XCTAssertTrue(sut.isSuccess)
        sut.description.assert(equal: expected)
    }

    func testPasswordDescription() throws {
        // given
        let data = try XCTUnwrap(password.data(using: .utf8))
        let expected = "code 200: Password reset mail sent!"

        // when
        let sut = try JSONDecoder.mtp.decode(OperationMessageReply.self,
                                             from: data)

        // then
        XCTAssertTrue(sut.isSuccess)
        sut.description.assert(equal: expected)
        sut.debugDescription.assert(equal: passwordDebugDescription)
    }
}

private let password = """
{
"code": 200,
"data": "passwords.sent",
"message": "Password reset mail sent!",
"message_type": "success"
}
"""

private let passwordDebugDescription = """
< OperationMessageReply: code 200: Password reset mail sent!:
code: 200
message: Password reset mail sent!
messageType: success
/OperationMessageReply >
"""
