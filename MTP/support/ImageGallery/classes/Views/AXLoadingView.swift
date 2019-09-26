// @copyright Trollwerks Inc.

// migrated from https://github.com/alexhillc/AXPhotoViewer

//
//  AXLoadingView.swift
//  AXPhotoViewer
//
//  Created by Alex Hill on 5/7/17.
//  Copyright © 2017 Alex Hill. All rights reserved.
//

/// AXLoadingView
final class AXLoadingView: UIView, AXLoadingViewProtocol {

    private var retryButton: AXButton?

    /// The error text to show inside of the `retryButton` when displaying an error.
    private var retryText: String {
        return L.tryAgain()
    }

    /// The attributes that will get applied to the `retryText` when displaying an error.
    private var retryAttributes: [NSAttributedString.Key: Any] {
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body,
                                                                      compatibleWith: self.traitCollection)
        let font = UIFont.systemFont(ofSize: fontDescriptor.pointSize,
                                     weight: UIFont.Weight.light)
        return [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
    }

    private var retryHandler: (() -> Void)?

    private lazy var indicatorView: UIView = UIActivityIndicatorView(style: .white)

    private var errorImageView: UIImageView?

    /// The image to show in the `errorImageView` when displaying an error.
    private var errorImage: UIImage? {
        return R.image.error()
    }

    private var errorLabel: UILabel?

    /// The error text to show when displaying an error.
    private var errorText: String {
        return L.errorState()
    }

    /// The attributes that will get applied to the `errorText` when displaying an error.
    private var errorAttributes: [NSAttributedString.Key: Any] {
        var fontDescriptor: UIFontDescriptor
            fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body,
                                                                      compatibleWith: self.traitCollection)
        var font: UIFont
            font = UIFont.systemFont(ofSize: fontDescriptor.pointSize, weight: UIFont.Weight.light)
        return [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
    }

    /// :nodoc:
    init() {
        super.init(frame: .zero)

        _ = NotificationCenter.default.addObserver(forName: UIContentSizeCategory.didChangeNotification,
                                                   object: nil,
                                                   queue: .main) { [weak self] _ in
            self?.setNeedsLayout()
        }
    }

    /// :nodoc:
    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    /// :nodoc:
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// :nodoc:
    override func layoutSubviews() {
        super.layoutSubviews()
        self.computeSize(for: self.frame.size, applySizingLayout: true)
    }

