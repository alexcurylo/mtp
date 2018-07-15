// @copyright Trollwerks Inc.

import UIKit

typealias GradientPoints = (start: CGPoint, end: CGPoint)

enum GradientOrientation {
    case topRightBottomLeft
    case topLeftBottomRight
    case horizontal
    case vertical

    var start: CGPoint {
        return points.start
    }

    var end: CGPoint {
        return points.end
    }

    var points: GradientPoints {
        switch self {
        case .topRightBottomLeft:
            return (CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 0))
        case .topLeftBottomRight:
            return (CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 1))
        case .horizontal:
            return (CGPoint(x: 0, y: 0.5), CGPoint(x: 1, y: 0.5))
        case .vertical:
            return (CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 1))
        }
    }
}

extension UIView {

    static let gradientLayerName = "AppliedGradientLayer"

    func removeAppliedGradient() {
        guard let sublayers = layer.sublayers else { return }
        for layer in sublayers where layer.name == UIView.gradientLayerName {
            layer.removeFromSuperlayer()
        }
    }

    func apply(gradient colours: [UIColor],
               locations: [NSNumber]) {
        removeAppliedGradient()
        let gradient = CAGradientLayer()
        gradient.name = UIView.gradientLayerName
        gradient.frame = bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        layer.insertSublayer(gradient, at: 0)
    }

    func apply(gradient colours: [UIColor],
               orientation: GradientOrientation) {
        removeAppliedGradient()
        let gradient = CAGradientLayer()
        gradient.name = UIView.gradientLayerName
        gradient.frame = bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = orientation.start
        gradient.endPoint = orientation.end
        layer.insertSublayer(gradient, at: 0)
    }

    func round(corners radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
}

extension UIColor {

    // swiftlint:disable:next identifier_name
    convenience init(r: Int, g: Int, b: Int, a: Int = 255) {
        self.init(red: CGFloat(r) / 255.0,
                  green: CGFloat(g) / 255.0,
                  blue: CGFloat(b) / 255.0,
                  alpha: CGFloat(a) / 255.0)
    }

    convenience init(rgb: Int) {
        self.init(r: (rgb >> 16) & 0xFF,
                  g: (rgb >> 8) & 0xFF,
                  b: rgb & 0xFF)
    }

    convenience init(argb: Int) {
        self.init(r: (argb >> 16) & 0xFF,
                  g: (argb >> 8) & 0xFF,
                  b: argb & 0xFF,
                  a: (argb >> 24) & 0xFF)
    }
}
