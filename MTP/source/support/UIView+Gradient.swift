// @copyright Trollwerks Inc.

import UIKit

typealias GradientPoints = (start: CGPoint, end: CGPoint)

enum GradientOrientation: Int {
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
            return (CGPoint(x: 1, y: 0), CGPoint(x: 0, y: 1))
        case .topLeftBottomRight:
            return (CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 1))
        case .horizontal:
            return (CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0))
        case .vertical:
            return (CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 1))
        }
    }
}

extension UIView {

    static let gradientLayerName = "BackingGradient"

    var gradient: CAGradientLayer? {
        return layer.sublayers?.first {
            $0.name == UIView.gradientLayerName
        } as? CAGradientLayer
    }

    func apply(gradient colors: [UIColor],
               orientation: GradientOrientation? = .vertical,
               locations: [Float] = []) {
        let apply = gradient ?? {
                let new = CAGradientLayer()
                new.name = UIView.gradientLayerName
                layer.insertSublayer(new, at: 0)
                return new
            }()
        apply.frame = bounds
        apply.colors = colors.map { $0.cgColor }
        if !locations.isEmpty {
            apply.locations = locations.map { NSNumber(value: $0) }
        }
        let points = orientation ?? .vertical
        apply.startPoint = points.start
        apply.endPoint = points.end
    }

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            if let border = layer.borderColor {
                return UIColor(cgColor: border)
            }
            return nil
        }
        set {
            layer.borderColor = borderColor?.cgColor
        }
    }

    func apply(shadow color: UIColor = .black,
               offset: CGSize = .zero,
               blur: CGFloat = 10,
               opacity: Float = 1) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = blur
        layer.shadowOpacity = opacity
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.masksToBounds = false
    }

    func animate(gradient colors: [UIColor],
                 duration: TimeInterval) {
        let from = gradient?.colors
        gradient?.colors = colors
        let animation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = from
        animation.toValue = colors
        animation.duration = duration
        animation.isRemovedOnCompletion = true
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        gradient?.add(animation, forKey: "animateGradient")
    }

    func apply(radialGradient colors: [UIColor]) {
        guard let gradient = CGGradient(colorsSpace: nil,
                                        colors: colors as CFArray,
                                        locations: nil) else { return }
        let endRadius = sqrt(pow(frame.width / 2, 2) + pow(frame.height / 2, 2))
        let center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        UIGraphicsGetCurrentContext()?.drawRadialGradient(
            gradient,
            startCenter: center,
            startRadius: 0.0,
            endCenter: center,
            endRadius: endRadius,
            options: .drawsBeforeStartLocation)
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

@IBDesignable class GradientView: UIView {

    @IBInspectable var startColor: UIColor = .white {
        didSet {
            setup()
        }
    }

    @IBInspectable var endColor: UIColor = .white {
        didSet {
            setup()
        }
    }

    @IBInspectable var orientation: Int = 3 {
        didSet {
            setup()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }

    func setup() {
        apply(gradient: [startColor, endColor],
              orientation: GradientOrientation(rawValue: orientation))
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        gradient?.frame = bounds
    }
}

@IBDesignable class GradientButton: UIButton {

    @IBInspectable var startColor: UIColor = .white {
        didSet {
            setup()
        }
    }

    @IBInspectable var endColor: UIColor = .white {
        didSet {
            setup()
        }
    }

    @IBInspectable var orientation: Int = 3 {
        didSet {
            setup()
         }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }

    func setup() {
        apply(gradient: [startColor, endColor],
              orientation: GradientOrientation(rawValue: orientation))
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        gradient?.frame = bounds
    }
}
