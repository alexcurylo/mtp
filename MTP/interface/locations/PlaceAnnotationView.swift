// @copyright Trollwerks Inc.

import Anchorage
import MapKit

final class PlaceAnnotationView: MKMarkerAnnotationView, ServiceProvider {

    enum Layout {
        static let width = CGFloat(260)
        static let imageSize = CGSize(width: width, height: 150)
        static let closeOutset = CGFloat(6)
    }

    let featuredImage = UIImageView {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFill
        $0.sizeAnchors == Layout.imageSize
        $0.clipsToBounds = true
    }

    let category = UILabel {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = Avenir.medium.of(size: 13)
        $0.textColor = .darkText
    }

    let name = UILabel {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = Avenir.heavy.of(size: 18)
        $0.textColor = .darkText
    }

    let country = UILabel {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = Avenir.heavy.of(size: 15)
        $0.textColor = .darkText
    }

    let visitors = UILabel {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = Avenir.medium.of(size: 13)
        $0.textColor = .darkText
    }

    let showMore = GradientButton {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.orientation = GradientOrientation.horizontal.rawValue
        $0.startColor = .dodgerBlue
        $0.endColor = .azureRadiance
        $0.cornerRadius = 4

        let title = Localized.showMore()
        $0.setTitle(title, for: .normal)
        $0.titleLabel?.font = Avenir.heavy.of(size: 18)
    }

    override init(annotation: MKAnnotation?,
                  reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        clusteringIdentifier = PlaceClusterAnnotationView.identifier
        collisionMode = .circle
        canShowCallout = true
        titleVisibility = .hidden
        subtitleVisibility = .visible
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()
        guard let place = annotation as? PlaceAnnotation else { return }

        markerTintColor = place.background
        glyphImage = place.listImage
        glyphText = nil

        // this is called at startup, don't set image here
        category.text = place.type.category.uppercased()
        name.text = place.subtitle
        country.text = place.country
        visitors.text = Localized.visitors(place.visitors.grouped)

        detailCalloutAccessoryView = detailView(place: place)
   }

    func prepareForCallout() {
        guard let place = annotation as? PlaceAnnotation,
              featuredImage.image == nil else { return }

        featuredImage.set(thumbnail: place)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        featuredImage.prepareForReuse()
        markerTintColor = nil
        glyphText = nil
        glyphImage = nil
        leftCalloutAccessoryView = nil
        rightCalloutAccessoryView = nil
        detailCalloutAccessoryView = nil
        annotation = nil
        image = nil
    }
}

private extension PlaceAnnotationView {

    @objc func toggleVisit(_ sender: UISwitch) {
        guard let place = annotation as? PlaceAnnotation else { return }
        place.visited = sender.isOn
    }

    @objc func showMoreTapped(_ sender: GradientButton) {
        guard let place = annotation as? PlaceAnnotation else { return }
        place.show()
    }

    @objc func closeTapped(_ sender: UIButton) {
        guard let place = annotation as? PlaceAnnotation else { return }

        place.delegate?.close(callout: place)
    }

    func detailView(place: PlaceAnnotation) -> UIView {

        let holder = UIView {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.addSubview(featuredImage)
            $0.heightAnchor == Layout.imageSize.height + Layout.closeOutset
            $0.widthAnchor == Layout.imageSize.width
            featuredImage.centerXAnchor == $0.centerXAnchor
            featuredImage.bottomAnchor == $0.bottomAnchor
        }

        _ = UIButton {
            $0.setImage(R.image.buttonCloseOutlined(), for: .normal)
            holder.addSubview($0)
            $0.topAnchor == holder.topAnchor
            $0.trailingAnchor == holder.trailingAnchor + Layout.closeOutset
            $0.addTarget(self,
                         action: #selector(closeTapped),
                         for: .touchUpInside)
        }

        let nameStack = UIStackView(arrangedSubviews: [category,
                                                       name])
        nameStack.axis = .vertical
        nameStack.spacing = 0

        let detailStack = UIStackView(arrangedSubviews: [country,
                                                         visitors])
        detailStack.axis = .vertical
        detailStack.spacing = 0

        let bottomSpacer = UIView {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.heightAnchor == 2
        }

        showMore.addTarget(self,
                           action: #selector(showMoreTapped),
                           for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [holder,
                                                   nameStack,
                                                   detailStack,
                                                   showMore,
                                                   bottomSpacer
                                                   ])
        stack.axis = .vertical
        stack.spacing = 4
        stack.widthAnchor == Layout.width

        return stack
    }
}
