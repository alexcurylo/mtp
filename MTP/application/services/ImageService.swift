// @copyright Trollwerks Inc.

import Nuke

protocol ImageService {}

extension UIImageView {

    func prepareForReuse() {
        Nuke.cancelRequest(for: self)
        image = nil
        isHidden = false
    }

    func set(thumbnail location: Location?) {
        let placeholder = R.image.placeholderThumb()
        guard let url = location?.imageUrl else {
            image = placeholder
            return
        }

        Nuke.loadImage(
            with: url,
            options: ImageLoadingOptions(
                placeholder: placeholder,
                transition: .fadeIn(duration: 0.2)
            ),
            into: self
        )
    }

    func set(thumbnail place: PlaceAnnotation?) {
        let placeholder = R.image.placeholderThumb()
        guard let url = place?.imageUrl else {
            image = placeholder
            return
        }

        Nuke.loadImage(
            with: url,
            options: ImageLoadingOptions(
                placeholder: placeholder,
                transition: .fadeIn(duration: 0.2)
            ),
            into: self
        )
    }

    func set(thumbnail photo: Photo?) {
        let placeholder = R.image.placeholderThumb()
        guard let url = photo?.imageUrl else {
            image = placeholder
            return
        }

        Nuke.loadImage(
            with: url,
            options: ImageLoadingOptions(
                placeholder: placeholder,
                transition: .fadeIn(duration: 0.2)
            ),
            into: self
        )
    }

    func set(thumbnail user: UserAvatar) {
        let placeholder = user.placeholder
        guard let url = user.imageUrl else {
            image = placeholder
            return
        }

        Nuke.loadImage(
            with: url,
            options: ImageLoadingOptions(
                placeholder: placeholder,
                transition: .fadeIn(duration: 0.2)
            ),
            into: self
        )
    }

    func set(thumbnail html: String) -> Bool {
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
        guard let url = target.requestUrl else {
            image = nil
            return false
        }

        let placeholder = R.image.placeholderThumb()
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
