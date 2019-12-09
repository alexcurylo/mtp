// @copyright Trollwerks Inc.

// migrated from https://github.com/alexhillc/AXPhotoViewer

//
//  AXPhotosViewController.swift
//  AXPhotoViewer
//
//  Created by Alex Hill on 5/7/17.
//  Copyright © 2017 Alex Hill. All rights reserved.
//

import MobileCoreServices
import UIKit

// swiftlint:disable file_length

/// AXPhotosViewController
final class AXPhotosViewController: UIViewController,
                                    // swiftlint:disable:previous type_body_length
                                    UIPageViewControllerDelegate,
                                    UIPageViewControllerDataSource,
                                    UIGestureRecognizerDelegate,
                                    AXPhotoViewControllerDelegate,
                                    AXNetworkIntegrationDelegate,
                                    AXPhotosTransitionControllerDelegate {

    /// The close bar button item that is initially set in the overlay's toolbar.
    /// Any 'target' or 'action' provided to this button will be overwritten.
    /// Overriding this is purely for customizing the look and feel of the button.
    /// Alternatively, you may create your own `UIBarButtonItem`s
    /// and directly set them _and_ their actions on the `overlayView` property.
    private var closeBarButtonItem: UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .stop, target: nil, action: nil)
    }

    /// The action bar button item that is initially set in the overlay's toolbar.
    /// Any 'target' or 'action' provided to this button will be overwritten.
    /// Overriding this is purely for customizing the look and feel of the button.
    /// Alternatively, you may create your own `UIBarButtonItem`s
    /// and directly set them _and_ their actions on the `overlayView` property.
    private var actionBarButtonItem: UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)
    }

    /// The internal tap gesture recognizer that is used to initiate and pan interactive dismissals.
    private var panGestureRecognizer: UIPanGestureRecognizer?

    private var ax_prefersStatusBarHidden: Bool = false
    /// :nodoc:
    override var prefersStatusBarHidden: Bool {
        return super.prefersStatusBarHidden || self.ax_prefersStatusBarHidden
    }
    /// :nodoc:
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private weak var delegate: AXPhotosViewControllerDelegate?

    /// The underlying `OverlayView` that is used for displaying photo captions, titles, and actions.
    let overlayView = AXOverlayView()

    /// The photos to display in the PhotosViewController.
    var dataSource = AXPhotosDataSource() {
        didSet {
            // this can occur during `commonInit(dataSource:pagingConfig:transitionInfo:networkIntegration:)`
            // if that's the case, this logic will be applied in `viewDidLoad()`
            if self.pageViewController == nil || self.networkIntegration == nil {
                return
            }

            self.pageViewController.dataSource = (self.dataSource.numberOfPhotos > 1) ? self : nil
            self.networkIntegration.cancelAllLoads()
            self.configurePageViewController()
        }
    }

    /// The configuration object applied to the internal pager at initialization.
    fileprivate(set) var pagingConfig = AXPagingConfig()

    /// The `AXTransitionInfo` passed in at initialization. Defines functionality for the presentation and dismissal
    /// of the `PhotosViewController`.
    fileprivate(set) var transitionInfo = AXTransitionInfo()

    /// The `NetworkIntegration` passed in at initialization. TFetches images asynchronously from a cache or URL.
    /// - Initialized by the end of `commonInit(dataSource:pagingConfig:transitionInfo:networkIntegration:)`.
    fileprivate(set) var networkIntegration: AXNetworkIntegrationProtocol!
    // swiftlint:disable:previous implicitly_unwrapped_optional

    /// The underlying UIPageViewController that is used for swiping horizontally and vertically.
    /// - Important: `AXPhotosViewController` is this page view controller's
    ///              `UIPageViewControllerDelegate`, `UIPageViewControllerDataSource`.
    ///              Changing these values will result in breakage.
    /// - Note: Initialized by the end of `commonInit(dataSource:pagingConfig:transitionInfo:networkIntegration:)`.
    fileprivate(set) var pageViewController: UIPageViewController!
    // swiftlint:disable:previous implicitly_unwrapped_optional

    /// The internal tap gesture recognizer that is used to hide/show the overlay interface.
    let singleTapGestureRecognizer = UITapGestureRecognizer()

    /// The view controller containing the photo currently being shown.
    var currentPhotoViewController: AXPhotoViewController? {
        // swiftlint:disable:next trailing_closure
        orderedViewControllers.first(where: { $0.pageIndex == currentPhotoIndex })
    }

    /// The index of the photo currently being shown.
    private(set) var currentPhotoIndex: Int = 0 {
        didSet {
            updateOverlay(for: currentPhotoIndex)
        }
    }

    // MARK: - Private/internal variables
    private enum SwipeDirection {
        case none, left, right
    }

    /// If the `PhotosViewController` is being presented in a fullscreen container,
    /// this value is set when the `PhotosViewController`
    /// is added to a parent view controller to allow `PhotosViewController` to be its transitioning delegate.
    private weak var containerViewController: UIViewController? {
        didSet {
            oldValue?.transitioningDelegate = nil

            if let containerViewController = self.containerViewController {
                containerViewController.transitioningDelegate = self.transitionController
                self.transitioningDelegate = nil
            } else {
                self.transitioningDelegate = self.transitionController
            }
        }
    }

    private var isSizeTransitioning = false
    private var isFirstAppearance = true

    private var orderedViewControllers = [AXPhotoViewController]()
    private var recycledViewControllers = [AXPhotoViewController]()

    private var transitionController: AXPhotosTransitionController?
    private let notificationCenter = NotificationCenter()

    // MARK: - Initialization

    /// :nodoc:
    init() {
        super.init(nibName: nil, bundle: nil)
        self.commonInit()
    }

    /// :nodoc:
    init(dataSource: AXPhotosDataSource?) {
        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: dataSource)
    }

    /// :nodoc:
    init(dataSource: AXPhotosDataSource?,
         pagingConfig: AXPagingConfig?) {

        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: dataSource,
                        pagingConfig: pagingConfig)
    }

    /// :nodoc:
    init(pagingConfig: AXPagingConfig?,
         transitionInfo: AXTransitionInfo?) {

        super.init(nibName: nil, bundle: nil)
        self.commonInit(pagingConfig: pagingConfig,
                        transitionInfo: transitionInfo)
    }

    /// :nodoc:
    init(dataSource: AXPhotosDataSource?,
         pagingConfig: AXPagingConfig?,
         transitionInfo: AXTransitionInfo?) {

        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: dataSource,
                        pagingConfig: pagingConfig,
                        transitionInfo: transitionInfo)
    }

    /// :nodoc:
    init(networkIntegration: AXNetworkIntegrationProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.commonInit(networkIntegration: networkIntegration)
    }

    /// :nodoc:
    init(dataSource: AXPhotosDataSource?,
         networkIntegration: AXNetworkIntegrationProtocol) {

        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: dataSource,
                        networkIntegration: networkIntegration)
    }

    /// :nodoc:
    init(dataSource: AXPhotosDataSource?,
         pagingConfig: AXPagingConfig?,
         networkIntegration: AXNetworkIntegrationProtocol) {

        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: dataSource,
                        pagingConfig: pagingConfig,
                        networkIntegration: networkIntegration)
    }

    /// :nodoc:
    init(pagingConfig: AXPagingConfig?,
         transitionInfo: AXTransitionInfo?,
         networkIntegration: AXNetworkIntegrationProtocol) {

        super.init(nibName: nil, bundle: nil)
        self.commonInit(pagingConfig: pagingConfig,
                        transitionInfo: transitionInfo,
                        networkIntegration: networkIntegration)
    }

    /// :nodoc:
    init(dataSource: AXPhotosDataSource?,
         pagingConfig: AXPagingConfig?,
         transitionInfo: AXTransitionInfo?,
         networkIntegration: AXNetworkIntegrationProtocol) {

        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: dataSource,
                        pagingConfig: pagingConfig,
                        transitionInfo: transitionInfo,
                        networkIntegration: networkIntegration)
    }

    /// :nodoc:
    init(from previewingPhotosViewController: AXPreviewingPhotosViewController) {
        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: previewingPhotosViewController.dataSource,
                        networkIntegration: previewingPhotosViewController.networkIntegration)
        loadViewIfNeeded()
    }

    /// :nodoc:
    init(from previewingPhotosViewController: AXPreviewingPhotosViewController,
         pagingConfig: AXPagingConfig?) {

        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: previewingPhotosViewController.dataSource,
                        pagingConfig: pagingConfig,
                        networkIntegration: previewingPhotosViewController.networkIntegration)
        loadViewIfNeeded()
    }

    /// :nodoc:
    init(from previewingPhotosViewController: AXPreviewingPhotosViewController,
         pagingConfig: AXPagingConfig?,
         transitionInfo: AXTransitionInfo?) {

        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: previewingPhotosViewController.dataSource,
                        pagingConfig: pagingConfig,
                        transitionInfo: transitionInfo,
                        networkIntegration: previewingPhotosViewController.networkIntegration)
        loadViewIfNeeded()
    }

    /// :nodoc:
    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    /// init to be used internally by the library
    @nonobjc init(dataSource: AXPhotosDataSource? = nil,
                  pagingConfig: AXPagingConfig? = nil,
                  transitionInfo: AXTransitionInfo? = nil,
                  networkIntegration: AXNetworkIntegrationProtocol? = nil) {

        super.init(nibName: nil, bundle: nil)
        self.commonInit(dataSource: dataSource,
                        pagingConfig: pagingConfig,
                        transitionInfo: transitionInfo,
                        networkIntegration: networkIntegration)
    }

    /// :nodoc:
    private func commonInit(dataSource ds: AXPhotosDataSource? = nil,
                            pagingConfig pc: AXPagingConfig? = nil,
                            transitionInfo ti: AXTransitionInfo? = nil,
                            networkIntegration ni: AXNetworkIntegrationProtocol? = nil) {
        if let ds = ds { dataSource = ds }
        if let pc = pc { pagingConfig = pc }
        if let ti = ti {
            transitionInfo = ti
            if ti.interactiveDismissalEnabled {
                panGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                              action: #selector(didPanWithGestureRecognizer(_:)))
                panGestureRecognizer?.maximumNumberOfTouches = 1
                panGestureRecognizer?.delegate = self
            }
        }

        if ni == nil {
            networkIntegration = NukeIntegration()
        } else {
            networkIntegration = ni
        }
        networkIntegration.delegate = self

        pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                  navigationOrientation: pagingConfig.navigationOrientation,
                                                  options: [.interPageSpacing: pagingConfig.interPhotoSpacing])
        pageViewController.delegate = self
        pageViewController.dataSource = (dataSource.numberOfPhotos > 1) ? self : nil
        pageViewController.scrollView.addContentOffsetObserver(self)
        configurePageViewController()

        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.addTarget(self, action: #selector(didSingleTapWithGestureRecognizer(_:)))

        overlayView.tintColor = .white
        overlayView.setShowInterface(false, animated: false)

        let closeBarButtonItem = self.closeBarButtonItem
        closeBarButtonItem.target = self
        closeBarButtonItem.action = #selector(closeAction(_:))
        self.overlayView.leftBarButtonItem = closeBarButtonItem

        let actionBarButtonItem = self.actionBarButtonItem
        actionBarButtonItem.target = self
        actionBarButtonItem.action = #selector(shareAction(_:))
        self.overlayView.rightBarButtonItem = actionBarButtonItem
    }

    /// :nodoc:
    deinit {
        self.recycledViewControllers.removeLifeycleObserver(self)
        self.orderedViewControllers.removeLifeycleObserver(self)
        self.pageViewController.scrollView.removeContentOffsetObserver(self)
    }

    /// :nodoc:
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        self.recycledViewControllers.removeLifeycleObserver(self)
        self.recycledViewControllers.removeAll()

        self.reduceMemoryForPhotos(at: self.currentPhotoIndex)
    }

    /// :nodoc:
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .black

        self.transitionController = AXPhotosTransitionController(transitionInfo: self.transitionInfo)
        self.transitionController?.delegate = self

        #if os(iOS)
        if let panGestureRecognizer = self.panGestureRecognizer {
            self.pageViewController.view.addGestureRecognizer(panGestureRecognizer)
        }
        #endif

        if let containerViewController = self.containerViewController {
            containerViewController.transitioningDelegate = self.transitionController
        } else {
            self.transitioningDelegate = self.transitionController
        }

        if self.pageViewController.view.superview == nil {
            self.pageViewController.view.addGestureRecognizer(self.singleTapGestureRecognizer)

            self.addChild(self.pageViewController)
            self.view.addSubview(self.pageViewController.view)
            self.pageViewController.didMove(toParent: self)
        }

        if self.overlayView.superview == nil {
            self.view.addSubview(self.overlayView)
        }
    }

    /// :nodoc:
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if self.isFirstAppearance {
            let visible: Bool = true
            // swiftlint:disable:next trailing_closure
            self.overlayView.setShowInterface(visible, animated: true, alongside: { [weak self] in
                guard let self = self else { return }

                self.updateStatusBarAppearance(show: visible)
                self.overlayView(self.overlayView, visibilityWillChange: visible)
            })
            self.isFirstAppearance = false
        }
    }

    /// :nodoc:
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        self.isSizeTransitioning = true
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            self?.isSizeTransitioning = false
        }
    }

    /// :nodoc:
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.pageViewController.view.frame = self.view.bounds
        self.overlayView.frame = self.view.bounds
        self.overlayView.performAfterShowInterfaceCompletion { [weak self] in
            // if being dismissed, let's just return early rather than update insets
            guard let self = self, !self.isBeingDismissed else { return }
            self.updateOverlayInsets()
        }
    }

    /// :nodoc:
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)

        if parent is UINavigationController {
            assertionFailure("Do not embed `PhotosViewController` in a navigation stack.")
            return
        }

        self.containerViewController = parent
    }

    // MARK: - PhotosViewControllerTransitionAnimatorDelegate

    /// :nodoc:
    func transitionController(_ transitionController: AXPhotosTransitionController,
                              didCompletePresentationWith transitionView: UIImageView) {
        guard let photo = self.dataSource.photo(at: self.currentPhotoIndex) else { return }

        self.notificationCenter.post(
            name: .photoImageUpdate,
            object: photo,
            userInfo: nil
        )
    }

    /// :nodoc:
    func transitionController(_ transitionController: AXPhotosTransitionController,
                              didCompleteDismissalWith transitionView: UIImageView) {
        // empty impl
    }

    /// :nodoc:
    func transitionControllerDidCancelDismissal(_ transitionController: AXPhotosTransitionController) {
        // empty impl
    }

    // MARK: - Dismissal

    /// :nodoc:
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if self.presentedViewController != nil {
            super.dismiss(animated: flag, completion: completion)
            return
        }

        self.delegate?.photosViewControllerWillDismiss(self)
        super.dismiss(animated: flag) { [weak self] in
            guard let self = self else { return }

            let canceled = (self.view.window != nil)

            if canceled {
                self.transitionController?.forceInteractiveDismissal = false
                #if os(iOS)
                self.panGestureRecognizer?.isEnabled = true
                #endif
            } else {
                self.delegate?.photosViewControllerDidDismiss(self)
            }

            completion?()
        }
    }

    // MARK: - Navigation

    /// Convenience method to programmatically navigate to a photo
    /// - Parameters:
    ///   - photoIndex: The index of the photo to navigate to
    ///   - animated: Whether or not to animate the transition
    func navigateToPhotoIndex(_ photoIndex: Int, animated: Bool) {
        if photoIndex < 0 || photoIndex > (self.dataSource.numberOfPhotos - 1) {
            return
        }

        guard let photoViewController = self.makePhotoViewController(for: photoIndex) else { return }

        let forward = (photoIndex > self.currentPhotoIndex)
        self.pageViewController.setViewControllers([photoViewController],
                                                   direction: forward ? .forward : .reverse,
                                                   animated: animated,
                                                   completion: nil)
        self.loadPhotos(at: photoIndex)
        self.currentPhotoIndex = photoIndex
    }

    // MARK: - Page VC Configuration

    private func configurePageViewController() {
        func configure(with viewController: UIViewController, pageIndex: Int) {
            pageViewController.setViewControllers([viewController],
                                                  direction: .forward,
                                                  animated: false,
                                                  completion: nil)
            currentPhotoIndex = pageIndex

            overlayView.titleView?.tweenBetweenLowIndex(pageIndex, highIndex: pageIndex + 1, percent: 0)
        }

        guard let photoViewController = self.makePhotoViewController(for: self.dataSource.initialPhotoIndex) else {
            configure(with: UIViewController(), pageIndex: 0)
            return
        }

        configure(with: photoViewController, pageIndex: photoViewController.pageIndex)
        self.loadPhotos(at: self.dataSource.initialPhotoIndex)
    }

    // MARK: - Overlay

    private func updateOverlay(for photoIndex: Int) {
        guard let photo = dataSource.photo(at: photoIndex) else { return }

        willUpdate(overlayView: overlayView,
                   for: photo,
                   at: photoIndex,
                   totalNumberOfPhotos: dataSource.numberOfPhotos)

        if dataSource.numberOfPhotos > 1 {
            overlayView.internalTitle = L.indexCount(photoIndex + 1,
                                                     dataSource.numberOfPhotos)
        } else {
            overlayView.internalTitle = nil
        }

        overlayView.updateCaptionView(photo: photo)
    }

    private func updateOverlayInsets() {
        overlayView.contentInset = view.safeAreaInsets
    }

    // MARK: - Gesture recognizers

    @objc private func didSingleTapWithGestureRecognizer(_ sender: UITapGestureRecognizer) {
        let show = (self.overlayView.alpha == 0)
        // swiftlint:disable:next trailing_closure
        self.overlayView.setShowInterface(show, animated: true, alongside: { [weak self] in
            guard let self = self else { return }

            self.updateStatusBarAppearance(show: show)
            self.overlayView(self.overlayView, visibilityWillChange: show)
        })
    }

    @objc private func didPanWithGestureRecognizer(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            self.transitionController?.forceInteractiveDismissal = true
            self.dismiss(animated: true, completion: nil)
        }

        self.transitionController?.didPanWithGestureRecognizer(sender, in: self.containerViewController ?? self)
    }

    private func updateStatusBarAppearance(show: Bool) {
        self.ax_prefersStatusBarHidden = !show
        self.setNeedsStatusBarAppearanceUpdate()
        if show {
            UIView.performWithoutAnimation { [weak self] in
                self?.updateOverlayInsets()
                self?.overlayView.setNeedsLayout()
                self?.overlayView.layoutIfNeeded()
            }
        }
    }

    // MARK: - Default bar button actions

    /// Share
    /// - Parameter barButtonItem: UIBarButtonItem
    @objc func shareAction(_ barButtonItem: UIBarButtonItem) {
        guard let photo = self.dataSource.photo(at: self.currentPhotoIndex) else { return }

        if self.handleActionButtonTapped(photo: photo) {
            return
        }

        var anyRepresentation: Any?
        if let imageData = photo.imageData {
            anyRepresentation = imageData
        } else if let image = photo.image {
            anyRepresentation = image
        }

        guard let uAnyRepresentation = anyRepresentation else { return }

        let activityViewController = UIActivityViewController(activityItems: [uAnyRepresentation],
                                                              applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { [weak self] activityType, completed, _, _ in
            guard let self = self else { return }

            if completed, let activityType = activityType {
                self.actionCompleted(activityType: activityType, for: photo)
            }
        }

        activityViewController.popoverPresentationController?.barButtonItem = barButtonItem
        self.present(activityViewController, animated: true)
    }

    /// Close
    /// - Parameter sender: UIBarButtonItem
    @objc func closeAction(_ sender: UIBarButtonItem) {
        self.transitionController?.forceInteractiveDismissal = false
        self.dismiss(animated: true)
    }

    // MARK: - Loading helpers

    private func loadPhotos(at index: Int) {
        let numberOfPhotosToLoad = self.dataSource.prefetchBehavior.rawValue
        let startIndex = (((index - (numberOfPhotosToLoad / 2)) >= 0) ? (index - (numberOfPhotosToLoad / 2)) : 0)
        let indexes = startIndex...(startIndex + numberOfPhotosToLoad)

        for index in indexes {
            guard let photo = self.dataSource.photo(at: index) else { return }

            if photo.ax_loadingState == .notLoaded || photo.ax_loadingState == .loadingCancelled {
                photo.ax_loadingState = .loading
                self.networkIntegration.loadPhoto(photo)
            }
        }
    }

    private func reduceMemoryForPhotos(at index: Int) {
        let numberOfPhotosToLoad = self.dataSource.prefetchBehavior.rawValue
        let areLower = index - (numberOfPhotosToLoad / 2) - 1 >= 0
        let lowerIndex = areLower ? index - (numberOfPhotosToLoad / 2) - 1 : NSNotFound
        let areUpper = index + (numberOfPhotosToLoad / 2) + 1 < self.dataSource.numberOfPhotos
        let upperIndex = areUpper ? index + (numberOfPhotosToLoad / 2) + 1 : NSNotFound

        weak var weakSelf = self
        func reduceMemory(for photo: AXPhotoProtocol) {
            guard let self = weakSelf else { return }

            if photo.ax_loadingState == .loading {
                self.networkIntegration.cancelLoad(for: photo)
                photo.ax_loadingState = .loadingCancelled
            } else if photo.ax_loadingState == .loaded && photo.ax_isReducible {
                photo.imageData = nil
                photo.image = nil
                photo.ax_loadingState = .notLoaded
            }
        }

        if lowerIndex != NSNotFound, let photo = self.dataSource.photo(at: lowerIndex) {
            reduceMemory(for: photo)
        }

        if upperIndex != NSNotFound, let photo = self.dataSource.photo(at: upperIndex) {
            reduceMemory(for: photo)
        }
    }

    // MARK: - Reuse / Factory

    private func makePhotoViewController(for pageIndex: Int) -> AXPhotoViewController? {
        guard let photo = dataSource.photo(at: pageIndex) else { return nil }

        var photoViewController: AXPhotoViewController

        if !recycledViewControllers.isEmpty {
            photoViewController = recycledViewControllers.removeLast()
            photoViewController.prepareForReuse()
        } else {
            guard let loadingView = makeLoadingView(for: pageIndex) else { return nil }

            photoViewController = AXPhotoViewController(loadingView: loadingView,
                                                        notificationCenter: notificationCenter)
            photoViewController.addLifecycleObserver(self)
            photoViewController.delegate = self

            singleTapGestureRecognizer.require(toFail: photoViewController.zoomingImageView.doubleTapGestureRecognizer)
        }

        photoViewController.pageIndex = pageIndex
        photoViewController.applyPhoto(photo)

        // swiftlint:disable:next trailing_closure
        let insertionIndex = orderedViewControllers.insertionIndex(of: photoViewController,
                                                                   isOrderedBefore: { $0.pageIndex < $1.pageIndex })
        orderedViewControllers.insert(photoViewController, at: insertionIndex.index)

        return photoViewController
    }

    private func makeLoadingView(for pageIndex: Int) -> AXLoadingViewProtocol? {
        guard let loadingViewType = self.pagingConfig.loadingViewClass as? UIView.Type else {
            assertionFailure("`loadingViewType` must be a UIView.")
            return nil
        }

        return loadingViewType.init() as? AXLoadingViewProtocol
    }

    // MARK: - Recycling

    private func recyclePhotoViewController(_ photoViewController: AXPhotoViewController) {
        if self.recycledViewControllers.contains(photoViewController) {
            return
        }

        if let index = self.orderedViewControllers.firstIndex(of: photoViewController) {
            self.orderedViewControllers.remove(at: index)
        }

        self.recycledViewControllers.append(photoViewController)
    }

    // MARK: - KVO

    /// KVO observation
    /// - Parameter keyPath: Key path
    /// - Parameter object: Object observed
    /// - Parameter change: Change
    /// - Parameter context: Context
    override func observeValue(forKeyPath keyPath: String?,
                               // swiftlint:disable:previous block_based_kvo
                               of object: Any?,
                               // swiftlint:disable:next discouraged_optional_collection
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        if context == &PhotoViewControllerLifecycleContext {
            self.lifecycleContextDidUpdate(object: object, change: change)
        } else if context == &PhotoViewControllerContentOffsetContext {
            self.contentOffsetContextDidUpdate(object: object, change: change)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    private func lifecycleContextDidUpdate(object: Any?,
                                           // swiftlint:disable:next discouraged_optional_collection
                                           change: [NSKeyValueChangeKey: Any]?) {
        guard let photoViewController = object as? AXPhotoViewController else { return }

        if change?[.newKey] is NSNull {
            self.recyclePhotoViewController(photoViewController)
        }
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private func contentOffsetContextDidUpdate(object: Any?,
                                               // swiftlint:disable:next discouraged_optional_collection
                                               change: [NSKeyValueChangeKey: Any]?) {
        guard let scrollView = object as? UIScrollView, !self.isSizeTransitioning else { return }

        var percent: CGFloat
        if self.pagingConfig.navigationOrientation == .horizontal {
            percent = (scrollView.contentOffset.x - scrollView.frame.size.width) / scrollView.frame.size.width
        } else {
            percent = (scrollView.contentOffset.y - scrollView.frame.size.height) / scrollView.frame.size.height
        }

        var horizontalSwipeDirection: SwipeDirection = .none
        if percent > 0 {
            horizontalSwipeDirection = .right
        } else if percent < 0 {
            horizontalSwipeDirection = .left
        }

        let layoutDirection = UIView.userInterfaceLayoutDirection(for: pageViewController.view.semanticContentAttribute)
        let swipePercent: CGFloat
        if horizontalSwipeDirection == .left {
            if layoutDirection == .leftToRight {
                swipePercent = 1 - abs(percent)
            } else {
                swipePercent = abs(percent)
            }
        } else {
            if layoutDirection == .leftToRight {
                swipePercent = abs(percent)
            } else {
                swipePercent = 1 - abs(percent)
            }
        }

        var lowIndex: Int = NSNotFound
        var highIndex: Int = NSNotFound

        let viewControllers = self.computeVisibleViewControllers(in: scrollView)
        if horizontalSwipeDirection == .left {
            guard let viewController = viewControllers.first else { return }

            if viewControllers.count > 1 {
                lowIndex = viewController.pageIndex
                if lowIndex < self.dataSource.numberOfPhotos {
                    highIndex = lowIndex + 1
                }
            } else {
                highIndex = viewController.pageIndex
            }
        } else if horizontalSwipeDirection == .right {
            guard let viewController = viewControllers.last else { return }

            if viewControllers.count > 1 {
                highIndex = viewController.pageIndex
                if highIndex > 0 {
                    lowIndex = highIndex - 1
                }
            } else {
                lowIndex = viewController.pageIndex
            }
        }

        guard lowIndex != NSNotFound && highIndex != NSNotFound else {
            return
        }

        if swipePercent < 0.5 && self.currentPhotoIndex != lowIndex {
            self.currentPhotoIndex = lowIndex

            if let photo = self.dataSource.photo(at: lowIndex) {
                self.didNavigateTo(photo: photo, at: lowIndex)
            }
        } else if swipePercent > 0.5 && self.currentPhotoIndex != highIndex {
            self.currentPhotoIndex = highIndex

            if let photo = self.dataSource.photo(at: highIndex) {
                self.didNavigateTo(photo: photo, at: highIndex)
            }
        }

        overlayView.titleView?.tweenBetweenLowIndex(lowIndex, highIndex: highIndex, percent: percent)
    }

    private func computeVisibleViewControllers(in referenceView: UIScrollView) -> [AXPhotoViewController] {
        var visibleViewControllers = [AXPhotoViewController]()

        for viewController in orderedViewControllers {
            if viewController.view.frame.equalTo(.zero) {
                continue
            }

            let frame = viewController.view.frame
            let axis = pagingConfig.navigationOrientation
            let space = pagingConfig.interPhotoSpacing
            let origin = CGPoint(
                x: frame.origin.x - (axis == .horizontal ? (space / 2) : 0),
                y: frame.origin.y - (axis == .vertical ? (space / 2) : 0)
            )
            let size = CGSize(
                width: frame.size.width + ((axis == .horizontal) ? space : 0),
                height: frame.size.height + ((axis == .vertical) ? space : 0)
            )
            let conversionRect = CGRect(origin: origin, size: size)

            if let fromView = viewController.view.superview,
                referenceView.convert(conversionRect, from: fromView).intersects(referenceView.bounds) {
                visibleViewControllers.append(viewController)
            }
        }

        return visibleViewControllers
    }

    // MARK: - UIPageViewControllerDataSource

    /// :nodoc:
    func pageViewController(_ pageViewController: UIPageViewController,
                            willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let viewController = pendingViewControllers.first as? AXPhotoViewController else { return }
        loadPhotos(at: viewController.pageIndex)
    }

    /// :nodoc:
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard let viewController = pageViewController.viewControllers?.first as? AXPhotoViewController else { return }
        reduceMemoryForPhotos(at: viewController.pageIndex)
    }

    /// :nodoc:
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let uViewController = viewController as? AXPhotoViewController else {
            assertionFailure("Paging VC must be a subclass of `AXPhotoViewController`.")
            return nil
        }

        return self.pageViewController(pageViewController, viewControllerAt: uViewController.pageIndex - 1)
    }

    /// :nodoc:
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let uViewController = viewController as? AXPhotoViewController else {
            assertionFailure("Paging VC must be a subclass of `AXPhotoViewController`.")
            return nil
        }

        return self.pageViewController(pageViewController, viewControllerAt: uViewController.pageIndex + 1)
    }

    /// :nodoc:
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAt index: Int) -> UIViewController? {
        guard index >= 0 && self.dataSource.numberOfPhotos > index else { return nil }
        return self.makePhotoViewController(for: index)
    }

    // MARK: - AXPhotoViewControllerDelegate

    /// :nodoc:
    func photoViewController(_ photoViewController: AXPhotoViewController,
                             retryDownloadFor photo: AXPhotoProtocol) {
        guard photo.ax_loadingState != .loading && photo.ax_loadingState != .loaded else { return }
        photo.ax_error = nil
        photo.ax_loadingState = .loading
        self.networkIntegration.loadPhoto(photo)
    }

    /// :nodoc:
    func photoViewController(_ photoViewController: AXPhotoViewController,
                             maximumZoomScaleForPhotoAt index: Int,
                             minimumZoomScale: CGFloat,
                             imageSize: CGSize) -> CGFloat {
        guard let photo = self.dataSource.photo(at: index) else { return .leastNormalMagnitude }
        return self.maximumZoomScale(for: photo, minimumZoomScale: minimumZoomScale, imageSize: imageSize)
    }

    // MARK: - AXPhotosViewControllerDelegate calls

    /// Called when the `AXPhotosViewController` navigates to a new photo.
    /// This is defined as when the swipe percent between pages
    /// is greater than the threshold (>0.5).
    /// If you override this and fail to call super, the corresponding delegate method **will not be called!**
    /// - Parameters:
    ///   - photo: The `AXPhoto` that was navigated to.
    ///   - index: The `index` in the dataSource of the `AXPhoto` being transitioned to.
    func didNavigateTo(photo: AXPhotoProtocol, at index: Int) {
        self.delegate?.photosViewController(self, didNavigateTo: photo, at: index)
    }

    /// Called when the `AXPhotosViewController` is configuring its `OverlayView`
    /// for a new photo. This should be used to update the
    /// the overlay's title or any other overlay-specific properties.
    /// If you override this and fail to call super, the corresponding delegate method **will not be called!**
    /// - Parameters:
    ///   - overlayView: The `AXOverlayView` that is being updated.
    ///   - photo: The `AXPhoto` the overlay is being configured for.
    ///   - index: The index of the `AXPhoto` that the overlay is being configured for.
    ///   - totalNumberOfPhotos: The total number of photos in the current `dataSource`.
    func willUpdate(overlayView: AXOverlayView, for photo: AXPhotoProtocol, at index: Int, totalNumberOfPhotos: Int) {
        self.delegate?.photosViewController(self,
                                            willUpdate: overlayView,
                                            for: photo,
                                            at: index,
                                            totalNumberOfPhotos: totalNumberOfPhotos)
    }

    /// Called when the `AXPhotoViewController` will show/hide its `OverlayView`.
    /// This method will be called inside of an
    /// animation context, so perform any coordinated animations here.
    /// If you override this and fail to call super, the corresponding delegate method **will not be called!**
    /// - Parameters:
    ///   - overlayView: The `AXOverlayView` whose visibility is changing.
    ///   - visible: A boolean that denotes whether or not the overlay will be visible or invisible.
    func overlayView(_ overlayView: AXOverlayView, visibilityWillChange visible: Bool) {
        self.delegate?.photosViewController(self,
                                            overlayView: overlayView,
                                            visibilityWillChange: visible)
    }

    /// If implemented and returns a valid zoom scale for the photo (valid meaning >= the photo's
    ///  minimum zoom scale), the underlying
    /// zooming image view will adopt the returned `maximumZoomScale` instead of the default
    ///  calculated by the library. A good implementation
    /// of this method will use a combination of the provided `minimumZoomScale` and
    ///  `imageSize` to extrapolate a `maximumZoomScale` to return.
    /// If the `minimumZoomScale` is returned (ie. `minimumZoomScale` == `maximumZoomScale`),
    ///  zooming will be disabled for this image.
    /// If you override this and fail to call super, the corresponding delegate method **will not be called!**
    /// - Parameters:
    ///   - photo: The `Photo` that the zoom scale will affect.
    ///   - minimumZoomScale: The minimum zoom scale that is calculated by the library. This value cannot be changed.
    ///   - imageSize: The size of the image that belongs to the `AXPhoto`.
    /// - Returns: A "maximum" zoom scale that >= `minimumZoomScale`.
    func maximumZoomScale(for photo: AXPhotoProtocol, minimumZoomScale: CGFloat, imageSize: CGSize) -> CGFloat {
        return self.delegate?.photosViewController(self,
                                                   maximumZoomScaleFor: photo,
                                                   minimumZoomScale: minimumZoomScale,
                                                   imageSize: imageSize) ?? .leastNormalMagnitude
    }

    /// Called when the action button is tapped for a photo.
    /// If you override this and fail to call super, the corresponding
    /// delegate method **will not be called!**
    /// - Parameters:
    ///   - photo: The related `AXPhoto`.
    /// - Returns:
    ///   true if the action button tap was handled, false if the default action button behavior
    ///   should be invoked.
    func handleActionButtonTapped(photo: AXPhotoProtocol) -> Bool {
        if delegate?.photosViewController(self, handleActionButtonTappedFor: photo) != nil {
            return true
        }

        return false
    }

    /// Called when an action button action is completed. If you override this and fail to call super, the corresponding
    /// delegate method **will not be called!**
    /// - Parameters:
    ///   - photo: The related `AXPhoto`.
    /// - Note: This is only called for the default action.
    func actionCompleted(activityType: UIActivity.ActivityType, for photo: AXPhotoProtocol) {
        self.delegate?.photosViewController(self, actionCompletedWith: activityType, for: photo)
    }

    // MARK: - AXNetworkIntegrationDelegate

    /// :nodoc:
    func networkIntegration(_ networkIntegration: AXNetworkIntegrationProtocol,
                            loadDidFinishWith photo: AXPhotoProtocol) {
        if let image = photo.image {
            photo.ax_loadingState = .loaded
            DispatchQueue.main.async { [weak self] in
                self?.notificationCenter.post(
                    name: .photoImageUpdate,
                    object: photo,
                    userInfo: [
                        AXPhotosViewControllerNotification.ImageKey: image,
                        AXPhotosViewControllerNotification.LoadingStateKey: AXPhotoLoadingState.loaded
                    ])
            }
        }
    }

    /// :nodoc:
    func networkIntegration(_ networkIntegration: AXNetworkIntegrationProtocol,
                            loadDidFailWith error: Error,
                            for photo: AXPhotoProtocol) {
        guard photo.ax_loadingState != .loadingCancelled else {
            return
        }

        photo.ax_loadingState = .loadingFailed
        photo.ax_error = error
        DispatchQueue.main.async { [weak self] in
            self?.notificationCenter.post(
                name: .photoImageUpdate,
                object: photo,
                userInfo: [
                    AXPhotosViewControllerNotification.ErrorKey: error,
                    AXPhotosViewControllerNotification.LoadingStateKey: AXPhotoLoadingState.loadingFailed
                ])
        }
    }

    /// :nodoc:
    func networkIntegration(_ networkIntegration: AXNetworkIntegrationProtocol,
                            didUpdateLoadingProgress progress: CGFloat,
                            for photo: AXPhotoProtocol) {
        photo.ax_progress = progress
        DispatchQueue.main.async { [weak self] in
            self?.notificationCenter.post(name: .photoLoadingProgressUpdate,
                                          object: photo,
                                          userInfo: [AXPhotosViewControllerNotification.ProgressKey: progress])
        }
    }

    // MARK: - UIGestureRecognizerDelegate

    /// :nodoc:
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let currentPhotoIndex = self.currentPhotoIndex
        let dataSource = self.dataSource
        let zoomingImageView = self.currentPhotoViewController?.zoomingImageView
        let pagingConfig = self.pagingConfig

        guard !(zoomingImageView?.isScrollEnabled ?? true)
            && (pagingConfig.navigationOrientation == .horizontal
            || (pagingConfig.navigationOrientation == .vertical
            && (currentPhotoIndex == 0 || currentPhotoIndex == dataSource.numberOfPhotos - 1))) else {
            return false
        }

        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGestureRecognizer.velocity(in: gestureRecognizer.view)

            let isVertical = abs(velocity.y) > abs(velocity.x)
            guard isVertical else {
                return false
            }

            if pagingConfig.navigationOrientation == .horizontal {
                return true
            } else {
                if currentPhotoIndex == 0 {
                    return velocity.y > 0
                } else {
                    return velocity.y < 0
                }
            }
        }

        return false
    }

    /// :nodoc:
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - Convenience extensions

