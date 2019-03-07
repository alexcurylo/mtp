// @copyright Trollwerks Inc.

import UIKit

@IBDesignable final class InsetTextField: UITextField {

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
}
