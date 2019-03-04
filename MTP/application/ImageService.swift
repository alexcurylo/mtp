// @copyright Trollwerks Inc.

import Nuke

protocol ImageService {}

extension UIImageView {

    func prepareForReuse() {
        Nuke.cancelRequest(for: self)
        image = nil
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

    func set(thumbnail user: UserInfo) {
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
}