private var PhotoViewControllerLifecycleContext: UInt8 = 0

private extension Array where Element: UIViewController {

    func removeLifeycleObserver(_ observer: NSObject) {
        self.forEach { ($0 as UIViewController).removeLifecycleObserver(observer) }
    }
}

private extension UIViewController {

    func addLifecycleObserver(_ observer: NSObject) {
        self.addObserver(observer,
                         forKeyPath: #keyPath(parent),
                         options: .new,
                         context: &PhotoViewControllerLifecycleContext)
    }

    func removeLifecycleObserver(_ observer: NSObject) {
        self.removeObserver(observer,
                            forKeyPath: #keyPath(parent),
                            context: &PhotoViewControllerLifecycleContext)
    }
}

private extension UIPageViewController {

    var scrollView: UIScrollView {
        guard let scrollView = self.view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView else {
            fatalError("Unable to locate the underlying `UIScrollView`")
        }

        return scrollView
    }
}

private var PhotoViewControllerContentOffsetContext: UInt8 = 0

private extension UIScrollView {

    func addContentOffsetObserver(_ observer: NSObject) {
        self.addObserver(observer,
                         forKeyPath: #keyPath(contentOffset),
                         options: .new,
                         context: &PhotoViewControllerContentOffsetContext)
    }

    func removeContentOffsetObserver(_ observer: NSObject) {
        self.removeObserver(observer,
                            forKeyPath: #keyPath(contentOffset),
                            context: &PhotoViewControllerContentOffsetContext)
    }
}

