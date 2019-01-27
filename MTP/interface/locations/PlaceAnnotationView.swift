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
   }

    override func prepareForReuse() {
        markerTintColor = nil
        glyphImage = nil
        annotation = nil
        super.prepareForReuse()
    }
}
