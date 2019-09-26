// @copyright Trollwerks Inc.

// migrated from https://github.com/alexhillc/AXPhotoViewer

//
//  AXPhotoViewController.swift
//  AXPhotoViewer
//
//  Created by Alex Hill on 5/7/17.
//  Copyright © 2017 Alex Hill. All rights reserved.
//

import UIKit

/// AXPhotoViewController
final class AXPhotoViewController: UIViewController, AXPageableViewControllerProtocol, AXZoomingImageViewDelegate {

    /// delegate
    weak var delegate: AXPhotoViewControllerDelegate?

    /// AXPageableViewControllerProtocol
    var pageIndex: Int = 0

    /// loadingView
    private(set) var loadingView: AXLoadingViewProtocol?

    /// zoomingImageView
    var zoomingImageView: AXZoomingImageView {
        // swiftlint:disable:next force_cast
        return self.view as! AXZoomingImageView
    }

    private var photo: AXPhotoProtocol?
    private weak var notificationCenter: NotificationCenter?

    /// :nodoc:
    init(loadingView: AXLoadingViewProtocol,
         notificationCenter: NotificationCenter) {
        self.loadingView = loadingView
        self.notificationCenter = notificationCenter

        super.init(nibName: nil, bundle: nil)

        notificationCenter.addObserver(self,
                                       selector: #selector(photoLoadingProgressDidUpdate(_:)),
                                       name: .photoLoadingProgressUpdate,
                                       object: nil)

        notificationCenter.addObserver(self,
                                       selector: #selector(photoImageDidUpdate(_:)),
                                       name: .photoImageUpdate,
                                       object: nil)
    }

    /// :nodoc:
    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    /// :nodoc:
    deinit {
        self.notificationCenter?.removeObserver(self)
    }

    /// :nodoc:
    override func loadView() {
        self.view = AXZoomingImageView()
    }

    /// :nodoc:
    override func viewDidLoad() {
        super.viewDidLoad()

        self.zoomingImageView.zoomScaleDelegate = self

        if let loadingView = self.loadingView as? UIView {
            self.view.addSubview(loadingView)
        }
    }

    /// :nodoc:
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        var adjustedSize = self.view.bounds.size
        adjustedSize.width -= (self.view.safeAreaInsets.left + self.view.safeAreaInsets.right)
        adjustedSize.height -= (self.view.safeAreaInsets.top + self.view.safeAreaInsets.bottom)

        let loadingViewSize = self.loadingView?.sizeThatFits(adjustedSize) ?? .zero
        let origin = CGPoint(x: floor((self.view.bounds.size.width - loadingViewSize.width) / 2),
                             y: floor((self.view.bounds.size.height - loadingViewSize.height) / 2))
        (self.loadingView as? UIView)?.frame = CGRect(origin: origin,
                                                      size: loadingViewSize)
    }

    /// Apply photo
    /// - Parameter photo: Photo
    func applyPhoto(_ photo: AXPhotoProtocol) {
        self.photo = photo

        weak var weakSelf = self
        func resetImageView() {
            weakSelf?.zoomingImageView.image = nil
        }

        self.loadingView?.removeError()

        switch photo.ax_loadingState {
        case .loading, .notLoaded, .loadingCancelled:
            resetImageView()
            self.loadingView?.startLoading(initialProgress: photo.ax_progress)
        case .loadingFailed:
            resetImageView()
            let error = photo.ax_error ?? NSError()
            self.loadingView?.showError(error, retryHandler: { [weak self] in
                guard let self = self else { return }
                self.delegate?.photoViewController(self, retryDownloadFor: photo)
                self.loadingView?.removeError()
                self.loadingView?.startLoading(initialProgress: photo.ax_progress)
            })
        case .loaded:
            guard photo.image != nil else {
                assertionFailure("Must provide valid `UIImage` in \(#function)")
                return
            }

            self.loadingView?.stopLoading()

            if let image = photo.image {
                self.zoomingImageView.image = image
            }
        }

        self.view.setNeedsLayout()
    }

    // MARK: - AXPageableViewControllerProtocol

    /// :nodoc:
    func prepareForReuse() {
        self.zoomingImageView.image = nil
    }

    // MARK: - AXZoomingImageViewDelegate

    /// :nodoc:
    func zoomingImageView(_ zoomingImageView: AXZoomingImageView, maximumZoomScaleFor imageSize: CGSize) -> CGFloat {
        return self.delegate?.photoViewController(self,
                                                  maximumZoomScaleForPhotoAt: self.pageIndex,
                                                  minimumZoomScale: zoomingImageView.minimumZoomScale,
                                                  imageSize: imageSize) ?? .leastNormalMagnitude
    }

    // MARK: - Notifications

    /// :nodoc:
    @objc private func photoLoadingProgressDidUpdate(_ notification: Notification) {
        guard let photo = notification.object as? AXPhotoProtocol else {
            assertionFailure("Photos must conform to the AXPhoto protocol.")
            return
        }

        guard photo === self.photo,
              let progress = notification.userInfo?[AXPhotosViewControllerNotification.ProgressKey] as? CGFloat else {
            return
        }

        self.loadingView?.updateProgress(progress)
    }

    /// :nodoc:
    @objc private func photoImageDidUpdate(_ notification: Notification) {
        guard let photo = notification.object as? AXPhotoProtocol else {
            assertionFailure("Photos must conform to the AXPhoto protocol.")
            return
        }

        guard photo === self.photo, let userInfo = notification.userInfo else {
            return
        }

        if userInfo[AXPhotosViewControllerNotification.ImageKey] != nil {
            self.applyPhoto(photo)
        } else if let error = userInfo[AXPhotosViewControllerNotification.ErrorKey] as? Error {
            self.loadingView?.showError(error, retryHandler: { [weak self] in
                guard let self = self, let photo = self.photo else { return }
                self.delegate?.photoViewController(self, retryDownloadFor: photo)
                self.loadingView?.removeError()
                self.loadingView?.startLoading(initialProgress: photo.ax_progress)
                self.view.setNeedsLayout()
            })

            self.view.setNeedsLayout()
        }
    }
}

/// AXPhotoViewControllerDelegate
protocol AXPhotoViewControllerDelegate: AnyObject, NSObjectProtocol {

    /// Retry download
    /// - Parameter photoViewController: AXPhotoViewController
    /// - Parameter photo: photo descriptionAXPhotoProtocol
    func photoViewController(_ photoViewController: AXPhotoViewController,
                             retryDownloadFor photo: AXPhotoProtocol)

    /// Set scale and size
    /// - Parameter photoViewController: AXPhotoViewController
    /// - Parameter index: Int
    /// - Parameter minimumZoomScale: CGFloat
    /// - Parameter imageSize: CGSize
    func photoViewController(_ photoViewController: AXPhotoViewController,
                             maximumZoomScaleForPhotoAt index: Int,
                             minimumZoomScale: CGFloat,
                             imageSize: CGSize) -> CGFloat
}