// MARK: - AXPhotosViewControllerDelegate

/// AXPhotosViewControllerDelegate
protocol AXPhotosViewControllerDelegate: AnyObject, NSObjectProtocol {

    /// Called when the `AXPhotosViewController` navigates to a new photo.
    /// This is defined as when the swipe percent between pages
    /// is greater than the threshold (>0.5).
    /// - Parameters:
    ///   - photosViewController: The `AXPhotosViewController` that is navigating.
    ///   - photo: The `AXPhoto` that was navigated to.
    ///   - index: The `index` in the dataSource of the `AXPhoto` being transitioned to.
    func photosViewController(_ photosViewController: AXPhotosViewController,
                              didNavigateTo photo: AXPhotoProtocol,
                              at index: Int)

    /// Called when the `AXPhotosViewController` is configuring its `OverlayView` for a new photo.
    /// This should be used to update the
    /// the overlay's title or any other overlay-specific properties.
    /// - Parameters:
    ///   - photosViewController: The `AXPhotosViewController` that is updating the overlay.
    ///   - overlayView: The `AXOverlayView` that is being updated.
    ///   - photo: The `AXPhoto` the overlay is being configured for.
    ///   - index: The index of the `AXPhoto` that the overlay is being configured for.
    ///   - totalNumberOfPhotos: The total number of photos in the current `dataSource`.
    func photosViewController(_ photosViewController: AXPhotosViewController,
                              willUpdate overlayView: AXOverlayView,
                              for photo: AXPhotoProtocol,
                              at index: Int,
                              totalNumberOfPhotos: Int)

