// @copyright Trollwerks Inc.

import UIKit

/// Things tht can trigger in a PhotoCell
protocol PhotoCellDelegate: AnyObject {

    func prepared(forReuse cell: PhotoCell)

    func tapped(hide: Photo?)
    func tapped(report: Photo?)
    func tapped(block: Photo?)
}

/// Displays pictures in Photos tabs
final class PhotoCell: UICollectionViewCell, ServiceProvider {

    //swiftlint:disable:next private_outlet
    @IBOutlet var imageView: UIImageView?

    private var photo: Photo?
    private var loaded = false
    var isScrolling = false {
        didSet {
            if !isScrolling { load() }
        }
    }

    private weak var delegate: PhotoCellDelegate?

    override var isSelected: Bool {
        didSet {
            borderColor = isSelected ? .switchOn : nil
            borderWidth = isSelected ? 4 : 0
        }
    }

    func set(photo: Photo?,
             delegate: PhotoCellDelegate,
             isScrolling: Bool) {
        self.photo = photo
        self.delegate = delegate
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
}

// MARK: - Private

private extension PhotoCell {

    func load() {
        guard !loaded, let photo = photo else { return }

        loaded = true
        imageView?.load(image: photo)
    }

    @objc func hide(_ sender: AnyObject?) {
        delegate?.tapped(hide: photo)
    }

    @objc func report(_ sender: AnyObject?) {
        delegate?.tapped(report: photo)
    }

    @objc func block(_ sender: AnyObject?) {
        delegate?.tapped(block: photo)
    }
}
