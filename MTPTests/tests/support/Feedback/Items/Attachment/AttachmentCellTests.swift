// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class AttachmentCellTests: XCTestCase {

    func testConfigure() throws {
        let cell = AttachmentCell(style: .default,
                                  reuseIdentifier: AttachmentCell.reuseIdentifier)
        var item = AttachmentItem(isHidden: false)
        let image = try XCTUnwrap(UIImage(color: .red))
        item.media = .image(image)
        let handler = MockAttachmentCellEventHandler()
        AttachmentCell.configure(cell,
                                 with: item,
                                 for: IndexPath(row: 0, section: 0),
                                 eventHandler: handler)
        XCTAssertTrue(cell.imageView?.image === image)
    }

    func testTapImageView() throws {
        let cell = AttachmentCell(style: .default,
                                  reuseIdentifier: AttachmentCell.reuseIdentifier)
        var item = AttachmentItem(isHidden: false)
        let image = try XCTUnwrap(UIImage(color: .red))
        item.media = .image(image)
        let handler = MockAttachmentCellEventHandler()
        AttachmentCell.configure(cell,
                                 with: item,
                                 for: IndexPath(row: 0, section: 0),
                                 eventHandler: handler)
        cell.attViewTapped(UITapGestureRecognizer())
        XCTAssertTrue(handler.invokedShowImage)
    }
}

private class MockAttachmentCellEventHandler: AttachmentCellEventProtocol {
    var invokedShowImage = false
    var invokedShowImageCount = 0
    var invokedShowImageParameters: (item: AttachmentItem, Void)?
    var invokedShowImageParametersList = [(item: AttachmentItem, Void)]()

    func showImage(of item: AttachmentItem) {
        invokedShowImage = true
        invokedShowImageCount += 1
        invokedShowImageParameters = (item, ())
        invokedShowImageParametersList.append((item, ()))
    }
}

extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
