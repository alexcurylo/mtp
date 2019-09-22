// @copyright Trollwerks Inc.

import UIKit

/// A UITextField with settable insets
@IBDesignable class InsetTextField: UITextField {

    /// Expose horizontal inset
    @IBInspectable var hInset: CGFloat = 0
    /// Expose vertical inset
    @IBInspectable var vInset: CGFloat = 0

    /// Return text rect
    ///
    /// - Parameter bounds: Field bounds
    /// - Returns: Inset bounds
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return super.textRect(forBounds: bounds)
                    .insetBy(dx: hInset, dy: vInset)
    }

    /// Return editing rect
    ///
    /// - Parameter bounds: Field bounds
    /// - Returns: Inset bounds
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return super.editingRect(forBounds: bounds)
                    .insetBy(dx: hInset, dy: vInset)
    }

    /// Return placeholder rect
    ///
    /// - Parameter bounds: Field bounds
    /// - Returns: Inset bounds
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return super.placeholderRect(forBounds: bounds)
    }

    /// Return left view rect
    ///
    /// - Parameter bounds: Field bounds
    /// - Returns: Inset bounds
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        return super.leftViewRect(forBounds: bounds)
                    .offsetBy(dx: hInset, dy: vInset)
    }

    /// Return clear button rect
    ///
    /// - Parameter bounds: Field bounds
    /// - Returns: Inset bounds
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        return super.clearButtonRect(forBounds: bounds)
            .offsetBy(dx: -hInset, dy: vInset)
    }

    /// Return right view rect
    ///
    /// - Parameter bounds: Field bounds
    /// - Returns: Inset bounds
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return super.rightViewRect(forBounds: bounds)
    }

    /// Fill and disable
    ///
    /// - Parameter text: Text to fill with
    func disable(text: String) {
        self.text = text
        if !text.isEmpty {
            isEnabled = false
            alpha = 0.8
        }
    }
}

/// An InsetTextField with a gradient
final class InsetTextFieldGradient: InsetTextField {

    /// Expose start color
    @IBInspectable var startColor: UIColor = .dodgerBlue {
        didSet {
            setup()
        }
    }

    /// Expose end color
    @IBInspectable var endColor: UIColor = .azureRadiance {
        didSet {
            setup()
        }
    }

    /// Expose orientation
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
