// @copyright Trollwerks Inc.

// migrated from https://github.com/alexhillc/AXPhotoViewer

//
//  ZoomingImageView.swift
//  AXPhotoViewer
//
//  Created by Alex Hill on 5/21/17.
//  Copyright © 2017 Alex Hill. All rights reserved.
//

import UIKit

private let ZoomScaleEpsilon: CGFloat = 0.01

/// AXZoomingImageView
final class AXZoomingImageView: UIScrollView, UIScrollViewDelegate {

    /// Double-tap recognizer
    private(set) var doubleTapGestureRecognizer = UITapGestureRecognizer()

    /// Delegate
    weak var zoomScaleDelegate: AXZoomingImageViewDelegate?

    /// Displayed image
    var image: UIImage? {
        set(value) {
            self.updateImageView(image: value)
        }
        get {
            return self.imageView.image
        }
    }

    /// :nodoc:
    override var frame: CGRect {
        didSet { self.updateZoomScale() }
    }

    /// Displayed image view
    private(set) var imageView = UIImageView()

    private var needsUpdateImageView = false

    /// :nodoc:
    init() {
        super.init(frame: .zero)

        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.addTarget(self, action: #selector(doubleTapAction(_:)))
        doubleTapGestureRecognizer.isEnabled = false
        addGestureRecognizer(doubleTapGestureRecognizer)

        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)

        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        isScrollEnabled = false
        bouncesZoom = true
        decelerationRate = .fast
        delegate = self
        contentInsetAdjustmentBehavior = .never
    }

    /// :nodoc:
    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    private func updateImageView(image: UIImage?) {
        self.imageView.transform = .identity
        var imageSize: CGSize = .zero

        if let image = image {
            if self.imageView.image != image {
                self.imageView.image = image
            }
            imageSize = image.size
        } else {
            self.imageView.image = nil
        }

        self.imageView.frame = CGRect(origin: .zero, size: imageSize)
        self.contentSize = imageSize
        self.updateZoomScale()

        self.doubleTapGestureRecognizer.isEnabled = image != nil

        self.needsUpdateImageView = false
    }

    /// :nodoc:
    override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)

        if subview === self.imageView {
            self.needsUpdateImageView = true
        }
    }

    /// :nodoc:
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)

        if subview === self.imageView && self.needsUpdateImageView {
            self.updateImageView(image: self.imageView.image)
        }
    }

    // MARK: - UIScrollViewDelegate

    /// :nodoc:
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }

    /// :nodoc:
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.isScrollEnabled = true
    }

    /// :nodoc:
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ?
            (scrollView.bounds.size.width - scrollView.contentSize.width) / 2 : 0
        let offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ?
            (scrollView.bounds.size.height - scrollView.contentSize.height) / 2 : 0
        self.imageView.center = CGPoint(x: offsetX + (scrollView.contentSize.width / 2),
                                        y: offsetY + (scrollView.contentSize.height / 2))
    }

    /// :nodoc:
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        guard abs(scale - self.minimumZoomScale) <= ZoomScaleEpsilon else {
            return
        }

        scrollView.isScrollEnabled = false
    }

    // MARK: - Zoom scale

    private func updateZoomScale() {
        let imageSize = self.imageView.image?.size ?? CGSize(width: 1, height: 1)

        let scaleWidth = self.bounds.size.width / imageSize.width
        let scaleHeight = self.bounds.size.height / imageSize.height
        self.minimumZoomScale = min(scaleWidth, scaleHeight)

        let delegatedMaxZoomScale = self.zoomScaleDelegate?.zoomingImageView(self, maximumZoomScaleFor: imageSize)
        if let maximumZoomScale = delegatedMaxZoomScale, (maximumZoomScale - self.minimumZoomScale) >= 0 {
            self.maximumZoomScale = maximumZoomScale
        } else {
            self.maximumZoomScale = self.minimumZoomScale * 3.5
        }

        // if the zoom scale is the same, change it to force the UIScrollView to
        // recompute the scroll view's content frame
        if abs(self.zoomScale - self.minimumZoomScale) <= .ulpOfOne {
            self.zoomScale = self.minimumZoomScale + 0.1
        }
        self.zoomScale = self.minimumZoomScale

        self.isScrollEnabled = false
    }

    // MARK: - UITapGestureRecognizer

    @objc fileprivate func doubleTapAction(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: self.imageView)

        var zoomScale = self.maximumZoomScale
        if self.zoomScale >= self.maximumZoomScale || abs(self.zoomScale - self.maximumZoomScale) <= ZoomScaleEpsilon {
            zoomScale = self.minimumZoomScale
        }

        if abs(self.zoomScale - zoomScale) <= .ulpOfOne {
            return
        }

        let width = self.bounds.size.width / zoomScale
        let height = self.bounds.size.height / zoomScale
        let originX = point.x - (width / 2)
        let originY = point.y - (height / 2)

        let zoomRect = CGRect(x: originX, y: originY, width: width, height: height)
        self.zoom(to: zoomRect, animated: true)
    }
}

/// AXZoomingImageViewDelegate
protocol AXZoomingImageViewDelegate: AnyObject {

    /// Retrieve maximum zoom
    /// - Parameter zoomingImageView: AXZoomingImageView
    /// - Parameter imageSize: Image size
    func zoomingImageView(_ zoomingImageView: AXZoomingImageView,
                          maximumZoomScaleFor imageSize: CGSize) -> CGFloat
}
