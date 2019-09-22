// @copyright Trollwerks Inc.

// migrated from https://github.com/alexhillc/AXPhotoViewer

//
//  AXPagingConfig.swift
//  AXPhotoViewer
//
//  Created by Alex Hill on 6/1/17.
//  Copyright © 2017 Alex Hill. All rights reserved.
//

private let DefaultHorizontalSpacing: CGFloat = 20

final class AXPagingConfig: NSObject {

    /// Navigation configuration to be applied to the internal pager of the `PhotosViewController`.
    fileprivate(set) var navigationOrientation: UIPageViewController.NavigationOrientation

    /// Space between photos, measured in points.
    /// Applied to the internal pager of the `PhotosViewController` at initialization.
    fileprivate(set) var interPhotoSpacing: CGFloat

    /// The loading view class which will be instantiated instead of the default `AXLoadingView`.
    fileprivate(set) var loadingViewClass: AXLoadingViewProtocol.Type = AXLoadingView.self

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

    override convenience init() {
        self.init(navigationOrientation: .horizontal,
                  interPhotoSpacing: DefaultHorizontalSpacing,
                  loadingViewClass: nil)
    }

    convenience init(navigationOrientation: UIPageViewController.NavigationOrientation) {
        self.init(navigationOrientation: navigationOrientation,
                  interPhotoSpacing: DefaultHorizontalSpacing,
                  loadingViewClass: nil)
    }

    convenience init(interPhotoSpacing: CGFloat) {
        self.init(navigationOrientation: .horizontal, interPhotoSpacing: interPhotoSpacing, loadingViewClass: nil)
    }

    convenience init(loadingViewClass: AXLoadingViewProtocol.Type?) {
        self.init(navigationOrientation: .horizontal,
                  interPhotoSpacing: DefaultHorizontalSpacing,
                  loadingViewClass: loadingViewClass)
    }
}
