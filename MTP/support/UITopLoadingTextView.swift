// @copyright Trollwerks Inc.

import UIKit

// works around issue where text in storyboard loads not at top

final class UITopLoadingTextView: UITextView {

    var shouldEnableScroll = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        shouldEnableScroll = isScrollEnabled
        self.isScrollEnabled = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        isScrollEnabled = shouldEnableScroll
    }
}
