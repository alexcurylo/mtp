// @copyright Trollwerks Inc.

import UIKit

extension UIButton {

    /// Set tint color of image according to selection
    /// - Parameter tintedSelection: Selection
    /// - Parameter tint: Color
    func set(tintedSelection: Bool,
             tint: UIColor = .azureRadiance) {
        isSelected = tintedSelection
        tintColor = tintedSelection ? tint : .black
    }

    /// Set gap between icon and title in button
    /// - Parameter gap: Between icon and title
    /// - Parameter padding: Optionally replace current content insets
    func setInsets(gap: CGFloat,
                   content padding: UIEdgeInsets? = nil) {
        contentEdgeInsets = padding ?? contentEdgeInsets
        contentEdgeInsets.right += gap
        titleEdgeInsets = UIEdgeInsets(top: 0,
                                       left: gap,
                                       bottom: 0,
                                       right: -gap)
    }

    /// Center image and label
    /// - Parameter gap: Pixels between image and label
    /// - Parameter imageOnTop: Vertical or not
    func centerImageAndLabel(gap: CGFloat,
                             imageOnTop: Bool = true) {
        guard let image = currentImage,
              let label = titleLabel,
              let text = label.text else { return }

        let sign: CGFloat = imageOnTop ? 1 : -1
        titleEdgeInsets = UIEdgeInsets(top: (image.size.height + gap) * sign,
                                       left: -image.size.width,
                                       bottom: 0,
                                       right: 0)

        let font = label.font ?? Avenir.book.of(size: 17)
        let titleSize = text.size(withAttributes: [NSAttributedString.Key.font: font])
        imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + gap) * sign,
                                       left: 0,
                                       bottom: 0,
                                       right: -titleSize.width)
    }
}
