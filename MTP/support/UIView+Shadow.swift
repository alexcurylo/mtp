// @copyright Trollwerks Inc.

import UIKit

extension UIView {

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

@IBDesignable final class ShadowView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    /// Decoding intializer
    ///
    /// - Parameter aDecoder: Decoder
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }

    private func setup() {
        cornerRadius = EditProfileVC.Layout.sectionCornerRadius
        applyShadow()
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        updateShadow()
    }
}
