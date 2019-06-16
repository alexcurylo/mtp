// @copyright Trollwerks Inc.

import UIKit

enum ViewCorners {

    case square
    case all(radius: CGFloat)
    case top(radius: CGFloat)
    case bottom(radius: CGFloat)

    var rounded: UIRectCorner {
        switch self {
        case .square: return []
        case .all: return .allCorners
        case .top: return [.topLeft, .topRight]
        case .bottom: return [.bottomLeft, .bottomRight]
        }
    }
}

extension UIView {

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

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

    func mask(corners: UIRectCorner,
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
