// @copyright Trollwerks Inc.

import UIKit

extension UIImage {

    /// Create a flat color image
    /// - Parameters:
    ///   - color: UIColor
    ///   - size: CGSize
    /// - Returns: Image if created
    static func image(color: UIColor, size: CGSize) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    /// Return a rounded copy
    /// - Parameter cornerRadius: Point radius
    /// - Returns: Image if created
    func rounded(cornerRadius: Int) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        UIBezierPath(roundedRect: rect,
                     cornerRadius: CGFloat(cornerRadius))
            .addClip()
        draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
