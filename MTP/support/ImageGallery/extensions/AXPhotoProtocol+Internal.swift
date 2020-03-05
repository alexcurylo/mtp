// @copyright Trollwerks Inc.

// migrated from https://github.com/alexhillc/AXPhotoViewer

//
//  AXPhoto+Internal.swift
//  AXPhotoViewer
//
//  Created by Alex Hill on 5/27/17.
//  Copyright © 2017 Alex Hill. All rights reserved.
//

/// Loading state
enum AXPhotoLoadingState {

    /// Not loaded
    case notLoaded
    /// Loading
    case loading
    /// Loaded
    case loaded
    /// Loading cancelled
    case loadingCancelled
    /// Loading failed
    case loadingFailed
}

private enum AssociationKeys {

    static var error: UInt8 = 0
    static var progress: UInt8 = 0
    static var loadingState: UInt8 = 0
}

// MARK: - Internal AXPhotoProtocol extension to be used by the framework.

extension AXPhotoProtocol {

    /// Associated Object: Progress
    var ax_progress: CGFloat {
        get {
            objc_getAssociatedObject(self, &AssociationKeys.progress) as? CGFloat ?? 0
        }
        set(value) {
            objc_setAssociatedObject(self, &AssociationKeys.progress, value, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    /// Associated Object: Error
    var ax_error: Error? {
        get {
            objc_getAssociatedObject(self, &AssociationKeys.error) as? Error
        }
        set(value) {
            objc_setAssociatedObject(self, &AssociationKeys.error, value, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    /// Associated Object: Loading State
    var ax_loadingState: AXPhotoLoadingState {
        get {
            objc_getAssociatedObject(self, &AssociationKeys.loadingState) as? AXPhotoLoadingState ?? .notLoaded
        }
        set(value) {
            objc_setAssociatedObject(self, &AssociationKeys.loadingState, value, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    /// Has URL
    var ax_isReducible: Bool {
        self.url != nil
    }
}
