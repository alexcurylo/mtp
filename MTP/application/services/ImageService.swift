// @copyright Trollwerks Inc.

import Nuke
import NukeAlamofirePlugin

private let _dispatchOnceConfigureNukeWithAlamofire: Void = {
    let pipeline = ImagePipeline {
        $0.dataLoader = AlamofireDataLoader()
        $0.imageCache = ImageCache.shared
    }
    ImagePipeline.shared = pipeline
}()

/// Currently synonym for the Nuke protocol
protocol ImageService: ImageDisplaying { }

extension ImageService where Self: UIView {

    /// Load location image
    ///
    /// - Parameter location: Location
    func load(image location: Location?) {
        load(image: location?.placeImageUrl)
    }

    /// Load location flag
    ///
    /// - Parameter location: Location
    func load(flag location: Location?) {
        load(image: location?.flagUrl)
    }

    /// Load mappable image
    ///
    /// - Parameter mappable: Mappable
    func load(image mappable: Mappable?) {
        load(image: mappable?.imageUrl,
             placeholder: R.image.placeholderMedium()
        )
    }

    /// Load photo image
    ///
    /// - Parameter photo: Photo
    func load(image photo: Photo?) {
        load(image: photo?.imageUrl)
    }

    /// Load user image
    ///
    /// - Parameter user: User info
    func load(image user: UserAvatar) {
        load(image: user.imageUrl,
             placeholder: user.placeholder
        )
    }

    /// Load image from HTML
    ///
    /// - Parameter html: HTML
    func load(image html: String) -> Bool {
        // example pattern, 30 characters prefix and 1 character suffix:
        // src="/api/files/preview?uuid=7FgX3ruwM4j5heCyrAAaq8"
        guard let range = html.range(
                of: #"src="\/api\/files\/preview\?uuid=[A-Za-z0-9+\/=]+\""#,
                options: .regularExpression
             ) else {
                display(image: nil)
                return false
        }

        let match = String(html[range])
        let uuid = String(match[29...match.count - 2])
        let target = MTP.picture(uuid: uuid, size: .thumb)

        return load(image: target.requestUrl)
    }

    @discardableResult private func load(
        image url: URL?,
        placeholder: UIImage? = R.image.placeholderThumb()
    ) -> Bool {
        guard let url = url else {
            display(image: placeholder)
            return false
        }

        _dispatchOnceConfigureNukeWithAlamofire

        Nuke.loadImage(
            with: url,
            options: ImageLoadingOptions(
                placeholder: placeholder,
                transition: .fadeIn(duration: 0.2)
            ),
            into: self
        )
        return true
    }
}

extension UIImageView: ImageService {

    /// Cancel request in progress
    func prepareForReuse() {
        Nuke.cancelRequest(for: self)
        image = nil
        isHidden = false
    }
}

extension UIButton: ImageService {

    /// Conform UIButton to ImageService
    ///
    /// - Parameter image: image to display
    open func display(image: Image?) {
        setBackgroundImage(image, for: .normal)
    }
}
