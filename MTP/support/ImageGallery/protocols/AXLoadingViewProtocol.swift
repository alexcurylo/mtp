// @copyright Trollwerks Inc.

// migrated from https://github.com/alexhillc/AXPhotoViewer

//
//  AXLoadingViewProtocol.swift
//  AXPhotoViewer
//
//  Created by Alex Hill on 5/28/17.
//  Copyright © 2017 Alex Hill. All rights reserved.
//

/// AXLoadingViewProtocol
protocol AXLoadingViewProtocol: NSObjectProtocol {

    /// Called by the AXPhotoViewController when progress of the image download should be shown to the user.
    ///
    /// - Parameter initialProgress: The current progress of the image download. Exists on a scale from 0..1.
    func startLoading(initialProgress: CGFloat)

    /// Called by the AXPhotoViewController when progress of the image download should be hidden.
    /// This usually happens when the containing view controller is moved offscreen.
    ///
    func stopLoading()

    /// Called by the AXPhotoViewController when the progress of an image download is updated.
    /// The implementation of this method should reflect the progress of the downloaded image.
    ///
    /// - Parameter progress: The progress complete of the image download. Exists on a scale from 0..1.
    func updateProgress(_ progress: CGFloat)

    /// Called by the AXPhotoViewController when an image download fails.
    /// The implementation of this method should display an error to the user,
    /// and optionally, offer to retry the image download.
    ///
    /// - Parameters:
    ///   - error: The error that the image download failed with.
    ///   - retryHandler: Call this handler to retry the image download.
    func showError(_ error: Error, retryHandler: @escaping () -> Void)

    /// Called by the AXPhotoViewController when an image download is being retried, or the container decides to stop
    /// displaying an error to the user.
    ///
    func removeError()

    /// The `AXPhotosViewController` uses this method to correctly size the loading view for a constrained width.
    ///
    /// - Parameter size: The constrained size. Use the width of this value to layout subviews.
    /// - Returns: A size that fits all subviews inside a constrained width.
    func sizeThatFits(_ size: CGSize) -> CGSize
}
