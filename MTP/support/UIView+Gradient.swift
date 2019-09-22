// @copyright Trollwerks Inc.

import UIKit

private typealias GradientPoints = (start: CGPoint, end: CGPoint)

/// Supported gradient orientations
enum GradientOrientation: Int {

    /// Top right to bottom left
    case topRightBottomLeft
    /// Top left to bottom right
    case topLeftBottomRight
    /// Horizontal
    case horizontal
    /// Vertical
    case vertical

    fileprivate var start: CGPoint {
        return points.start
    }

    fileprivate var end: CGPoint {
        return points.end
    }

    fileprivate var points: GradientPoints {
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

    private static let gradientLayerName = "BackingGradient"

    /// Layer with gradient
    var gradient: CAGradientLayer? {
        return layer.sublayers?.first {
            $0.name == UIView.gradientLayerName
        } as? CAGradientLayer
    }

    /// Apply a gradient
    ///
    /// - Parameters:
    ///   - colors: Start to end color array
    ///   - orientation: Orientation
    ///   - locations: Optional location array
    func apply(gradient colors: [UIColor],
               orientation: GradientOrientation? = .vertical,
               locations: [Float] = []) {
        let apply: CAGradientLayer = gradient ?? CAGradientLayer { [weak self] in
            $0.name = UIView.gradientLayerName
            self?.layer.insertSublayer($0, at: 0)
        }
        apply.frame = bounds
        apply.colors = colors.map { $0.cgColor }
        if !locations.isEmpty {
            apply.locations = locations.map { NSNumber(value: $0) }
        }
        let points = orientation ?? .vertical
        apply.startPoint = points.start
        apply.endPoint = points.end
    }

    /// Convenience for assigning layer border width
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    /// Convenience for assigning layer border color
    @IBInspectable var borderColor: UIColor? {
        get {
            if let border = layer.borderColor {
                return UIColor(cgColor: border)
            }
            return nil
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    private func animate(gradient colors: [UIColor],
                         duration: TimeInterval) {
        let from = gradient?.colors
        gradient?.colors = colors
        let animation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = from
        animation.toValue = colors
        animation.duration = duration
        animation.isRemovedOnCompletion = true
        animation.fillMode = .forwards
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        gradient?.add(animation, forKey: "animateGradient")
    }

    private func apply(radialGradient colors: [UIColor]) {
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

    /// Convenience component initializer
    ///
    /// - Parameters:
    ///   - r: Red, 0...255
    ///   - g: Green, 0...255
    ///   - b: Blue, 0...255
    ///   - a: Alpha, 0...255
    convenience init(r: Int, g: Int, b: Int, a: Int = 255) {
        self.init(red: CGFloat(r) / 255.0,
                  green: CGFloat(g) / 255.0,
                  blue: CGFloat(b) / 255.0,
                  alpha: CGFloat(a) / 255.0)
    }

    /// Convenience Int RGB initializer
    ///
    /// - Parameter rgb: 3 byte RGB
    convenience init(rgb: Int) {
        self.init(r: (rgb >> 16) & 0xFF,
                  g: (rgb >> 8) & 0xFF,
                  b: rgb & 0xFF)
    }

    /// Convenience Int ARGB initializer
    ///
    /// - Parameter rgb: 4 byte ARGB
    convenience init(argb: Int) {
        self.init(r: (argb >> 16) & 0xFF,
                  g: (argb >> 8) & 0xFF,
                  b: argb & 0xFF,
                  a: (argb >> 24) & 0xFF)
    }
}

/// View that contains a gradient
@IBDesignable final class GradientView: UIView {

    /// Gradient starting color
    @IBInspectable var startColor: UIColor = .white {
        didSet {
            setup()
        }
    }

    /// Gradient ending color
    @IBInspectable var endColor: UIColor = .white {
        didSet {
            setup()
        }
    }

    /// Gradient orientation
    @IBInspectable var orientation: Int = 3 {
        didSet {
            setup()
        }
    }

    /// Simple gradient setter
    ///
    /// - Parameters:
    ///   - colors: Color array
    ///   - direction: GradientOrientation
    func set(gradient colors: [UIColor],
             orientation direction: GradientOrientation) {
        startColor = colors[0]
        endColor = colors[1]
        orientation = direction.rawValue
    }

    /// Procedural intializer
    ///
    /// - Parameter frame: Display frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    /// :nodoc:
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        apply(gradient: [startColor, endColor],
              orientation: GradientOrientation(rawValue: orientation))
    }

    /// Update screen rendering
    ///
    /// - Parameter layer: Our layer
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        gradient?.frame = bounds
    }

    /// Set predefined style
    ///
    /// - Parameter style: Style definition
    func set(style: Styler) {
        switch style {
        case .login:
            set(gradient: [.frenchPass, .white],
                orientation: .vertical)
        case .map, .system:
            break
        case .standard:
            set(gradient: [.dodgerBlue, .azureRadiance],
                orientation: .topRightBottomLeft)
        }
    }
}

/// Button with a gradient background
@IBDesignable class GradientButton: UIButton {

    /// Gradient starting color
    @IBInspectable var startColor: UIColor = .white {
        didSet {
            setup()
        }
    }

    /// Gradient ending color
    @IBInspectable var endColor: UIColor = .white {
        didSet {
            setup()
        }
    }

    /// Gradient orientation
    @IBInspectable var orientation: Int = 3 {
        didSet {
            setup()
         }
    }

    /// Factory for gradient buttons triggering URL navigation
    ///
    /// - Parameters:
    ///   - title: Button title
    ///   - link: Triggered link
    /// - Returns: Created button
    static func urlButton(title: String,
                          link: String) -> GradientButton {
        let button = GradientButton {
            $0.orientation = GradientOrientation.horizontal.rawValue
            $0.startColor = .dodgerBlue
            $0.endColor = .azureRadiance
            $0.cornerRadius = 4
            $0.contentEdgeInsets = UIEdgeInsets(
                top: 8,
                left: 16,
                bottom: 8,
                right: 16)

            $0.setTitle(title, for: .normal)
            $0.titleLabel?.font = Avenir.heavy.of(size: 13)
            $0.accessibilityIdentifier = link
        }
        return button
    }

    /// Procedural intializer
    ///
    /// - Parameter frame: Display frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    /// :nodoc:
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        apply(gradient: [startColor, endColor],
              orientation: GradientOrientation(rawValue: orientation))
    }

    /// Update screen rendering
    ///
    /// - Parameter layer: Our layer
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        gradient?.frame = bounds
    }
}

extension UIEdgeInsets {

    /// Convenience accessor for horizontal inset total
    var horizontal: CGFloat {
        return left + right
    }

    /// Convenience accessor for vertical inset total
    var vertical: CGFloat {
        return top + bottom
    }
}

extension CGRect {

    /// Convience accessor for shortest edge
    var minEdge: CGFloat {
        return min(width, height)
    }
}
