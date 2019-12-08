// @copyright Trollwerks Inc.

// migrated from https://github.com/alexhillc/AXPhotoViewer

//
//  AXNetworkIntegrationProtocol.swift
//  AXPhotoViewer
//
//  Created by Alex Hill on 5/20/17.
//  Copyright © 2017 Alex Hill. All rights reserved.
//

/// AXNetworkIntegrationProtocol
protocol AXNetworkIntegrationProtocol: AnyObject, NSObjectProtocol {

    /// Delegate
    var delegate: AXNetworkIntegrationDelegate? { get set }

    /// This function should load a provided photo,
    /// calling all necessary `AXNetworkIntegrationDelegate` delegate methods.
    /// - Parameter photo: The photo to load.
    func loadPhoto(_ photo: AXPhotoProtocol)

    /// This function should cancel the load (if possible) for the provided photo.
    /// - Parameter photo: The photo load to cancel.
    func cancelLoad(for photo: AXPhotoProtocol)

    /// This function should cancel all current photo loads.
    func cancelAllLoads()
}

/// AXNetworkIntegrationDelegate
protocol AXNetworkIntegrationDelegate: AnyObject, NSObjectProtocol {

    /// Called when a `AXPhoto` successfully finishes loading.
    /// - Parameters:
    ///   - networkIntegration: The `NetworkIntegration` that was performing the load.
    ///   - photo: The related `Photo`.
    /// - Note: This method is expected to be called on a background thread.
    /// Be mindful of this when retrieving items from a memory cache.
    func networkIntegration(_ networkIntegration: AXNetworkIntegrationProtocol,
                            loadDidFinishWith photo: AXPhotoProtocol)

    /// Called when a `AXPhoto` fails to load.
    /// - Parameters:
    ///   - networkIntegration: The `NetworkIntegration` that was performing the load.
    ///   - error: The error that the load failed with.
    ///   - photo: The related `Photo`.
    /// - Note: This method is expected to be called on a background thread.
    func networkIntegration(_ networkIntegration: AXNetworkIntegrationProtocol,
                            loadDidFailWith error: Error,
                            for photo: AXPhotoProtocol)

    /// Called when a `AXPhoto`'s loading progress is updated.
    /// - Parameters:
    ///   - networkIntegration: The `NetworkIntegration` that is performing the load.
    ///   - progress: The progress of the `AXPhoto` load represented as a percentage. Exists on a scale from 0..1. 
    ///   - photo: The related `AXPhoto`.
    /// - Note: This method is expected to be called on a background thread.
    func networkIntegration(_ networkIntegration: AXNetworkIntegrationProtocol,
                            didUpdateLoadingProgress progress: CGFloat,
                            for photo: AXPhotoProtocol)
}
