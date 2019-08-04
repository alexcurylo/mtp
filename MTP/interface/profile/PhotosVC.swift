// @copyright Trollwerks Inc.

import AXPhotoViewer

protocol PhotoSelectionDelegate: AnyObject {

    func selected(picture: String)
}

class PhotosVC: UICollectionViewController, ServiceProvider {

    @IBOutlet private var saveButton: UIBarButtonItem?

    enum Mode {
        case browser
        case picker
    }

    private enum Layout {
        static let minItemSize = CGFloat(100)
    }

    var contentState: ContentState = .loading
    var mode: Mode = .browser

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

    var canCreate: Bool {
        return false
    }

    var photoCount: Int {
        fatalError("photoCount has not been overridden")
    }

    //swiftlint:disable:next unavailable_function
    func photo(at index: Int) -> Photo {
        fatalError("photo(at:) has not been overridden")
    }

    //swiftlint:disable:next unavailable_function
    func createPhoto() {
        fatalError("createPhoto has not been overridden")
    }

    func set(mode: Mode,
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
}

// MARK: UICollectionViewDataSource

extension PhotosVC {

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

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return photoCount
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //swiftlint:disable:next implicitly_unwrapped_optional
        let cell: PhotoCell! = collectionView.dequeueReusableCell(
            withReuseIdentifier: R.reuseIdentifier.photoCell,
            for: indexPath
        )

        let model = photo(at: indexPath.item)
        cell.set(photo: model, isScrolling: isScrolling)
        if isScrolling {
            cell.delegate = self
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

    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        current = photo(at: indexPath.item).uuid
        saveButton?.isEnabled = original != current
    }
}

// MARK: UIScrollViewDelegate

extension PhotosVC {

    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrolling = true
    }

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                           willDecelerate decelerate: Bool) {
        if !decelerate {
            isScrolling = false
        }
    }

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isScrolling = false
    }

    override func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        isScrolling = true
        return true
    }

    override func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        isScrolling = false
    }

    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isScrolling = false
    }
}

// MARK: PhotoCellDelegate

extension PhotosVC: PhotoCellDelegate {

    func prepared(forReuse cell: PhotoCell) {
        scrollingCells.remove(cell)
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension PhotosVC: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection: Int) -> CGSize {
        if canCreate,
           let flow = collectionViewLayout as? UICollectionViewFlowLayout {
            return flow.headerReferenceSize
        }

        return .zero
    }

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

protocol PhotoCellDelegate: AnyObject {

    func prepared(forReuse cell: PhotoCell)
}

final class PhotoCell: UICollectionViewCell {

    //swiftlint:disable:next private_outlet
    @IBOutlet var imageView: UIImageView?

    private var photo: Photo?
    private var loaded = false
    var isScrolling = false {
        didSet {
            if !isScrolling { load() }
        }
    }

    weak var delegate: PhotoCellDelegate?

    override var isSelected: Bool {
        didSet {
            borderColor = isSelected ? .switchOn : nil
            borderWidth = isSelected ? 4 : 0
        }
    }

    fileprivate func set(photo: Photo?,
                         isScrolling: Bool) {
        self.photo = photo
        self.isScrolling = isScrolling
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView?.prepareForReuse()
        photo = nil
        loaded = false
        isScrolling = false

        delegate?.prepared(forReuse: self)
    }

    private func load() {
        guard !loaded, let photo = photo else { return }

        loaded = true
        imageView?.load(image: photo)
    }
}

final class PhotosHeader: UICollectionReusableView {
    // expect addTapped(_:) hooked up in storyboard
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
