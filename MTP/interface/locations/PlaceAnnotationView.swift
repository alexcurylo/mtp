// @copyright Trollwerks Inc.

import MapKit

final class PlaceAnnotationView: MKMarkerAnnotationView, ServiceProvider {

    override init(annotation: MKAnnotation?,
                  reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        clusteringIdentifier = PlaceClusterAnnotationView.identifier
        collisionMode = .circle
        canShowCallout = true
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()
        guard let place = annotation as? PlaceAnnotation else { return }

        log.todo("implement PlaceAnnotationView")

        markerTintColor = place.background
        glyphImage = place.listImage

        #if VISIT_TOGGLE
        let visit = UISwitch {
            $0.styleAsFilter()
            $0.isOn = place.visited
            $0.addTarget(self,
                         action: #selector(toggleVisit),
                         for: .valueChanged)
        }
        rightCalloutAccessoryView = visit
        #endif

        let showMore = GradientButton {
            $0.orientation = GradientOrientation.horizontal.rawValue
            $0.startColor = .dodgerBlue
            $0.endColor = .azureRadiance
            $0.cornerRadius = 4
            $0.contentEdgeInsets = UIEdgeInsets(
                top: 8,
                left: 16,
                bottom: 8,
                right: 16)

            let title = Localized.showMore()
            $0.setTitle(title, for: .normal)
            $0.titleLabel?.font = Avenir.heavy.of(size: 18)
            $0.addTarget(self,
                         action: #selector(showMoreTapped),
                         for: .touchUpInside)
        }
        detailCalloutAccessoryView = showMore
   }

    override func prepareForReuse() {
        super.prepareForReuse()

        markerTintColor = nil
        glyphImage = nil
        rightCalloutAccessoryView = nil
        detailCalloutAccessoryView = nil
        annotation = nil
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
}
