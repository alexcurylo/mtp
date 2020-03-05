// @copyright Trollwerks Inc.

// migrated from https://github.com/alexhillc/AXPhotoViewer

//
//  AXPagingConfig.swift
//  AXPhotoViewer
//
//  Created by Alex Hill on 6/1/17.
//  Copyright © 2017 Alex Hill. All rights reserved.
//

private let defaultHorizontalSpacing: CGFloat = 20

/// AXPagingConfig
final class AXPagingConfig: NSObject {

    /// Navigation configuration to be applied to the internal pager of the `PhotosViewController`.
    fileprivate(set) var navigationOrientation: UIPageViewController.NavigationOrientation

    /// Space between photos, measured in points.
    /// Applied to the internal pager of the `PhotosViewController` at initialization.
    fileprivate(set) var interPhotoSpacing: CGFloat

    /// The loading view class which will be instantiated instead of the default `AXLoadingView`.
    fileprivate(set) var loadingViewClass: AXLoadingViewProtocol.Type = AXLoadingView.self

    /// :nodoc:
    init(navigationOrientation: UIPageViewController.NavigationOrientation,
         interPhotoSpacing: CGFloat,
         loadingViewClass: AXLoadingViewProtocol.Type? = nil) {

        self.navigationOrientation = navigationOrientation
        self.interPhotoSpacing = interPhotoSpacing

        super.init()

        if let loadingViewClass = loadingViewClass {
            guard loadingViewClass is UIView.Type else {
                assertionFailure("`loadingViewClass` must be a UIView.")
                return
            }

            self.loadingViewClass = loadingViewClass
        }
    }

    /// :nodoc:
    override convenience init() {
        self.init(navigationOrientation: .horizontal,
                  interPhotoSpacing: defaultHorizontalSpacing,
                  loadingViewClass: nil)
    }

    /// :nodoc:
    convenience init(navigationOrientation: UIPageViewController.NavigationOrientation) {
        self.init(navigationOrientation: navigationOrientation,
                  interPhotoSpacing: defaultHorizontalSpacing,
                  loadingViewClass: nil)
    }

    /// :nodoc:
    convenience init(interPhotoSpacing: CGFloat) {
        self.init(navigationOrientation: .horizontal, interPhotoSpacing: interPhotoSpacing, loadingViewClass: nil)
    }

    /// :nodoc:
    convenience init(loadingViewClass: AXLoadingViewProtocol.Type?) {
        self.init(navigationOrientation: .horizontal,
                  interPhotoSpacing: defaultHorizontalSpacing,
                  loadingViewClass: loadingViewClass)
    }
}
