// @copyright Trollwerks Inc.

import Nuke

protocol ImageService {}

extension UIImageView {

    func prepareForReuse() {
        Nuke.cancelRequest(for: self)
        image = nil
        isHidden = false
    }

    func load(image location: Location?) {
        load(image: location?.imageUrl)
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
            image = nil
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
            image = placeholder
            return false
        }

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