    /// :nodoc:
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return self.computeSize(for: size, applySizingLayout: false)
    }

    // swiftlint:disable:next function_body_length
    @discardableResult private func computeSize(for constrainedSize: CGSize,
                                                applySizingLayout: Bool) -> CGSize {
        func makeAttributedString(_ attributes: [NSAttributedString.Key: Any],
                                  for attributedString: NSAttributedString?) -> NSAttributedString? {
            guard let newAttributedString = attributedString?.mutableCopy() as? NSMutableAttributedString else {
                return attributedString
            }
            newAttributedString.setAttributes(nil,
                                              range: NSRange(location: 0, length: newAttributedString.length))
            newAttributedString.addAttributes(attributes,
                                              range: NSRange(location: 0, length: newAttributedString.length))
            return newAttributedString.copy() as? NSAttributedString
        }

        let ImageViewVerticalPadding: CGFloat = 20
        let VerticalPadding: CGFloat = 10
        var totalHeight: CGFloat = 0

        var indicatorViewSize: CGSize = .zero
        var errorImageViewSize: CGSize = .zero
        var errorLabelSize: CGSize = .zero
        var retryButtonSize: CGSize = .zero
        if let errorLabel = self.errorLabel {
            if let errorImageView = self.errorImageView {
                errorImageViewSize = errorImageView.sizeThatFits(constrainedSize)
                totalHeight += errorImageViewSize.height
                totalHeight += ImageViewVerticalPadding
            }

            errorLabel.attributedText = makeAttributedString(self.errorAttributes, for: errorLabel.attributedText)

            errorLabelSize = errorLabel.sizeThatFits(constrainedSize)
            totalHeight += errorLabelSize.height

            // on iOS, we want the button to be sized to its label,
            // on tvOS, we want the button to be sized to its original size for the focus effect
            if let retryButton = self.retryButton {
                retryButton.setAttributedTitle(makeAttributedString(self.retryAttributes,
                                                                    for: retryButton.attributedTitle(for: .normal)),
                                               for: .normal)

                let RetryButtonLabelPadding: CGFloat = 10.0
                retryButtonSize = retryButton.titleLabel?.sizeThatFits(constrainedSize) ?? .zero
                retryButtonSize.width += RetryButtonLabelPadding
                retryButtonSize.height += RetryButtonLabelPadding
                totalHeight += retryButtonSize.height
                totalHeight += VerticalPadding
            }
        } else {
            indicatorViewSize = self.indicatorView.sizeThatFits(constrainedSize)
            totalHeight += indicatorViewSize.height
        }

        if applySizingLayout {
            var yOffset: CGFloat = (constrainedSize.height - totalHeight) / 2.0

            if let errorLabel = self.errorLabel {
                if let errorImageView = self.errorImageView {
                    let origin = CGPoint(x: floor((constrainedSize.width - errorImageViewSize.width) / 2),
                                         y: floor(yOffset))
                    errorImageView.frame = CGRect(origin: origin,
                                                  size: errorImageViewSize)
                    yOffset += errorImageViewSize.height
                    yOffset += ImageViewVerticalPadding
                }

                errorLabel.frame = CGRect(origin: CGPoint(x: floor((constrainedSize.width - errorLabelSize.width) / 2),
                                                          y: floor(yOffset)),
                                          size: errorLabelSize)

                if let retryButton = self.retryButton {
                    yOffset += errorLabelSize.height
                    yOffset += VerticalPadding
                    let origin = CGPoint(x: floor((constrainedSize.width - retryButtonSize.width) / 2),
                                         y: floor(yOffset))
                    retryButton.frame = CGRect(origin: origin,
                                               size: retryButtonSize)
                    retryButton.setCornerRadius(retryButtonSize.height / 4.0, for: .normal)
                }
            } else {
                let origin = CGPoint(x: floor((constrainedSize.width - indicatorViewSize.width) / 2),
                                     y: floor(yOffset))
                self.indicatorView.frame = CGRect(origin: origin,
                                                  size: indicatorViewSize)
            }
        }

        return CGSize(width: constrainedSize.width, height: totalHeight)
    }

    /// AXLoadingViewProtocol
    func startLoading(initialProgress: CGFloat) {
        if self.indicatorView.superview == nil {
            self.addSubview(self.indicatorView)
            self.setNeedsLayout()
        }

        if let indicatorView = self.indicatorView as? UIActivityIndicatorView, !indicatorView.isAnimating {
            indicatorView.startAnimating()
        }
    }

    /// AXLoadingViewProtocol
    func stopLoading() {
        if let indicatorView = self.indicatorView as? UIActivityIndicatorView, indicatorView.isAnimating {
            indicatorView.stopAnimating()
        }
    }

    /// AXLoadingViewProtocol
    func updateProgress(_ progress: CGFloat) {
        // empty for now, need to create a progressive loading indicator
    }

    /// AXLoadingViewProtocol
    func showError(_ error: Error,
                   retryHandler: @escaping () -> Void) {
        stopLoading()

        if let errorImage = errorImage {
            let imageView = UIImageView(image: errorImage)
            imageView.tintColor = .white
            addSubview(imageView)
            errorImageView = imageView
        } else {
            errorImageView?.removeFromSuperview()
            errorImageView = nil
        }

        let label = UILabel()
        label.attributedText = NSAttributedString(string: errorText, attributes: errorAttributes)
        label.textAlignment = .center
        label.numberOfLines = 3
        label.textColor = .white
        addSubview(label)
        errorLabel = label

        self.retryHandler = retryHandler

        let button = AXButton()
        button.setAttributedTitle(NSAttributedString(string: retryText,
                                                     attributes: retryAttributes),
                                  for: .normal)
        button.addTarget(self, action: #selector(retryButtonAction(_:)), for: .touchUpInside)
        addSubview(button)
        retryButton = button

        setNeedsLayout()
    }

    /// AXLoadingViewProtocol
    func removeError() {
        if let errorImageView = self.errorImageView {
            errorImageView.removeFromSuperview()
            self.errorImageView = nil
        }

        if let errorLabel = self.errorLabel {
            errorLabel.removeFromSuperview()
            self.errorLabel = nil
        }

        if let retryButton = self.retryButton {
            retryButton.removeFromSuperview()
            self.retryButton = nil
        }

        self.retryHandler = nil
    }

    // MARK: - Button actions

    @objc fileprivate func retryButtonAction(_ sender: AXButton) {
        self.retryHandler?()
        self.retryHandler = nil
    }
}
