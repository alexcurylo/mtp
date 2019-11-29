// @copyright Trollwerks Inc.

import AVFoundation
import QuartzCore
import UIKit

extension CGSize {

    /// Rect creator
    func rect() -> CGRect {
        return CGRect(origin: .zero, size: self)
    }

    /// Center accessor
    func center() -> CGPoint {
        return CGPoint(x: self.width / 2, y: self.height / 2)
    }

    /// Center top accessor
    func centerTop(forSize size: CGSize) -> CGPoint {
        return CGPoint(x: self.width / 2, y: size.height / 2)
    }

    /// Center bottom accessor
    func centerBottom(forSize size: CGSize) -> CGPoint {
        return CGPoint(x: self.width / 2, y: self.height - size.height / 2)
    }

    /// Center left accessor
    func centerLeft(forSize size: CGSize) -> CGPoint {
        return CGPoint(x: size.width / 2, y: self.height / 2)
    }

    /// Center right accessor
    func centerRight(forSize size: CGSize) -> CGPoint {
        return CGPoint(x: self.width - size.width / 2, y: self.height / 2)
    }

    /// Top left accessor
    func topLeft(forSize size: CGSize) -> CGPoint {
        return CGPoint(x: size.width / 2, y: size.height / 2)
    }

    /// Top right  accessor
    func topRight(forSize size: CGSize) -> CGPoint {
        return CGPoint(x: self.width - size.width / 2, y: size.height / 2)
    }

    /// Bottom left accessor
    func bottomLeft(forSize size: CGSize) -> CGPoint {
        return CGPoint(x: size.width / 2, y: self.height - size.height / 2)
    }

    /// Bottom right accessor
    func bottomRight(forSize size: CGSize) -> CGPoint {
        return CGPoint(x: self.width - size.width / 2, y: self.height - size.height / 2)
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

    /// Convience accessor for center
    var center: CGPoint {
        get { return CGPoint(x: midX, y: midY) }
        set {
            let x = newValue.x - width / 2.0
            let y = newValue.y - height / 2.0
            let newOrigin = CGPoint(x: x, y: y)
            origin = newOrigin
        }
    }

    /// Aspect fit rectangle
    /// - Parameter size: Size
    func aspectFitRect(forSize size: CGSize) -> CGRect {
        return AVMakeRect(aspectRatio: size, insideRect: self)
    }

    /// Aspect fill rectangle
    /// - Parameter size: Size
    func aspectFillRect(forSize size: CGSize) -> CGRect {
        let sizeRatio = size.width / size.height
        let selfSizeRatio = self.width / self.height
        if sizeRatio > selfSizeRatio {
            return CGRect(x: 0, y: 0, width: floor(self.height * sizeRatio), height: self.height)
        } else {
            return CGRect(x: 0, y: 0, width: self.width, height: floor(self.width / sizeRatio))
        }
    }
}