    /// Called when the `AXPhotoViewController` will show/hide its `OverlayView`.
    /// This method will be called inside of an
    /// animation context, so perform any coordinated animations here.
    /// - Parameters:
    ///   - photosViewController: The `AXPhotosViewController` that is updating the overlay visibility.
    ///   - overlayView: The `AXOverlayView` whose visibility is changing.
    ///   - visible: A boolean that denotes whether or not the overlay will be visible or invisible.
        func photosViewController(_ photosViewController: AXPhotosViewController,
                                  overlayView: AXOverlayView,
                                  visibilityWillChange visible: Bool)

    /// If implemented and returns a valid zoom scale for the photo (valid meaning >= the photo's minimum zoom scale),
    /// the underlying zooming image view will adopt the returned `maximumZoomScale` instead of the default
    /// calculated by the library. A good implementation of this method will use a combination of the provided
    /// `minimumZoomScale` and `imageSize` to extrapolate a `maximumZoomScale` to return.
    /// If the `minimumZoomScale` is returned (ie. `minimumZoomScale` == `maximumZoomScale`),
    /// zooming will be disabled for this image.
    /// - Parameters:
    ///   - photosViewController: The `AXPhotosViewController` that is updating the photo's zoom scale.
    ///   - photo: The `AXPhoto` that the zoom scale will affect.
    ///   - minimumZoomScale: The minimum zoom scale that is calculated by the library. This value cannot be changed.
    ///   - imageSize: The size of the image that belongs to the `AXPhoto`.
    /// - Returns: A "maximum" zoom scale that >= `minimumZoomScale`.
    func photosViewController(_ photosViewController: AXPhotosViewController,
                              maximumZoomScaleFor photo: AXPhotoProtocol,
                              minimumZoomScale: CGFloat,
                              imageSize: CGSize) -> CGFloat

