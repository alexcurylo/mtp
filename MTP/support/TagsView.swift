// @copyright Trollwerks Inc.

#if IMPLEMENT_FAVORITES

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

import Anchorage
import UIKit

// swiftlint:disable file_length

protocol TagsDelegate: AnyObject {
    func tagsTouchAction(_ tagsView: TagsView, tagButton: TagButton)
    func tagsLastTagAction(_ tagsView: TagsView, tagButton: TagButton)
    func tagsChangeHeight(_ tagsView: TagsView, height: CGFloat)
}

extension TagsDelegate {
    func tagsTouchAction(_ tagsView: TagsView, tagButton: TagButton) { }
    func tagsLastTagAction(_ tagsView: TagsView, tagButton: TagButton) { }
    func tagsChangeHeight(_ tagsView: TagsView, height: CGFloat) { }
}

// swiftlint:disable:next type_body_length
@IBDesignable final class TagsView: UIView {

    weak var delegate: TagsDelegate?

    private var _tagArray = [TagButton]()
    var tagArray: [TagButton] {
        return Array(_tagArray)
    }
    var tagTextArray: [String] {
        return _tagArray.compactMap { $0.currentTitle }
    }

    var viewWidth: CGFloat = UIScreen.main.bounds.width
    var viewHeight: CGFloat = 0

    private var lastTagButton: TagButton?

