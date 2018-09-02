// @copyright Trollwerks Inc.

import UIKit

extension UIView {

  func constrainCentered(_ subview: UIView) {
    subview.translatesAutoresizingMaskIntoConstraints = false

    let verticalConstraint = NSLayoutConstraint(
      item: subview,
      attribute: .centerY,
      relatedBy: .equal,
      toItem: self,
      attribute: .centerY,
      multiplier: 1.0,
      constant: 0)

    let horizontalConstraint = NSLayoutConstraint(
      item: subview,
      attribute: .centerX,
      relatedBy: .equal,
      toItem: self,
      attribute: .centerX,
      multiplier: 1.0,
      constant: 0)

    let heightConstraint = NSLayoutConstraint(
      item: subview,
      attribute: .height,
      relatedBy: .equal,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1.0,
      constant: subview.frame.height)

    let widthConstraint = NSLayoutConstraint(
      item: subview,
      attribute: .width,
      relatedBy: .equal,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1.0,
      constant: subview.frame.width)

    addConstraints([
      horizontalConstraint,
      verticalConstraint,
      heightConstraint,
      widthConstraint])
  }

    // swiftlint:disable:next function_body_length
  func constrainToEdges(_ subview: UIView,
                        edges: UIRectEdge = .all) {
    subview.translatesAutoresizingMaskIntoConstraints = false

    let topConstraint: NSLayoutConstraint?
    if edges.contains(.top) {
        topConstraint = NSLayoutConstraint(
            item: subview,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1.0,
            constant: 0)
    } else {
        topConstraint = nil
    }

    let bottomConstraint: NSLayoutConstraint?
    if edges.contains(.bottom) {
        bottomConstraint = NSLayoutConstraint(
            item: subview,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0)
    } else {
        bottomConstraint = nil
    }

    let leadingConstraint: NSLayoutConstraint?
    if edges.contains(.left) {
        leadingConstraint = NSLayoutConstraint(
            item: subview,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1.0,
            constant: 0)
    } else {
        leadingConstraint = nil
    }

    let trailingConstraint: NSLayoutConstraint?
    if edges.contains(.right) {
        trailingConstraint = NSLayoutConstraint(
            item: subview,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: self,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 0)
    } else {
        trailingConstraint = nil
    }

    addConstraints([
      topConstraint,
      bottomConstraint,
      leadingConstraint,
      trailingConstraint].compactMap { $0 })
  }
}
