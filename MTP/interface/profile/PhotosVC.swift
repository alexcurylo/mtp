// @copyright Trollwerks Inc.

import AXPhotoViewer

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

    @IBOutlet private var saveButton: UIBarButtonItem?

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

    /// Display a user's posts
    var canCreate: Bool {
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
        //swiftlint:disable:previous unavailable_function
        fatalError("photo(at:) has not been overridden")
    }

    /// Create a new Photo
    func createPhoto() {
        //swiftlint:disable:previous unavailable_function
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

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

    /// Inform delegate of selection
    func broadcastSelection() {
        delegate?.selected(picture: current)
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
    }

    @IBAction func addTapped(_ sender: GradientButton) {
        createPhoto()
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
}

// MARK: UICollectionViewDataSource

extension PhotosVC {

    /// Provide header
    ///
    /// - Parameters:
    ///   - collectionView: Collection
    ///   - kind: Expect header
    ///   - indexPath: Item path
    /// - Returns: PhotosHeader
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        //swiftlint:disable:next implicitly_unwrapped_optional
        let header: PhotosHeader! = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: R.reuseIdentifier.photosHeader,
            for: indexPath
        )

        return header
    }

    /// Section items count
    ///
    /// - Parameters:
    ///   - collectionView: Collection
    ///   - section: Index
    /// - Returns: Item count
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return photoCount
    }

    /// Provide cell
    ///
    /// - Parameters:
    ///   - collectionView: Collection
    ///   - indexPath: Index path
    /// - Returns: PhotoCell
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //swiftlint:disable:next implicitly_unwrapped_optional
        let cell: PhotoCell! = collectionView.dequeueReusableCell(
            withReuseIdentifier: R.reuseIdentifier.photoCell,
            for: indexPath
        )

        let model = photo(at: indexPath.item)
        cell.inject(photo: model,
                    delegate: self,
                    isScrolling: isScrolling)
        if isScrolling {
            scrollingCells.insert(cell)
        }

        let selected = model.uuid == current && !original.isEmpty
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

    /// Selection permission
    ///
    /// - Parameters:
    ///   - collectionView: Container
    ///   - indexPath: Index path
    /// - Returns: Permission
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

    /// Selection handling
    ///
    /// - Parameters:
    ///   - collectionView: Container
    ///   - indexPath: Index path
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        current = photo(at: indexPath.item).uuid
        saveButton?.isEnabled = original != current
    }

    /// Menu permission
    ///
    /// - Parameters:
    ///   - collectionView: Container
    ///   - indexPath: Index path
    /// - Returns: Permission
    override func collectionView(_ collectionView: UICollectionView,
                                 shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        configureMenu()
        return true
    }

    /// Action permission
    ///
    /// - Parameters:
    ///   - collectionView: Container
    ///   - action: Action
    ///   - indexPath: Index path
    ///   - sender: Sender
    /// - Returns: Permission
    override func collectionView(_ collectionView: UICollectionView,
                                 canPerformAction action: Selector,
                                 forItemAt indexPath: IndexPath,
                                 withSender sender: Any?) -> Bool {
        return MenuAction.isContent(action: action)
    }

    /// Action operation
    ///
    /// - Parameters:
    ///   - collectionView: Container
    ///   - action: Action
    ///   - indexPath: Index path
    ///   - sender: Sender
    override func collectionView(_ collectionView: UICollectionView,
                                 performAction action: Selector,
                                 forItemAt indexPath: IndexPath,
                                 withSender sender: Any?) {
        // Required to be present but only triggers for standard items
    }
}

// MARK: UIScrollViewDelegate

extension PhotosVC {

    /// Flag scrolling to suppress image loading
    ///
    /// - Parameter scrollView: Container
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrolling = true
    }

    /// Unflag scrolling to resume image loading
    ///
    /// - Parameters:
    ///   - scrollView: Container
    ///   - decelerate: Will taper off
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                           willDecelerate decelerate: Bool) {
        if !decelerate {
            isScrolling = false
        }
    }

    /// Unflag scrolling to resume image loading
    ///
    /// - Parameter scrollView: Container
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isScrolling = false
    }

    /// Flag scrolling to suppress image loading
    ///
    /// - Parameter scrollView: Container
    /// - Returns: Permission
    override func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        isScrolling = true
        return true
    }

    /// Scrolling notfication
    ///
    /// - Parameter scrollView: Scrollee
    override func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        isScrolling = false
    }

    /// Unflag scrolling to resume image loading
    ///
    /// - Parameter scrollView: Container
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isScrolling = false
    }
}

// MARK: PhotoCellDelegate

extension PhotosVC: PhotoCellDelegate {

    /// Clear suspended state
    ///
    /// - Parameter cell: Cell
    func prepared(forReuse cell: PhotoCell) {
        scrollingCells.remove(cell)
    }

    /// Handle hide action
    ///
    /// - Parameter hide: Photo to hide
    func tapped(hide: Photo?) {
        data.block(photo: hide?.photoId ?? 0)
    }

    /// Handle report action
    ///
    /// - Parameter report: Photo to report
    func tapped(report: Photo?) {
        let message = L.reportPhoto(report?.photoId ?? 0)
        app.route(to: .reportContent(message))
    }

    /// Handle block action
    ///
    /// - Parameter block: Photo to block
    func tapped(block: Photo?) {
        data.block(user: block?.userId ?? 0)
        app.route(to: .locations)
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension PhotosVC: UICollectionViewDelegateFlowLayout {

    /// Provide header size
    ///
    /// - Parameters:
    ///   - collectionView: Collection
    ///   - collectionViewLayout: Collection layout
    ///   - section: Section index
    /// - Returns: Size
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection: Int) -> CGSize {
        if canCreate,
           let flow = collectionViewLayout as? UICollectionViewFlowLayout {
            return flow.headerReferenceSize
        }

        return .zero
    }

    /// Provide cell size
    ///
    /// - Parameters:
    ///   - collectionView: Collection
    ///   - collectionViewLayout: Collection layout
    ///   - indexPath: Cell path
    /// - Returns: Size
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

/// Header for photos collections
final class PhotosHeader: UICollectionReusableView {
    // expect addTapped(_:) hooked up in storyboard

    @IBOutlet private var addPhotoButton: GradientButton? {
        didSet {
            UIPhotos.add.expose(item: addPhotoButton)
        }
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
