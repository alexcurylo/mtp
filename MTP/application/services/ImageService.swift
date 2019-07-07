// @copyright Trollwerks Inc.

import Nuke
import NukeAlamofirePlugin

private let configureNukeWithAlamofire: Void = {
    let pipeline = ImagePipeline {
        $0.dataLoader = AlamofireDataLoader()
        $0.imageCache = ImageCache.shared
    }
}()

protocol ImageService: ImageDisplaying { }

extension ImageService where Self: UIView {

    func load(image location: Location?) {
        load(image: location?.placeImageUrl)
    }

    func load(flag location: Location?) {
        load(image: location?.flagUrl)
    }

    func load(image place: MapInfo?) {
        load(image: place?.imageUrl,
             placeholder: R.image.placeholderMedium()
        )
    }

    func load(image place: PlaceAnnotation?) {
        load(image: place?.imageUrl,
             placeholder: R.image.placeholderMedium()
        )
    }

    func load(image photo: Photo?) {
        load(image: photo?.imageUrl)
    }

    func load(image user: UserAvatar) {
        load(image: user.imageUrl,
             placeholder: user.placeholder
        )
    }

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

    @discardableResult func load(
        image url: URL?,
        placeholder: UIImage? = R.image.placeholderThumb()
    ) -> Bool {
        guard let url = url else {
            display(image: placeholder)
            return false
        }

        configureNukeWithAlamofire

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

    func prepareForReuse() {
        Nuke.cancelRequest(for: self)
        image = nil
        isHidden = false
    }
}

extension UIButton: ImageService {

    open func display(image: Image?) {
        setBackgroundImage(image, for: .normal)
    }
}
