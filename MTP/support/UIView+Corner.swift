// @copyright Trollwerks Inc.

import UIKit

/// Type of rounding to apply to corners
enum ViewCorners {

    /// No rounding
    case square
    /// All corners
    case all(radius: CGFloat)
    /// Top corners
    case top(radius: CGFloat)
    /// Bottom corners
    case bottom(radius: CGFloat)

    fileprivate var rounded: UIRectCorner {
        switch self {
        case .square: return []
        case .all: return .allCorners
        case .top: return [.topLeft, .topRight]
        case .bottom: return [.bottomLeft, .bottomRight]
        }
    }
}

extension UIView {

    /// Convenience for assigning corner rounding
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    /// Apply corner rounding
    /// - Parameter corners: Which corners to round
    func round(corners: ViewCorners) {
        switch corners {
        case .square:
            layer.mask = nil
            cornerRadius = 0
        case .all(let radius):
            layer.mask = nil
            cornerRadius = radius
        case .top(let radius),
             .bottom(let radius):
            cornerRadius = 0
            mask(corners: corners.rounded,
                 radius: radius)
        }
    }

    private func mask(corners: UIRectCorner,
                      radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
        layer.masksToBounds = false
    }
}