    /// Called when the action button is tapped for a photo.
    /// If no implementation is provided, will fall back to default action.
    /// - Parameters:
    ///   - photosViewController: The `AXPhotosViewController` handling the action.
    ///   - photo: The related `Photo`.
    func photosViewController(_ photosViewController: AXPhotosViewController,
                              handleActionButtonTappedFor photo: AXPhotoProtocol)

    /// Called when an action button action is completed.
    /// - Parameters:
    ///   - photosViewController: The `AXPhotosViewController` that handled the action.
    ///   - photo: The related `AXPhoto`.
    /// - Note: This is only called for the default action.
    func photosViewController(_ photosViewController: AXPhotosViewController,
                              actionCompletedWith activityType: UIActivity.ActivityType,
                              for photo: AXPhotoProtocol)

    /// Called just before the `AXPhotosViewController` begins its dismissal
    /// - Parameter photosViewController: The view controller being dismissed
    func photosViewControllerWillDismiss(_ photosViewController: AXPhotosViewController)

    /// Called after the `AXPhotosViewController` completes its dismissal
    /// - Parameter photosViewController: The dismissed view controller
    func photosViewControllerDidDismiss(_ photosViewController: AXPhotosViewController)
}

// MARK: - Notification definitions

/// DescriptionAXPhotosViewControllerNotification
final class AXPhotosViewControllerNotification: NSObject {

    /// ProgressUpdate
    static let ProgressUpdate = Notification.Name.photoLoadingProgressUpdate.rawValue
    /// ImageUpdate
    static let ImageUpdate = Notification.Name.photoImageUpdate.rawValue
    /// AXPhotosViewControllerLoadingState
    static let ImageKey = "AXPhotosViewControllerImage"
    /// AXPhotosViewControllerLoadingState
    static let LoadingStateKey = "AXPhotosViewControllerLoadingState"
    /// AXPhotosViewControllerError
    static let ProgressKey = "AXPhotosViewControllerProgress"
    /// AXPhotosViewControllerError
    static let ErrorKey = "AXPhotosViewControllerError"
}

extension Notification.Name {

    /// AXPhotoLoadingProgressUpdateNotification
    static let photoLoadingProgressUpdate = Notification.Name("AXPhotoLoadingProgressUpdateNotification")
    /// DescriptionAXPhotoLoadingProgressUpdateNotification
    static let photoImageUpdate = Notification.Name("AXPhotoImageUpdateNotification")
}
