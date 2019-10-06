// @copyright Trollwerks Inc.

import UIKit

// swiftlint:disable file_length

/// Photo selection notification
protocol PhotoSelectionDelegate: AnyObject {

    /// Notify of selection
    ///
    /// - Parameter picture: Selected picture
    func selected(picture: String)
}

/// Base class for location and user photo display
class PhotosVC: UICollectionViewController {

    @IBOutlet private var saveButton: UIBarButtonItem? {
        didSet {
            UIPhotos.save.expose(item: saveButton)
        }
    }

    /// Whether we can select a photo
    enum Mode {

        /// Display only
        case browser
        /// Select a picture, as for profile avatar
        case picker
    }

    private enum Layout {
        static let minItemSize = CGFloat(100)
    }

    /// Content state to display
    var contentState: ContentState = .loading
    /// Mode of presentation
    var mode: Mode = .browser
    private var configuredMenu = false
    /// Filtered queued network actions
    var queuedPhotos: [MTPPhotoRequest] = []
    private var requestsObserver: Observer?
    private var headerModel: PhotosHeader.Model = (false, false) {
        didSet {
            if headerModel != oldValue {
                collectionView.collectionViewLayout.invalidateLayout()
            }
        }
    }

    private var scrollingCells: Set<PhotoCell> = []
    private var isScrolling = false {
        didSet {
            if !isScrolling {
                scrollingCells.forEach { $0.isScrolling = isScrolling }
                scrollingCells = []
            }
        }
    }

    private var original: String = ""
    private var current: String = ""
    private weak var delegate: PhotoSelectionDelegate?

    private let layoutHeader = (create: CGFloat(50),
                                queued: CGFloat(100))

    /// Whether user can add a new photo
    var canCreate: Bool {
        return false
    }

    /// Whether a new photo is queued to upload
    var isQueued: Bool {
        return false
    }

    /// How many photos in collection
    var photoCount: Int {
        fatalError("photoCount has not been overridden")
    }

    /// Retrieve an indexed photo
    ///
    /// - Parameter index: Index
    /// - Returns: Photo
    func photo(at index: Int) -> Photo {
        // swiftlint:disable:previous unavailable_function
        fatalError("photo(at:) has not been overridden")
    }

    /// Create a new Photo
    func createPhoto() {
        // swiftlint:disable:previous unavailable_function
        fatalError("createPhoto has not been overridden")
    }

    /// Handle dependency injection
    ///
    /// - Parameters:
    ///   - mode: Presentation mode
    ///   - selection: Starting selection if any
    ///   - delegate: Selection delegate
    func inject(mode: Mode,
                selection: String = "",
                delegate: PhotoSelectionDelegate? = nil) {
        self.mode = mode
        original = selection
        current = selection
        self.delegate = delegate
        configure()
    }

    /// :nodoc:
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

    /// Inform delegate of selection
    func broadcastSelection() {
        delegate?.selected(picture: current)
    }

    /// Track queued photos for possible display
    func update() {
        queuedPhotos = net.requests.of(type: MTPPhotoRequest.self)
        headerModel = (add: canCreate, queue: isQueued)

        observeRequests()
    }
}

// MARK: - Private

private extension PhotosVC {

    func configure() {
        let background: UIView
        switch mode {
        case .browser:
            background = UIView {
                $0.backgroundColor = .clear
            }
        case .picker:
            background = GradientView {
                $0.set(gradient: [.dodgerBlue, .azureRadiance],
                       orientation: .topRightBottomLeft)
            }
            saveButton.require().isEnabled = false
        }
        collectionView.backgroundView = background
        UIPhotos.photos.expose(item: collectionView)

        update()
    }

    func present(fullscreen item: Int) {
        let source = AXMTPDataSource(source: self, item: item)

        let transition = AXTransitionInfo(
            interactiveDismissalEnabled: true,
            startingView: imageView(item: item)
        ) { [weak self] _, index -> UIImageView? in
            self?.imageView(item: index)
        }

        let photosViewController = AXPhotosViewController(dataSource: source,
                                                          pagingConfig: nil,
                                                          transitionInfo: transition)
        self.present(photosViewController, animated: true)
    }

    func imageView(item: Int) -> UIImageView? {
        let path = IndexPath(item: item, section: 0)
        let cell = collectionView.cellForItem(at: path)
        return (cell as? PhotoCell)?.imageView
    }

    private func configureMenu() {
        guard !configuredMenu else { return }

        configuredMenu = true
        UIMenuController.shared.menuItems = MenuAction.contentItems
    }

    func observeRequests() {
        guard requestsObserver == nil else { return }

        requestsObserver = net.observer(of: .requests) { [weak self] _ in
            self?.update()
        }
    }
}

// MARK: - PhotosHeaderDelegate

extension PhotosVC: PhotosHeaderDelegate {

    func addTapped() {
        createPhoto()
    }

    func queueTapped() {
        app.route(to: .network)
    }
}

// MARK: UICollectionViewDataSource

extension PhotosVC {

