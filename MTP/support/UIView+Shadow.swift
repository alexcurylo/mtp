// @copyright Trollwerks Inc.

private extension UIView {

    func applyShadow(color: UIColor = .darkGray,
                     offset: CGSize = .zero,
                     radius: CGFloat = 4,
                     opacity: Float = 0.7) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.masksToBounds = false
        updateShadow()
    }

    func updateShadow() {
        layer.shadowPath = UIBezierPath(roundedRect: bounds,
                                        cornerRadius: cornerRadius).cgPath
    }
}

/// A View with a shadow
@IBDesignable final class ShadowView: UIView {

    /// Procedural intializer
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
        cornerRadius = 5
        applyShadow()
    }

    /// Update screen rendering
    /// - Parameter layer: Our layer
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        updateShadow()
    }
}
