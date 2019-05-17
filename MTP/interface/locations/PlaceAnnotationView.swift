// @copyright Trollwerks Inc.

import Anchorage
import MapKit

final class PlaceAnnotationView: MKMarkerAnnotationView, ServiceProvider {

    enum Layout {
        static let width = CGFloat(260)
        static let imageSize = CGSize(width: width, height: 150)
        static let closeOutset = CGFloat(6)
    }

    let placeImage = UIImageView {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFill
        $0.sizeAnchors == Layout.imageSize
        $0.clipsToBounds = true
    }

    let categoryLabel = UILabel {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        $0.font = Avenir.medium.of(size: 13)
        $0.textColor = .darkText
    }

    let visitedLabel = UILabel {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.font = Avenir.medium.of(size: 13)
        $0.textColor = .darkText
    }

    let visitSwitch = UISwitch {
        $0.styleAsFilter()
        $0.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
    }

    let nameLabel = UILabel {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = Avenir.heavy.of(size: 18)
        $0.textColor = .darkText
        $0.numberOfLines = 0
    }

    let countryLabel = UILabel {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = Avenir.heavy.of(size: 14)
        $0.textColor = .darkText
        $0.numberOfLines = 0
    }

    let visitorsLabel = UILabel {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = Avenir.medium.of(size: 13)
        $0.textColor = .darkText
    }

    let showMoreButton = GradientButton {
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

        visitSwitch.addTarget(self,
                              action: #selector(toggleVisit),
                              for: .valueChanged)
        showMoreButton.addTarget(self,
                                 action: #selector(showMoreTapped),
                                 for: .touchUpInside)
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
        categoryLabel.text = place.list.category.uppercased()
        show(visited: place.isVisited)
        nameLabel.text = place.subtitle
        countryLabel.text = place.country
        visitorsLabel.text = Localized.visitors(place.visitors.grouped)

        detailCalloutAccessoryView = detailView(place: place)
   }

    func prepareForCallout() {
        guard let place = annotation as? PlaceAnnotation,
              placeImage.image == nil else { return }

        placeImage.load(image: place)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        placeImage.prepareForReuse()
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

        let isVisited = sender.isOn
        place.isVisited = isVisited
        show(visited: isVisited)
    }

    @objc func showMoreTapped(_ sender: GradientButton) {
        guard let place = annotation as? PlaceAnnotation else { return }
        place.show()
    }

    @objc func closeTapped(_ sender: UIButton) {
        guard let place = annotation as? PlaceAnnotation else { return }

        place.delegate?.close(place: place)
    }

    func show(visited: Bool) {
        visitedLabel.text = (visited ? Localized.visited() : Localized.notVisited()).uppercased()
        visitSwitch.isOn = visited
    }

    func detailView(place: PlaceAnnotation) -> UIView {

        let bottomSpacer = UIView {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.heightAnchor == 2
        }

        let stack = UIStackView(arrangedSubviews: [topView,
                                                   categoryStack,
                                                   detailStack,
                                                   showMoreButton,
                                                   bottomSpacer
                                                   ])
        stack.axis = .vertical
        stack.spacing = 4
        stack.widthAnchor == Layout.width

        return stack
    }

    var topView: UIView {
        let holder = UIView {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.addSubview(placeImage)
            $0.heightAnchor == Layout.imageSize.height + Layout.closeOutset
            $0.widthAnchor == Layout.imageSize.width
            placeImage.centerXAnchor == $0.centerXAnchor
            placeImage.bottomAnchor == $0.bottomAnchor
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

        return holder
    }

    var categoryStack: UIStackView {
        let categoryStack = UIStackView(arrangedSubviews: [categoryLabel,
                                                           visitedLabel,
                                                           visitSwitch])
        categoryStack.alignment = .center

        return categoryStack
    }

    var detailStack: UIStackView {
        let detailStack = UIStackView(arrangedSubviews: [nameLabel,
                                                         countryLabel,
                                                         visitorsLabel])
        detailStack.axis = .vertical
        detailStack.spacing = 0

        return detailStack
    }
}
