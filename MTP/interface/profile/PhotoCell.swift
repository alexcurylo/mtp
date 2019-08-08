// @copyright Trollwerks Inc.

import UIKit

/// Actions triggered by photo cell
protocol PhotoCellDelegate: AnyObject {

    /// Clear suspended state
    ///
    /// - Parameter cell: Cell
    func prepared(forReuse cell: PhotoCell)

    /// Handle hide action
    ///
    /// - Parameter hide: Photo to hide
    func tapped(hide: Photo?)
    /// Handle report action
    ///
    /// - Parameter report: Photo to report
    func tapped(report: Photo?)
    /// Handle block action
    ///
    /// - Parameter block: Photo to block
    func tapped(block: Photo?)
}

/// Displays pictures in Photos tabs
final class PhotoCell: UICollectionViewCell, ServiceProvider {

    /// Photo displayer
    @IBOutlet var imageView: UIImageView?
    //swiftlint:disable:previous private_outlet

    private var photo: Photo?
    private var loaded = false
    /// Display suppression flag
    var isScrolling = false {
        didSet {
            if !isScrolling { load() }
        }
    }

    private weak var delegate: PhotoCellDelegate?

    /// Handle selected state display
    override var isSelected: Bool {
        didSet {
            borderColor = isSelected ? .switchOn : nil
            borderWidth = isSelected ? 4 : 0
        }
    }

    /// Handle dependency injection
    ///
    /// - Parameters:
    ///   - model: Data model
    ///   - delegate: Delegate
    ///   - isScrolling: Whether to load immediately
    func inject(photo: Photo?,
                delegate: PhotoCellDelegate,
                isScrolling: Bool) {
        self.photo = photo
        self.delegate = delegate
        self.isScrolling = isScrolling
    }

    /// Empty display
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
