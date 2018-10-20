// @copyright Trollwerks Inc.

//Copyright (c) 2018 pikachu987 <pikachu77769@gmail.com>
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

import UIKit

enum TagDefaultOption {
    static var paddingLeftRight: CGFloat = 9
    static let paddingTopBottom: CGFloat = 3
    static var marginLeftRight: CGFloat = 8
    static var marginTopBottom: CGFloat = 8
    static var tagLayerColor: UIColor = .white
    static var tagLayerRadius: CGFloat = 14
    static var tagLayerWidth: CGFloat = 0
    static var tagTitleColor: UIColor = .white
    static var tagFont: UIFont = Avenir.heavy.of(size: 13)
    static var tagBackgroundColor: UIColor = .white
    static var lineBreakMode: NSLineBreakMode = .byTruncatingMiddle
    static var lastTagTitleColor: UIColor = .blue
    static var lastTagLayerColor: UIColor = .blue
    static var lastTagBackgroundColor: UIColor = .white
    static var gradientColors: [UIColor] = [.dodgerBlue, .azureRadiance]
    static var gradientOrientation: GradientOrientation = .horizontal
}

struct ButtonOptions {

    var paddingLeftRight: CGFloat
    var paddingTopBottom: CGFloat
    var layerColor: UIColor
    var layerRadius: CGFloat
    var layerWidth: CGFloat
    var tagTitleColor: UIColor
    var tagFont: UIFont
    var tagBackgroundColor: UIColor
    var lineBreakMode: NSLineBreakMode
    var gradientColors: [UIColor]
    var gradientOrientation: GradientOrientation

    init(
        paddingLeftRight: CGFloat = TagDefaultOption.paddingLeftRight,
        paddingTopBottom: CGFloat = TagDefaultOption.paddingTopBottom,
        layerColor: UIColor = TagDefaultOption.tagLayerColor,
        layerRadius: CGFloat = TagDefaultOption.tagLayerRadius,
        layerWidth: CGFloat = TagDefaultOption.tagLayerWidth,
        tagTitleColor: UIColor = TagDefaultOption.tagTitleColor,
        tagFont: UIFont = TagDefaultOption.tagFont,
        tagBackgroundColor: UIColor = TagDefaultOption.tagBackgroundColor,
        lineBreakMode: NSLineBreakMode = TagDefaultOption.lineBreakMode,
        gradientColors: [UIColor] = TagDefaultOption.gradientColors,
        gradientOrientation: GradientOrientation = TagDefaultOption.gradientOrientation) {
        self.paddingLeftRight = paddingLeftRight
        self.paddingTopBottom = paddingTopBottom
        self.layerColor = layerColor
        self.layerRadius = layerRadius
        self.layerWidth = layerWidth
        self.tagTitleColor = tagTitleColor
        self.tagFont = tagFont
        self.tagBackgroundColor = tagBackgroundColor
        self.lineBreakMode = lineBreakMode
        self.gradientColors = gradientColors
        self.gradientOrientation = gradientOrientation
    }
}

protocol TagButtonDelegate: AnyObject {
    /// When you touch the button, the function is called.
    func tagButtonAction(_ tagButton: TagButton, type: TagButtonType)
}

/// Button Type
enum TagButtonType {
    case custom, `default`, last, lastCustom
}

final class TagButton: GradientButton {

    weak var delegate: TagButtonDelegate?
    var index: Int = 0
    var key: Int = 0
    var keyString: String = ""
    var type: TagButtonType = .default

    var size: CGSize {
        var size = titleLabel?.attributedText?.size() ?? .zero
        size.width = ceil(size.width)
        size.height = ceil(size.height)
        size.width += contentEdgeInsets.left + contentEdgeInsets.right
        size.height += contentEdgeInsets.top + contentEdgeInsets.bottom
        size.width += 4
        size.height += 4
        return size
    }

    func setEntity(options: ButtonOptions) {
        setEntity()
        setEntityOptions(options: options)
    }

    func setEntityOptions(options: ButtonOptions) {
        contentEdgeInsets = UIEdgeInsets(
            top: options.paddingTopBottom,
            left: options.paddingLeftRight,
            bottom: options.paddingTopBottom,
            right: options.paddingLeftRight)
        borderColor = options.layerColor
        borderWidth = options.layerWidth
        cornerRadius = options.layerRadius
        setTitleColor(options.tagTitleColor, for: .normal)
        titleLabel?.font = options.tagFont
        backgroundColor = options.tagBackgroundColor
        titleLabel?.lineBreakMode = options.lineBreakMode
        apply(gradient: options.gradientColors,
              orientation: options.gradientOrientation)
    }

    func setEntity(paddingLeftRight: CGFloat,
                   paddingTopBottom: CGFloat) {
        contentEdgeInsets = UIEdgeInsets(
            top: paddingTopBottom,
            left: paddingLeftRight,
            bottom: paddingTopBottom,
            right: paddingLeftRight)
    }

    func setEntity(title: String) {
        setTitle(title, for: .normal)
        setEntity()
    }

    func setEntity() {
        translatesAutoresizingMaskIntoConstraints = false
        sizeToFit()

        removeTarget(self, action: #selector(touchAction(_:)), for: .touchUpInside)
        addTarget(self, action: #selector(touchAction(_:)), for: .touchUpInside)
    }

    func addConstraint() {
        removeConstraint()
        let widthConstraint = NSLayoutConstraint(
            item: self,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .width,
            multiplier: 1,
            constant: size.width)
        let heightConstraint = NSLayoutConstraint(
            item: self,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .height,
            multiplier: 1,
            constant: size.height)
        widthConstraint.priority = UILayoutPriority(900)
        heightConstraint.priority = UILayoutPriority(900)
        addConstraints([widthConstraint, heightConstraint])
    }

    func removeConstraint() {
        removeConstraints(constraints)
    }

    @objc private func touchAction(_ sender: UIButton) {
        delegate?.tagButtonAction(self, type: type)
    }
}
