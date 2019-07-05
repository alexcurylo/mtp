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
    private var mode: Mode = .browser
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    func broadcastSelection() {
        delegate?.selected(picture: current)
    }
}

// MARK: - Private

private extension PhotosVC {

    @IBAction func addTapped(_ sender: GradientButton) {
        createPhoto()
    }

    func present(fullscreen item: Int) {
        let model = photo(at: item)
        let photos = [
            AXPhoto(url: model.imageUrl)
        ]
        let dataSource = AXPhotosDataSource(photos: photos)
        let photosViewController = AXPhotosViewController(dataSource: dataSource)
        self.present(photosViewController, animated: true)
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
        cell.set(photo: model)
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

final class PhotoCell: UICollectionViewCell {

    @IBOutlet private var imageView: UIImageView?

    override var isSelected: Bool {
        didSet {
            borderColor = isSelected ? .switchOn : nil
            borderWidth = isSelected ? 4 : 0
        }
    }

    fileprivate func set(image: UIImage?) {
        imageView?.image = image
    }

    fileprivate func set(photo: Photo?) {
        imageView?.load(image: photo)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView?.prepareForReuse()
    }
}

final class PhotosHeader: UICollectionReusableView {
    // expect addTapped(_:) hooked up in storyboard
}
