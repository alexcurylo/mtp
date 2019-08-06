// @copyright Trollwerks Inc.

import UIKit

@IBDesignable class InsetTextField: UITextField {

    @IBInspectable var hInset: CGFloat = 0
    @IBInspectable var vInset: CGFloat = 0

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return super.textRect(forBounds: bounds)
                    .insetBy(dx: hInset, dy: vInset)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return super.editingRect(forBounds: bounds)
                    .insetBy(dx: hInset, dy: vInset)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return super.placeholderRect(forBounds: bounds)
    }

    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        return super.leftViewRect(forBounds: bounds)
                    .offsetBy(dx: hInset, dy: vInset)
    }

    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        return super.clearButtonRect(forBounds: bounds)
            .offsetBy(dx: -hInset, dy: vInset)
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return super.rightViewRect(forBounds: bounds)
    }

    func disable(text: String) {
        self.text = text
        if !text.isEmpty {
            isEnabled = false
            alpha = 0.8
        }
    }
}

final class InsetTextFieldGradient: InsetTextField {

    var startColor: UIColor = .dodgerBlue {
        didSet {
            setup()
        }
    }

    @IBInspectable var endColor: UIColor = .azureRadiance {
        didSet {
            setup()
        }
    }

    @IBInspectable var orientation: Int = 2 {
        didSet {
            setup()
        }
    }

    /// Procedural intializer
    ///
    /// - Parameter frame: Display frame
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

    func setup() {
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
