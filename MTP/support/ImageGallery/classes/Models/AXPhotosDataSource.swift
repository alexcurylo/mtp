// @copyright Trollwerks Inc.

// migrated from https://github.com/alexhillc/AXPhotoViewer

//
//  AXPhotosDataSource.swift
//  AXPhotoViewer
//
//  Created by Alex Hill on 6/1/17.
//  Copyright © 2017 Alex Hill. All rights reserved.
//

/// AXPhotosDataSource
class AXPhotosDataSource: NSObject {

    /// AXPhotosPrefetchBehavior
    enum AXPhotosPrefetchBehavior: Int {
        /// conservative
        case conservative = 0
        /// regular
        case regular = 2
        /// aggressive
        case aggressive = 4
    }

    /// The fetching behavior that the `PhotosViewController` should take action with.
    /// `conservative`, only the current photo will be loaded.
    /// `regular` (default), the current photo, the previous photo, and the next photo will be loaded.
    /// `aggressive`, the current photo, the previous two photos, and the next two photos will be loaded.
    fileprivate(set) var prefetchBehavior: AXPhotosPrefetchBehavior

    /// The photos to display in the PhotosViewController.
    fileprivate var photos: [AXPhotoProtocol]

    /// The initial photo index to display upon presentation.
    fileprivate(set) var initialPhotoIndex: Int = 0

    // MARK: - Initialization

    /// :nodoc:
    init(photos: [AXPhotoProtocol],
         initialPhotoIndex: Int,
         prefetchBehavior: AXPhotosPrefetchBehavior) {
        self.photos = photos
        self.prefetchBehavior = prefetchBehavior

        if !photos.isEmpty {
            assert(photos.count > initialPhotoIndex, "Invalid initial photo index provided.")
            self.initialPhotoIndex = initialPhotoIndex
        }

        super.init()
    }

    /// :nodoc:
    override convenience init() {
        self.init(photos: [], initialPhotoIndex: 0, prefetchBehavior: .regular)
    }

    /// :nodoc:
    convenience init(photos: [AXPhotoProtocol]) {
        self.init(photos: photos, initialPhotoIndex: 0, prefetchBehavior: .regular)
    }

    /// :nodoc:
    convenience init(photos: [AXPhotoProtocol], initialPhotoIndex: Int) {
        self.init(photos: photos, initialPhotoIndex: initialPhotoIndex, prefetchBehavior: .regular)
    }

    // MARK: - DataSource

    /// Number of photos
    var numberOfPhotos: Int {
        self.photos.count
    }

    /// Photo at index
    /// - Parameter index: Index
    func photo(at index: Int) -> AXPhotoProtocol? {
        if index < self.photos.count {
            return self.photos[index]
        }

        return nil
    }
}