    /// :nodoc:
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        // swiftlint:disable:next implicitly_unwrapped_optional
        let header: PhotosHeader! = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: R.reuseIdentifier.photosHeader,
            for: indexPath
        )

        header?.inject(model: headerModel,
                       delegate: self)

        return header
    }

    /// :nodoc:
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return photoCount
    }

    /// :nodoc:
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable:next implicitly_unwrapped_optional
        let cell: PhotoCell! = collectionView.dequeueReusableCell(
            withReuseIdentifier: R.reuseIdentifier.photoCell,
            for: indexPath
        )

        let model = PhotoCellModel(
            index: indexPath.item,
            photo: photo(at: indexPath.item)
        )
        cell.inject(model: model,
                    delegate: self,
                    isScrolling: isScrolling)
        if isScrolling {
            scrollingCells.insert(cell)
        }

        let selected = model.photo?.uuid == current && !original.isEmpty
        if selected && !cell.isSelected {
            cell.isSelected = true
            collectionView.selectItem(at: indexPath,
                                      animated: false,
                                      scrollPosition: [])
        }

        return cell
    }
}

// MARK: UICollectionViewDelegate

extension PhotosVC {

    /// :nodoc:
    override func collectionView(_ collectionView: UICollectionView,
                                 shouldSelectItemAt indexPath: IndexPath) -> Bool {
        switch mode {
        case .browser:
            present(fullscreen: indexPath.item)
            return false
        case .picker:
            return true
        }
    }

    /// :nodoc:
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        current = photo(at: indexPath.item).uuid
        saveButton?.isEnabled = original != current
    }

    /// :nodoc:
    override func collectionView(_ collectionView: UICollectionView,
                                 shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        configureMenu()
        return true
    }

    /// :nodoc:
    override func collectionView(_ collectionView: UICollectionView,
                                 canPerformAction action: Selector,
                                 forItemAt indexPath: IndexPath,
                                 withSender sender: Any?) -> Bool {
        return MenuAction.isContent(action: action)
    }

    /// :nodoc:
    override func collectionView(_ collectionView: UICollectionView,
                                 performAction action: Selector,
                                 forItemAt indexPath: IndexPath,
                                 withSender sender: Any?) {
        // Required to be present but only triggers for standard items
    }
}

// MARK: UIScrollViewDelegate

extension PhotosVC {

    /// :nodoc:
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrolling = true
    }

    /// :nodoc:
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                           willDecelerate decelerate: Bool) {
        if !decelerate {
            isScrolling = false
        }
    }

    /// :nodoc:
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isScrolling = false
    }

    /// :nodoc:
    override func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        isScrolling = true
        return true
    }

    /// :nodoc:
    override func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        isScrolling = false
    }

    /// :nodoc:
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isScrolling = false
    }
}

// MARK: PhotoCellDelegate

extension PhotosVC: PhotoCellDelegate {

    /// :nodoc:
    func prepared(forReuse cell: PhotoCell) {
        scrollingCells.remove(cell)
    }

    /// :nodoc:
    func tapped(hide: Photo?) {
        data.block(photo: hide?.photoId ?? 0)
    }

    /// :nodoc:
    func tapped(report: Photo?) {
        let message = L.reportPhoto(report?.photoId ?? 0)
        app.route(to: .reportContent(message))
    }

    /// :nodoc:
    func tapped(block: Photo?) {
        if data.block(user: block?.userId ?? 0) {
            app.route(to: .locations)
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension PhotosVC: UICollectionViewDelegateFlowLayout {

    /// :nodoc:
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection: Int) -> CGSize {
        switch (canCreate, isQueued) {
        case (true, true):
            return CGSize(width: collectionView.frame.width,
                          height: layoutHeader.queued)
        case (true, false):
            return CGSize(width: collectionView.frame.width,
                          height: layoutHeader.create)
        case (false, _):
            return .zero
        }
    }

    /// :nodoc:
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flow = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize(width: Layout.minItemSize, height: Layout.minItemSize)
        }
        let width = collectionView.bounds.width - flow.sectionInset.horizontal
        let itemWidth = Layout.minItemSize + flow.minimumInteritemSpacing
        let items = ((width + flow.minimumInteritemSpacing) / itemWidth).rounded(.down)
        let spacing = (items - 1) * flow.minimumInteritemSpacing
        let edge = ((width - spacing) / items).rounded(.down)
        return CGSize(width: edge, height: edge)
    }
}

private class AXMTPDataSource: AXPhotosDataSource {

    init(source: PhotosVC, item: Int) {
        let models = (0..<source.photoCount).map {
            AXMTPPhoto(source: source, item: $0)
        }
        super.init(photos: models,
                   initialPhotoIndex: item,
                   prefetchBehavior: .regular)
    }
}

private class AXMTPPhoto: NSObject, AXPhotoProtocol {

    private let source: PhotosVC
    private let item: Int

    var imageData: Data?
    var image: UIImage?
    var attributedTitle: NSAttributedString? {
        return model.attributedTitle
    }
    var attributedDescription: NSAttributedString?
    var attributedCredit: NSAttributedString?
    var url: URL? {
        return model.imageUrl
    }

    init(source: PhotosVC, item: Int) {
        self.source = source
        self.item = item
    }

    private var model: Photo {
        return source.photo(at: item)
    }
}
