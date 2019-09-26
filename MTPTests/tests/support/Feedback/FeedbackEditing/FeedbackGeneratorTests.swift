// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class FeedbackGeneratorTests: XCTestCase {

    func testGenerateNoHTML() throws {
        let configuration = FeedbackConfiguration(subject: "Subject",
                                                  additionalDiagnosticContent: "Additional",
                                                  topics: TopicItem.defaultTopics,
                                                  toRecipients: ["to@example.com"],
                                                  ccRecipients: ["cc@example.com"],
                                                  bccRecipients: ["bcc@example.com"],
                                                  usesHTML: false)

        let feedback = try FeedbackGenerator.generate(configuration: configuration,
                                                      repository: configuration.dataSource)
        XCTAssertEqual(feedback.subject, "Subject")
        XCTAssertTrue(feedback.body.contains("Additional"))
        XCTAssertFalse(feedback.isHTML)
        XCTAssertEqual(feedback.to, ["to@example.com"])
        XCTAssertEqual(feedback.cc, ["cc@example.com"])
        XCTAssertEqual(feedback.bcc, ["bcc@example.com"])
    }

    func testGenerateNoHTMLWithHidesAppInfoSection() throws {
        let configuration = FeedbackConfiguration(subject: "Subject",
                                                  additionalDiagnosticContent: "Additional",
                                                  topics: TopicItem.defaultTopics,
                                                  toRecipients: ["to@example.com"],
                                                  ccRecipients: ["cc@example.com"],
                                                  bccRecipients: ["bcc@example.com"],
                                                  hidesAppInfoSection: true,
                                                  usesHTML: false)
        let feedback = try FeedbackGenerator.generate(configuration: configuration,
                                                      repository: configuration.dataSource)
        XCTAssertEqual(feedback.subject, "Subject")
        XCTAssertTrue(feedback.body.contains("Additional"))
        XCTAssertFalse(feedback.isHTML)
        XCTAssertEqual(feedback.to, ["to@example.com"])
        XCTAssertEqual(feedback.cc, ["cc@example.com"])
        XCTAssertEqual(feedback.bcc, ["bcc@example.com"])
    }

    func testGenerateHTML() throws {
        let configuration = FeedbackConfiguration(subject: "Subject",
                                                  additionalDiagnosticContent: "Additional",
                                                  topics: TopicItem.defaultTopics,
                                                  toRecipients: ["to@example.com"],
                                                  ccRecipients: ["cc@example.com"],
                                                  bccRecipients: ["bcc@example.com"],
                                                  usesHTML: false)
        let feedback = try FeedbackGenerator.generate(configuration: configuration,
                                                      repository: configuration.dataSource)
        XCTAssertEqual(feedback.subject, "Subject")
        XCTAssertTrue(feedback.body.contains("Additional"))
        XCTAssertFalse(feedback.isHTML)
        XCTAssertEqual(feedback.to, ["to@example.com"])
        XCTAssertEqual(feedback.cc, ["cc@example.com"])
        XCTAssertEqual(feedback.bcc, ["bcc@example.com"])
    }
}
