// @copyright Trollwerks Inc.

// migrated from https://github.com/alexhillc/AXPhotoViewer

//
//  AXStackableViewContainer.swift
//  AXPhotoViewer
//
//  Created by Alex Hill on 9/17/17.
//

import UIKit

final class AXStackableViewContainer: UIView {

    weak var delegate: AXStackableViewContainerDelegate?

    /// The inset of the contents of the `StackableViewContainer`.
    /// For internal use only.
    var contentInset: UIEdgeInsets = .zero

    fileprivate(set) var anchorPoint: AXStackableViewContainerAnchorPoint

    enum AXStackableViewContainerAnchorPoint: Int {
        case top
        case bottom
    }

    init(views: [UIView], anchoredAt point: AXStackableViewContainerAnchorPoint) {
        self.anchorPoint = point
        super.init(frame: .zero)
        views.forEach { self.addSubview($0) }
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.computeSize(for: self.frame.size, applySizingLayout: true)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return self.computeSize(for: size, applySizingLayout: false)
    }

    @discardableResult fileprivate func computeSize(for constrainedSize: CGSize, applySizingLayout: Bool) -> CGSize {
        var yOffset: CGFloat = 0
        let xOffset: CGFloat = self.contentInset.left
        var constrainedInsetSize = constrainedSize
        constrainedInsetSize.width -= (self.contentInset.left + self.contentInset.right)

        let subviews = (self.anchorPoint == .top) ? self.subviews : self.subviews.reversed()
        for subview in subviews {
            let size = subview.sizeThatFits(constrainedInsetSize)
            var frame: CGRect

            if yOffset == 0 && size.height > 0 {
                yOffset = self.contentInset.top
            }

            // special cases, UIToolbar + UINavigationBar are not to be trifled with in iOS 11
            var forceLayout: Bool
            if isToolbarOrNavigationBar(subview) {
                frame = CGRect(x: xOffset, y: yOffset, width: constrainedInsetSize.width, height: size.height)
                forceLayout = false
            } else {
                frame = CGRect(origin: CGPoint(x: xOffset, y: yOffset), size: size)
                forceLayout = true
            }

            yOffset += frame.size.height

            if applySizingLayout {
                subview.frame = frame
                if forceLayout {
                    subview.setNeedsLayout()
                }
                subview.layoutIfNeeded()
            }
        }

        if (yOffset - self.contentInset.top) > 0 {
            yOffset += self.contentInset.bottom
        }

        return CGSize(width: constrainedSize.width, height: yOffset)
    }

    // MARK: - AXStackableViewContainerDelegate
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        delegate?.stackableViewContainer(self, didAddSubview: subview)
    }

    override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        delegate?.stackableViewContainer(self, willRemoveSubview: subview)
    }

    // MARK: - Helpers
    private func isToolbarOrNavigationBar(_ view: UIView) -> Bool {
        return view is UIToolbar || view is UINavigationBar
    }
}

protocol AXStackableViewContainerDelegate: AnyObject {

    func stackableViewContainer(_ stackableViewContainer: AXStackableViewContainer,
                                didAddSubview: UIView)
    func stackableViewContainer(_ stackableViewContainer: AXStackableViewContainer,
                                willRemoveSubview: UIView)
}