    override func awakeFromNib() {
        super.awakeFromNib()

        viewWidth = frame.width
        clipsToBounds = true
        redraw()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: viewWidth, height: 0)
    }

    var lineBreakMode: NSLineBreakMode = TagDefaultOption.lineBreakMode

    // The tag is truncated to a ,
    @IBInspectable var tags: String = "" {
        didSet {
            _tagArray.removeAll()
            append(contentsOf: tags.components(separatedBy: ",")
                                   .filter { !$0.isEmpty })
        }
    }

    @IBInspectable var paddingLeftRight: CGFloat = TagDefaultOption.paddingLeftRight {
        didSet { redraw() }
    }
    @IBInspectable var paddingTopBottom: CGFloat = TagDefaultOption.paddingTopBottom {
        didSet { redraw() }
    }
    @IBInspectable var marginLeftRight: CGFloat = TagDefaultOption.marginLeftRight {
        didSet { redraw() }
    }
    @IBInspectable var marginTopBottom: CGFloat = TagDefaultOption.marginTopBottom {
        didSet { redraw() }
    }
    @IBInspectable var tagLayerRadius: CGFloat = TagDefaultOption.tagLayerRadius {
        didSet { redraw() }
    }
    @IBInspectable var tagLayerWidth: CGFloat = TagDefaultOption.tagLayerWidth {
        didSet { redraw() }
    }
    @IBInspectable var tagLayerColor: UIColor = TagDefaultOption.tagLayerColor {
        didSet { redraw() }
    }
    @IBInspectable var tagTitleColor: UIColor = TagDefaultOption.tagTitleColor {
        didSet { redraw() }
    }
    @IBInspectable var tagBackgroundColor: UIColor = TagDefaultOption.tagBackgroundColor {
        didSet { redraw() }
    }
    var tagFont: UIFont = TagDefaultOption.tagFont {
        didSet { redraw() }
    }

    /// Always the last button is added.
    @IBInspectable var lastTag: String? = nil {
        didSet {
            if let text = lastTag {
                let button = TagButton(type: .system)
                button.delegate = self
                button.type = .last
                button.setEntity(title: text)
                lastTagButton = button
                redraw()
            } else {
                lastTagButton = nil
                redraw()
            }
        }
    }
    @IBInspectable var lastTagTitleColor: UIColor = TagDefaultOption.lastTagTitleColor {
        didSet { if lastTag != nil { redraw() } }
    }
    @IBInspectable var lastTagLayerColor: UIColor = TagDefaultOption.lastTagLayerColor {
        didSet { if lastTag != nil { redraw() } }
    }
    @IBInspectable var lastTagBackgroundColor: UIColor = TagDefaultOption.lastTagBackgroundColor {
        didSet { redraw() }
    }

    @discardableResult func append(_ button: TagButton) -> TagButton {
        button.delegate = self
        button.type = .custom
        button.setEntity()
        button.setEntity(paddingLeftRight: paddingLeftRight, paddingTopBottom: paddingTopBottom)
        _tagArray.append(button)
        redraw()
        return button
    }

    func append(contentsOf: [TagButton]) {
        for button in contentsOf {
            button.delegate = self
            button.type = .custom
            button.setEntity()
            button.setEntity(paddingLeftRight: paddingLeftRight, paddingTopBottom: paddingTopBottom)
            _tagArray.append(button)
        }
        redraw()
    }

    @discardableResult func append(_ text: String) -> TagButton {
        let button = TagButton(type: .system)
        button.delegate = self

        button.setEntity(title: text)
        _tagArray.append(button)
        redraw()
        return button
    }

    func append(contentsOf: [String]) {
        for text in contentsOf {
            let button = TagButton(type: .system)
            button.delegate = self
            button.setEntity(title: text)
            _tagArray.append(button)
        }
        redraw()
    }

    @discardableResult func update(_ button: TagButton, at index: Int) -> TagButton? {
        if index < 0 { return nil }
        if _tagArray.count > index {
            button.delegate = self
            button.type = .custom
            button.setEntity()
            button.setEntity(paddingLeftRight: paddingLeftRight, paddingTopBottom: paddingTopBottom)
            _tagArray[index] = button
            redraw()
            return button
        }
        return nil
    }

    @discardableResult func update(_ text: String, at index: Int) -> TagButton? {
        if index < 0 { return nil }
        if _tagArray.count > index {
            let button = TagButton(type: .system)
            button.delegate = self
            button.setEntity(title: text)
            _tagArray[index] = button
            redraw()
            return button
        }
        return nil
    }

    @discardableResult func insert(_ button: TagButton, at index: Int) -> TagButton {
        if _tagArray.count > index {
            button.delegate = self
            button.type = .custom
            button.setEntity()
            button.setEntity(paddingLeftRight: paddingLeftRight, paddingTopBottom: paddingTopBottom)
            _tagArray.insert(button, at: index < 0 ? 0 : index)
            redraw()
            return button
        } else {
            return append(button)
        }
    }

    @discardableResult func insert(_ text: String, at index: Int) -> TagButton {
        if _tagArray.count > index {
            let button = TagButton(type: .system)
            button.delegate = self
            button.setEntity(title: text)
            _tagArray.insert(button, at: index < 0 ? 0 : index)
            redraw()
            return button
        } else {
            return append(text)
        }
    }

    @discardableResult func remove(_ index: Int) -> TagButton? {
        if index < 0 { return nil }
        if _tagArray.count > index {
            let item = _tagArray.remove(at: index)
            item.removeConstraint()
            item.removeFromSuperview()
            redraw()
            return item
        }
        return nil
    }

    @discardableResult func remove(_ button: TagButton) -> TagButton? {
        for (index, element) in _tagArray.enumerated() where element == button {
            let item = _tagArray.remove(at: index)
            item.removeConstraint()
            item.removeFromSuperview()
            redraw()
            return item
        }
        return nil
    }

    func removeAll() {
        for element in _tagArray {
            element.removeConstraint()
            element.removeFromSuperview()
        }
        lastTagButton?.removeConstraint()
        lastTagButton?.removeFromSuperview()
        removeConstraints(constraints)
        _tagArray.removeAll()
        redraw()
    }

    func lastTagButton(_ button: TagButton) {
        button.delegate = self
        button.type = .lastCustom
        lastTagButton = button
        redraw()
    }

    private func removeAllConstraint() {
        _tagArray.forEach { element in
            element.removeConstraint()
            element.removeFromSuperview()
        }
        lastTagButton?.removeConstraint()
        lastTagButton?.removeFromSuperview()
        removeConstraints(constraints)
    }

    /// It is called when you add, delete or modify a button.
    func redraw() {
        removeAllConstraint()

        if _tagArray.isEmpty && lastTag == nil {
            viewHeight = 0
            delegate?.tagsChangeHeight(self, height: 0)
            addConstraint(NSLayoutConstraint(
                item: self,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .height,
                multiplier: 1,
                constant: 0))
            return
        }

        var tagArray = _tagArray
        if let tagButton = lastTagButton {
            tagArray.append(tagButton)
        }

        viewHeight = 0
        if !tagArray.isEmpty {
            viewHeight += marginTopBottom + tagArray[0].size.height + marginTopBottom
        }

        topItem = nil
        leftItem = nil
        buttonsWidth = 0
        leadingLine = nil
        for (index, element) in tagArray.enumerated() {
            layoutTag(index: index, element: element)
        }

        delegate?.tagsChangeHeight(self, height: viewHeight)
    }

    private var topItem: UIView?
    private var leftItem: UIView?
    private var buttonsWidth: CGFloat = 0
    private var leadingLine: NSLayoutConstraint?

    private func centerLine() {
        let half = floor((viewWidth - buttonsWidth) / 2)
        leadingLine?.constant = half
        leadingLine = nil
    }

    // swiftlint:disable:next function_body_length
    private func layoutTag(index: Int, element: TagButton) {
        addSubview(element)
        element.index = index
        if element.type == .default || element.type == .last {
            element.setEntityOptions(options: ButtonOptions(
                paddingLeftRight: paddingLeftRight,
                paddingTopBottom: paddingTopBottom,
                layerColor: element.type == .default ? tagLayerColor : lastTagLayerColor,
                layerRadius: tagLayerRadius,
                layerWidth: tagLayerWidth,
                tagTitleColor: element.type == .default ? tagTitleColor : lastTagTitleColor,
                tagFont: tagFont,
                tagBackgroundColor: element.type == .default ? tagBackgroundColor : lastTagBackgroundColor,
                lineBreakMode: lineBreakMode
            ))
        } else {
            element.setEntity(paddingLeftRight: paddingLeftRight, paddingTopBottom: paddingTopBottom)
        }
        element.addConstraint()

        var width = ceil(element.size.width) +
            marginLeftRight +
            (buttonsWidth == 0 ? marginLeftRight : 0)

        /// Prev Element Trailing, Next Line
        if !( buttonsWidth == 0 || (floor(viewWidth) - buttonsWidth - width > 0) ) {
            trailingAnchor >= tagArray[index - 1].trailingAnchor + marginLeftRight
            centerLine()

            width = ceil(element.size.width) + marginLeftRight + marginLeftRight
            buttonsWidth = 0
            topItem = tagArray[index - 1]
            leftItem = nil
            viewHeight += element.size.height + marginTopBottom
        }

        if let leftItem = leftItem {
            element.leadingAnchor == leftItem.trailingAnchor + marginLeftRight
        } else {
            leadingLine = element.leadingAnchor == leadingAnchor + marginLeftRight
        }
        if let topItem = topItem {
            element.topAnchor == topItem.bottomAnchor + marginTopBottom
        } else {
            element.topAnchor == topAnchor + marginTopBottom
        }

        leftItem = element
        buttonsWidth += width

        if element == tagArray[tagArray.count - 1] {
            bottomAnchor == element.bottomAnchor + marginTopBottom
            trailingAnchor >= element.trailingAnchor + marginTopBottom
            centerLine()
        }
    }
}

extension TagsView: TagButtonDelegate {

    func tagButtonAction(_ tagButton: TagButton, type: TagButtonType) {
        if type == .last || type == .lastCustom {
            delegate?.tagsLastTagAction(self, tagButton: tagButton)
        } else {
            delegate?.tagsTouchAction(self, tagButton: tagButton)
        }
    }
}

#endif
