// @copyright Trollwerks Inc.

// migrated from https://github.com/alexhillc/AXPhotoViewer

//
//  AXOverlayView.swift
//  AXPhotoViewer
//
//  Created by Alex Hill on 5/28/17.
//  Copyright © 2017 Alex Hill. All rights reserved.
//

import UIKit

// swiftlint:disable file_length

final class AXOverlayView: UIView, AXStackableViewContainerDelegate {
    // swiftlint:disable:previous type_body_length

    /// The toolbar used to set the `titleView`, `leftBarButtonItems`, `rightBarButtonItems`
    let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: 320, height: 44)))

    /// The title view displayed in the toolbar.
    /// This view is sized and centered between the `leftBarButtonItems` and `rightBarButtonItems`.
    /// This is prioritized over `title`.
    var titleView: AXOverlayTitleViewProtocol? {
        didSet {
            assert(self.titleView == nil ? true : self.titleView is UIView, "`titleView` must be a UIView.")

            if self.window == nil {
                return
            }

            self.updateToolbarBarButtonItems()
        }
    }

    /// The bar button item used internally to display the `titleView` attribute in the toolbar.
    var titleViewBarButtonItem: UIBarButtonItem?

    /// The title displayed in the toolbar. This string is centered between the `leftBarButtonItems`
    /// and `rightBarButtonItems`.
    /// Overwrites `internalTitle`.
    var title: String? {
        didSet {
            self.updateTitleBarButtonItem()
        }
    }

    /// The title displayed in the toolbar. This string is centered between the `leftBarButtonItems`
    /// and `rightBarButtonItems`.
    /// This is used internally by the library to set a default title. Overwritten by `title`.
    var internalTitle: String? {
        didSet {
            self.updateTitleBarButtonItem()
        }
    }

    /// The title text attributes inherited by the `title`.
    var titleTextAttributes: [NSAttributedString.Key: Any]? {
        // swiftlint:disable:previous discouraged_optional_collection
        didSet {
            self.updateTitleBarButtonItem()
        }
    }

    /// The bar button item used internally to display the `title` attribute in the toolbar.
    let titleBarButtonItem = UIBarButtonItem(customView: UILabel())

    /// The bar button item that appears in the top left corner of the overlay.
    var leftBarButtonItem: UIBarButtonItem? {
        set(value) {
            if let value = value {
                self.leftBarButtonItems = [value]
            } else {
                self.leftBarButtonItems = nil
            }
        }
        get {
            return self.leftBarButtonItems?.first
        }
    }

    /// The bar button items that appear in the top left corner of the overlay.
    var leftBarButtonItems: [UIBarButtonItem]? {
        // swiftlint:disable:previous discouraged_optional_collection
        didSet {
            if self.window == nil {
                return
            }

            self.updateToolbarBarButtonItems()
        }
    }

    /// The bar button item that appears in the top right corner of the overlay.
    var rightBarButtonItem: UIBarButtonItem? {
        set(value) {
            if let value = value {
                self.rightBarButtonItems = [value]
            } else {
                self.rightBarButtonItems = nil
            }
        }
        get {
            return self.rightBarButtonItems?.first
        }
    }

    /// The bar button items that appear in the top right corner of the overlay.
    var rightBarButtonItems: [UIBarButtonItem]? {
        // swiftlint:disable:previous discouraged_optional_collection
        didSet {
            if self.window == nil {
                return
            }

            self.updateToolbarBarButtonItems()
        }
    }

    /// The caption view to be used in the overlay.
    var captionView: AXCaptionViewProtocol = AXCaptionView() {
        didSet {
            guard let oldCaptionView = oldValue as? UIView else {
                assertionFailure("`oldCaptionView` must be a UIView.")
                return
            }

            guard let captionView = self.captionView as? UIView else {
                assertionFailure("`captionView` must be a UIView.")
                return
            }

            let index = self.bottomStackContainer.subviews.firstIndex(of: oldCaptionView)
            oldCaptionView.removeFromSuperview()
            self.bottomStackContainer.insertSubview(captionView, at: index ?? 0)
            self.setNeedsLayout()
        }
    }

    /// Whether or not to animate `captionView` changes. Defaults to true.
    var animateCaptionViewChanges: Bool = true {
        didSet {
            self.captionView.animateCaptionInfoChanges = self.animateCaptionViewChanges
        }
    }

    /// The inset of the contents of the `OverlayView`.
    ///  Use this property to adjust layout for things such as status bar height.
    /// For internal use only.
    var contentInset: UIEdgeInsets = .zero {
        didSet {
            self.setNeedsLayout()
        }
    }

    /// Container to embed all content anchored at the top of the `overlayView`.
    /// Add custom subviews to the top container in the order that you wish to stack them.
    /// These must be self-sizing views.
    var topStackContainer: AXStackableViewContainer!
    // swiftlint:disable:previous implicitly_unwrapped_optional

    /// Container to embed all content anchored at the bottom of the `overlayView`.
    /// Add custom subviews to the bottom container in the order that you wish to stack them.
    /// These must be self-sizing views.
    var bottomStackContainer: AXStackableViewContainer!
    // swiftlint:disable:previous implicitly_unwrapped_optional

    /// A flag that is set at the beginning and end of `OverlayView.setShowInterface(_:alongside:completion:)`
    fileprivate var isShowInterfaceAnimating = false

    /// Closures to be processed at the end of `OverlayView.setShowInterface(_:alongside:completion:)`
    fileprivate var showInterfaceCompletions = [() -> Void]()

    fileprivate var isFirstLayout: Bool = true

    init() {
        super.init(frame: .zero)

        self.topStackContainer = AXStackableViewContainer(views: [], anchoredAt: .top)
        self.topStackContainer.backgroundColor = AXConstants.overlayForegroundColor
        self.topStackContainer.delegate = self
        self.addSubview(self.topStackContainer)

        self.toolbar.backgroundColor = .clear
        self.toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        self.topStackContainer.addSubview(self.toolbar)

        self.bottomStackContainer = AXStackableViewContainer(views: [], anchoredAt: .bottom)
        self.bottomStackContainer.backgroundColor = AXConstants.overlayForegroundColor
        self.bottomStackContainer.delegate = self
        self.addSubview(self.bottomStackContainer)

        self.captionView.animateCaptionInfoChanges = true
        if let captionView = self.captionView as? UIView {
            self.bottomStackContainer.addSubview(captionView)
        }

        _ = NotificationCenter.default.addObserver(forName: UIContentSizeCategory.didChangeNotification,
                                                   object: nil,
                                                   queue: .main) { [weak self] _ in
            self?.setNeedsLayout()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        if self.window != nil {
            self.updateToolbarBarButtonItems()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        topStackContainer.contentInset = UIEdgeInsets(top: contentInset.top,
                                                      left: contentInset.left,
                                                      bottom: 0,
                                                      right: contentInset.right)
        topStackContainer.frame = CGRect(origin: .zero, size: topStackContainer.sizeThatFits(frame.size))

        bottomStackContainer.contentInset = UIEdgeInsets(top: 0,
                                                         left: contentInset.left,
                                                         bottom: contentInset.bottom,
                                                         right: contentInset.right)
        let bottomStackSize = bottomStackContainer.sizeThatFits(frame.size)
        bottomStackContainer.frame = CGRect(origin: CGPoint(x: 0,
                                                            y: frame.size.height - bottomStackSize.height),
                                            size: bottomStackSize)

        isFirstLayout = false
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let view = super.hitTest(point, with: event) as? UIControl {
            return view
        }

        return nil
    }

    // MARK: - Completions
    func performAfterShowInterfaceCompletion(_ closure: @escaping () -> Void) {
        self.showInterfaceCompletions.append(closure)

        if !self.isShowInterfaceAnimating {
            self.processShowInterfaceCompletions()
        }
    }

    func processShowInterfaceCompletions() {
        for completion in self.showInterfaceCompletions {
            completion()
        }

        self.showInterfaceCompletions.removeAll()
    }

    // MARK: - Show / hide interface
    func setShowInterface(_ show: Bool,
                          animated: Bool,
                          alongside closure: (() -> Void)? = nil,
                          completion: ((Bool) -> Void)? = nil) {
        let alpha: CGFloat = show ? 1 : 0
        if abs(alpha - self.alpha) <= .ulpOfOne {
            return
        }

        self.isShowInterfaceAnimating = true

        if abs(alpha - 1) <= .ulpOfOne {
            self.isHidden = false
        }

        let animations = { [weak self] in
            self?.alpha = alpha
            closure?()
        }

        let internalCompletion: (_ finished: Bool) -> Void = { [weak self] finished in
            if abs(alpha) <= .ulpOfOne {
                self?.isHidden = true
            }

            self?.isShowInterfaceAnimating = false

            completion?(finished)
            self?.processShowInterfaceCompletions()
        }

        if animated {
            UIView.animate(withDuration: AXConstants.frameAnimDuration,
                           animations: animations,
                           completion: internalCompletion)
        } else {
            animations()
            internalCompletion(true)
        }
    }

    // MARK: - AXCaptionViewProtocol

    func updateCaptionView(photo: AXPhotoProtocol) {
        self.captionView.applyCaptionInfo(attributedTitle: photo.attributedTitle,
                                          attributedDescription: photo.attributedDescription,
                                          attributedCredit: photo.attributedCredit)

        if self.isFirstLayout {
            self.setNeedsLayout()
            return
        }

        let size = self.bottomStackContainer.sizeThatFits(self.frame.size)
        let animations = { [weak self] in
            guard let self = self else { return }
            self.bottomStackContainer.frame = CGRect(origin: CGPoint(x: 0,
                                                                     y: self.frame.size.height - size.height),
                                                     size: size)
            self.bottomStackContainer.setNeedsLayout()
            self.bottomStackContainer.layoutIfNeeded()
        }

        if self.animateCaptionViewChanges {
            UIView.animate(withDuration: AXConstants.frameAnimDuration, animations: animations)
        } else {
            animations()
        }
    }

    // MARK: - AXStackableViewContainerDelegate
    func stackableViewContainer(_ stackableViewContainer: AXStackableViewContainer, didAddSubview: UIView) {
        self.setNeedsLayout()
    }

    func stackableViewContainer(_ stackableViewContainer: AXStackableViewContainer, willRemoveSubview: UIView) {
        DispatchQueue.main.async { [weak self] in
            self?.setNeedsLayout()
        }
    }

    // MARK: - UIToolbar convenience
    func updateToolbarBarButtonItems() {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = AXConstants.overlayBarButtonItemSpacing

        var barButtonItems = [UIBarButtonItem]()
        if let leftBarButtonItems = self.leftBarButtonItems {
            let last = leftBarButtonItems.last
            for barButtonItem in leftBarButtonItems {
                barButtonItems.append(barButtonItem)

                if barButtonItem != last {
                    barButtonItems.append(fixedSpace)
                }
            }
        }

        barButtonItems.append(flexibleSpace)

        var centerBarButtonItem: UIBarButtonItem?
        if let titleView = self.titleView as? UIView {
            if let titleViewBarButtonItem = titleViewBarButtonItem,
                titleViewBarButtonItem.customView === titleView {
                centerBarButtonItem = titleViewBarButtonItem
            } else {
                self.titleViewBarButtonItem = UIBarButtonItem(customView: titleView)
                centerBarButtonItem = self.titleViewBarButtonItem
            }
        } else {
            centerBarButtonItem = self.titleBarButtonItem
        }

        if let centerBarButtonItem = centerBarButtonItem {
            barButtonItems.append(centerBarButtonItem)
            barButtonItems.append(flexibleSpace)
        }

        if let rightBarButtonItems = self.rightBarButtonItems?.reversed() {
            let last = rightBarButtonItems.last
            for barButtonItem in rightBarButtonItems {
                barButtonItems.append(barButtonItem)

                if barButtonItem != last {
                    barButtonItems.append(fixedSpace)
                }
            }
        }

        self.toolbar.items = barButtonItems
    }

    func updateTitleBarButtonItem() {
        func defaultAttributes() -> [NSAttributedString.Key: Any] {
            let pointSize: CGFloat = 17.0
            let font = UIFont.systemFont(ofSize: pointSize, weight: UIFont.Weight.semibold)
            return [
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: UIColor.white
            ]
        }

        var attributedText: NSAttributedString?
        if let title = self.title {
            attributedText = NSAttributedString(string: title,
                                                attributes: self.titleTextAttributes ?? defaultAttributes())
        } else if let internalTitle = self.internalTitle {
            attributedText = NSAttributedString(string: internalTitle,
                                                attributes: self.titleTextAttributes ?? defaultAttributes())
        }

        if let attributedText = attributedText {
            guard let titleBarButtonItemLabel = self.titleBarButtonItem.customView as? UILabel else { return }
            if titleBarButtonItemLabel.attributedText != attributedText {
                titleBarButtonItemLabel.attributedText = attributedText
                titleBarButtonItemLabel.sizeToFit()
            }
        }
    }
}
