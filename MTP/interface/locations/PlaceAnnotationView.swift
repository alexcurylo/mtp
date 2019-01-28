// @copyright Trollwerks Inc.

import MapKit

final class PlaceAnnotationView: MKMarkerAnnotationView {

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

        markerTintColor = place.background
        glyphImage = place.image
        let visit: UISwitch = create {
            $0.isOn = place.visited
            $0.addTarget(self,
                         action: #selector(toggleVisit),
                         for: .valueChanged)
        }
        rightCalloutAccessoryView = visit
   }

    override func prepareForReuse() {
        super.prepareForReuse()

        markerTintColor = nil
        glyphImage = nil
        rightCalloutAccessoryView = nil
        annotation = nil
    }
}

private extension PlaceAnnotationView {

    @objc func toggleVisit(_ sender: UISwitch) {
        guard let place = annotation as? PlaceAnnotation else { return }
        place.visited = sender.isOn
    }
}
