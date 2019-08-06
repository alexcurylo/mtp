// @copyright Trollwerks Inc.

import UIKit

/// works around issue where text in storyboard loads not at top
final class TopLoadingTextView: UITextView {

    private var shouldEnableScroll = false

    /// Decoding intializer
    ///
    /// - Parameter aDecoder: Decoder
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        shouldEnableScroll = isScrollEnabled
        self.isScrollEnabled = false
    }

    /// Intercept layout process
    override func layoutSubviews() {
        super.layoutSubviews()
        isScrollEnabled = shouldEnableScroll
    }

    /// Implement text wrapping
    ///
    /// - Parameter rect: Bounds to exclude
    func exclude(rect: CGRect?) {
        guard let rect = rect else {
            textContainer.exclusionPaths = []
            return
        }

        let exclude = rect.insetBy(dx: 2, dy: 0)
        let imagePath = UIBezierPath(rect: exclude)
        textContainer.exclusionPaths = [imagePath]
    }
}
