// @copyright Trollwerks Inc.

// migrated from https://github.com/alexhillc/AXPhotoViewer

//
//  AXCaptionView.swift
//  AXPhotoViewer
//
//  Created by Alex Hill on 5/28/17.
//  Copyright © 2017 Alex Hill. All rights reserved.
//

import UIKit

/// AXCaptionView
final class AXCaptionView: UIView, AXCaptionViewProtocol {

    /// AXCaptionViewProtocol
    var animateCaptionInfoChanges: Bool = true

    private var titleLabel = UILabel()
    private var descriptionLabel = UILabel()
    private var creditLabel = UILabel()

    private var titleSizingLabel = UILabel()
    private var descriptionSizingLabel = UILabel()
    private var creditSizingLabel = UILabel()

    private var visibleLabels: [UILabel]
    private var visibleSizingLabels: [UILabel]

    private var needsCaptionLayoutAnim = false
    private var isCaptionAnimatingIn = false
    private var isCaptionAnimatingOut = false

    private var didOverwriteDefaultTitleFontAttributes = false
    private var didOverwriteDefaultDescriptionFontAttributes = false
    private var didOverwriteDefaultCreditFontAttributes = false

    private var isFirstLayout: Bool = true

    private var defaultTitleAttributes: [NSAttributedString.Key: Any] {
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body,
                                                                      compatibleWith: self.traitCollection)
        let font = UIFont.systemFont(ofSize: fontDescriptor.pointSize, weight: UIFont.Weight.bold)
        return [
            .font: font,
            .foregroundColor: UIColor.white,
        ]
    }

    private var defaultDescriptionAttributes: [NSAttributedString.Key: Any] {
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body,
                                                                      compatibleWith: self.traitCollection)
        let font = UIFont.systemFont(ofSize: fontDescriptor.pointSize, weight: UIFont.Weight.light)
        return [
            .font: font,
            .foregroundColor: UIColor.lightGray,
        ]
    }

    private var defaultCreditAttributes: [NSAttributedString.Key: Any] {
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .caption1,
                                                                      compatibleWith: self.traitCollection)
        let  font = UIFont.systemFont(ofSize: fontDescriptor.pointSize, weight: UIFont.Weight.light)
        return [
            .font: font,
            .foregroundColor: UIColor.gray,
        ]
    }

    /// :nodoc:
    init() {
        self.visibleLabels = [
            self.titleLabel,
            self.descriptionLabel,
            self.creditLabel,
        ]
        self.visibleSizingLabels = [
            self.titleSizingLabel,
            self.descriptionSizingLabel,
            self.creditSizingLabel,
        ]

        super.init(frame: .zero)

        self.backgroundColor = .clear

        self.titleSizingLabel.numberOfLines = 0
        self.descriptionSizingLabel.numberOfLines = 0
        self.creditSizingLabel.numberOfLines = 0

        self.titleLabel.textColor = .white
        self.titleLabel.numberOfLines = 0
        self.addSubview(self.titleLabel)

        self.descriptionLabel.textColor = .white
        self.descriptionLabel.numberOfLines = 0
        self.addSubview(self.descriptionLabel)

        self.creditLabel.textColor = .white
        self.creditLabel.numberOfLines = 0
        self.addSubview(self.creditLabel)

        _ = NotificationCenter.default.addObserver(forName: UIContentSizeCategory.didChangeNotification,
                                                   object: nil,
                                                   queue: .main) { [weak self] _ in
            self?.setNeedsLayout()
        }
    }

    /// :nodoc:
    required init?(coder aDecoder: NSCoder) { nil }

    /// :nodoc:
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// AXCaptionViewProtocol
    func applyCaptionInfo(attributedTitle: NSAttributedString?,
                          attributedDescription: NSAttributedString?,
                          attributedCredit: NSAttributedString?) {
        var didOverwriteDefaultTitleFontAttributes = false
        var didOverwriteDefaultDescriptionFontAttributes = false
        var didOverwriteDefaultCreditFontAttributes = false

        var title = NSAttributedString()
        if let attributedTitle = attributedTitle {
            let result = makeAttributedString(defaults: defaultTitleAttributes,
                                              for: attributedTitle)
            title = result.string
            didOverwriteDefaultTitleFontAttributes = result.removedDefaultKeys.contains(.font)
        }

        var description = NSAttributedString()
        if let attributedDescription = attributedDescription {
            let result = makeAttributedString(defaults: defaultDescriptionAttributes,
                                              for: attributedDescription)
            description = result.string
            didOverwriteDefaultDescriptionFontAttributes = result.removedDefaultKeys.contains(.font)
        }

        var credit = NSAttributedString()
        if let attributedCredit = attributedCredit {
            let result = makeAttributedString(defaults: defaultCreditAttributes,
                                              for: attributedCredit)
            credit = result.string
            didOverwriteDefaultCreditFontAttributes = result.removedDefaultKeys.contains(.font)
        }

        self.didOverwriteDefaultTitleFontAttributes = didOverwriteDefaultTitleFontAttributes
        self.didOverwriteDefaultDescriptionFontAttributes = didOverwriteDefaultDescriptionFontAttributes
        self.didOverwriteDefaultCreditFontAttributes = didOverwriteDefaultCreditFontAttributes

        self.visibleSizingLabels = []
        self.visibleLabels = []

        self.titleSizingLabel.attributedText = title
        if !title.string.isEmpty {
            self.visibleSizingLabels.append(self.titleSizingLabel)
            self.visibleLabels.append(self.titleLabel)
        }

        self.descriptionSizingLabel.attributedText = description
        if !description.string.isEmpty {
            self.visibleSizingLabels.append(self.descriptionSizingLabel)
            self.visibleLabels.append(self.descriptionLabel)
        }

        self.creditSizingLabel.attributedText = credit
        if !credit.string.isEmpty {
            self.visibleSizingLabels.append(self.creditSizingLabel)
            self.visibleLabels.append(self.creditLabel)
        }

        self.needsCaptionLayoutAnim = !self.isFirstLayout
    }

    /// :nodoc:
    override func layoutSubviews() {
        // swiftlint:disable:previous function_body_length
        super.layoutSubviews()

        self.computeSize(for: self.frame.size, applySizingLayout: true)

        weak var weakSelf = self
        func applySizingAttributes() {
            guard let self = weakSelf else { return }

            self.titleLabel.attributedText = self.titleSizingLabel.attributedText
            self.titleLabel.frame = self.titleSizingLabel.frame
            self.titleLabel.isHidden = (self.titleSizingLabel.attributedText?.string.isEmpty ?? true)

            self.descriptionLabel.attributedText = self.descriptionSizingLabel.attributedText
            self.descriptionLabel.frame = self.descriptionSizingLabel.frame
            self.descriptionLabel.isHidden = (self.descriptionSizingLabel.attributedText?.string.isEmpty ?? true)

            self.creditLabel.attributedText = self.creditSizingLabel.attributedText
            self.creditLabel.frame = self.creditSizingLabel.frame
            self.creditLabel.isHidden = (self.creditSizingLabel.attributedText?.string.isEmpty ?? true)
        }

        if self.animateCaptionInfoChanges && self.needsCaptionLayoutAnim {
            // ensure that this block runs in its own animation context (container may animate)
            // swiftlint:disable:next closure_body_length
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                let animateOut: () -> Void = {
                    self.titleLabel.alpha = 0
                    self.descriptionLabel.alpha = 0
                    self.creditLabel.alpha = 0
                }

                let animateOutCompletion: (_ finished: Bool) -> Void = { finished in
                    if !finished {
                        return
                    }

                    applySizingAttributes()
                    self.isCaptionAnimatingOut = false
                }

                let animateIn: () -> Void = {
                    self.titleLabel.alpha = 1
                    self.descriptionLabel.alpha = 1
                    self.creditLabel.alpha = 1
                }

                let animateInCompletion: (_ finished: Bool) -> Void = { finished in
                    if !finished {
                        return
                    }

                    self.isCaptionAnimatingIn = false
                }

                if self.isCaptionAnimatingOut {
                    return
                }

                self.isCaptionAnimatingOut = true
                UIView.animate(withDuration: AXOverlayView.frameAnimDuration / 2,
                               delay: 0,
                               options: [.beginFromCurrentState, .curveEaseOut],
                               animations: animateOut) { finished in
                    if self.isCaptionAnimatingIn {
                        return
                    }

                    animateOutCompletion(finished)
                    UIView.animate(withDuration: AXOverlayView.frameAnimDuration / 2,
                                   delay: 0,
                                   options: [.beginFromCurrentState, .curveEaseIn],
                                   animations: animateIn,
                                   completion: animateInCompletion)
                }
            }

            self.needsCaptionLayoutAnim = false
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                if !self.isCaptionAnimatingOut && !self.isCaptionAnimatingIn {
                    applySizingAttributes()
                }
            }
        }

        self.isFirstLayout = false
    }

    /// AXCaptionViewProtocol
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        computeSize(for: size, applySizingLayout: false)
    }

    @discardableResult private func computeSize(
        for constrainedSize: CGSize,
        applySizingLayout: Bool) -> CGSize {
        if !self.didOverwriteDefaultTitleFontAttributes {
            self.titleSizingLabel.attributedText = makeFontAdjustedAttributedString(
                for: self.titleSizingLabel.attributedText,
                fontTextStyle: .body
            )
        }

        if !self.didOverwriteDefaultDescriptionFontAttributes {
            self.descriptionSizingLabel.attributedText = makeFontAdjustedAttributedString(
                for: self.descriptionSizingLabel.attributedText,
                fontTextStyle: .body
            )
        }

        if !self.didOverwriteDefaultCreditFontAttributes {
            self.creditSizingLabel.attributedText = makeFontAdjustedAttributedString(
                for: self.creditSizingLabel.attributedText,
                fontTextStyle: .caption1
            )
        }

        let topPadding: CGFloat = 10
        let bottomPadding: CGFloat = 10
        let horizontalPadding: CGFloat = 15
        let interLabelSpacing: CGFloat = 2

        let xOffset = horizontalPadding
        var yOffset: CGFloat = 0

        for (index, label) in self.visibleSizingLabels.enumerated() {
            var constrainedLabelSize = constrainedSize
            constrainedLabelSize.width -= (2 * horizontalPadding)

            let labelSize = label.sizeThatFits(constrainedLabelSize)

            if index == 0 {
                yOffset += topPadding
            } else {
                yOffset += interLabelSpacing
            }

            let labelFrame = CGRect(
                x: xOffset,
                y: yOffset,
                width: constrainedLabelSize.width,
                height: labelSize.height
            )

            yOffset += labelFrame.size.height
            if index == (self.visibleSizingLabels.count - 1) {
                yOffset += bottomPadding
            }

            if applySizingLayout {
                label.frame = labelFrame
            }
        }

        return CGSize(width: constrainedSize.width, height: yOffset)
    }

    // MARK: - Helpers

    private func makeAttributedString(
        defaults: [NSAttributedString.Key: Any],
        for string: NSAttributedString) -> (string: NSAttributedString,
                                            removedDefaultKeys: Set<NSAttributedString.Key>
    ) {
        guard let defaultAttributedString = string.mutableCopy() as? NSMutableAttributedString else {
            return (string, [])
        }

        var removedKeys = Set<NSAttributedString.Key>()
        var defaultAttributes = defaults
        defaultAttributedString.enumerateAttributes(in: NSRange(location: 0,
                                                                length: defaultAttributedString.length),
                                                    options: []) { attributes, _, _ in
            for key in attributes.keys where defaultAttributes[key] != nil {
                defaultAttributes.removeValue(forKey: key)
                removedKeys.insert(key)
            }
        }

        defaultAttributedString.addAttributes(defaultAttributes,
                                              range: NSRange(location: 0,
                                                             length: defaultAttributedString.length))
        return (defaultAttributedString, removedKeys)
    }

    private func makeFontAdjustedAttributedString(for attributedString: NSAttributedString?,
                                                  fontTextStyle: UIFont.TextStyle) -> NSAttributedString? {
        guard let fontAdjustedAttributedString = attributedString?.mutableCopy() as? NSMutableAttributedString else {
            return attributedString
        }

        // swiftlint:disable:next trailing_closure
        fontAdjustedAttributedString.enumerateAttribute(NSAttributedString.Key.font,
                                                        in: NSRange(location: 0,
                                                                    length: fontAdjustedAttributedString.length),
                                                        options: [],
                                                        using: { [weak self] value, range, _ in
            guard let oldFont = value as? UIFont else { return }

            let newFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: fontTextStyle,
                                                                             compatibleWith: self?.traitCollection)
            let newFont = oldFont.withSize(newFontDescriptor.pointSize)
            fontAdjustedAttributedString.removeAttribute(.font, range: range)
            fontAdjustedAttributedString.addAttribute(.font, value: newFont, range: range)
        })

        return fontAdjustedAttributedString.copy() as? NSAttributedString
    }
}
