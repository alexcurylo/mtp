// @copyright Trollwerks Inc.

import UIKit

/// A display text view that allows tapping on links
final class LinkTappableTextView: UITextView {

    /// Procedural intializer
    ///
    /// - Parameter frame: Display frame
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        configure()
    }

    /// Unsupported coding constructor
    ///
    /// - Parameter coder: An unarchiver object.
    required init?(coder: NSCoder) {
        return nil
    }

    /// Hit test
    ///
    /// - Parameters:
    ///   - point: Point tapped
    ///   - event: Event for tap
    /// - Returns: View hit if any
    override func hitTest(_ point: CGPoint,
                          with event: UIEvent?) -> UIView? {
        var location = point
        location.x -= textContainerInset.left
        location.y -= textContainerInset.top

        let characterIndex = layoutManager.characterIndex(
            for: location,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        if characterIndex < textStorage.length {
            if textStorage.attribute(.link,
                                     at: characterIndex,
                                     effectiveRange: nil) != nil {
                return self
            }
        }

        return nil
    }

    private func configure() {
        delaysContentTouches = false
        isEditable = false
        isScrollEnabled = false
        isSelectable = true
        isUserInteractionEnabled = true
        textContainer.lineFragmentPadding = 0
        textContainerInset = .zero
    }
}
