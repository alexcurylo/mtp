// @copyright Trollwerks Inc.

import MapKit

final class PlaceAnnotationView: MKMarkerAnnotationView {

    static let cluster = NSStringFromClass(PlaceAnnotationView.self)

    override init(annotation: MKAnnotation?,
                  reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = PlaceAnnotationView.cluster
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()
        guard let place = annotation as? PlaceAnnotation else { return }

        displayPriority = .required
        markerTintColor = place.background
        glyphImage = place.image
        canShowCallout = true
   }

    override func prepareForReuse() {
        markerTintColor = nil
        glyphImage = nil
        super.prepareForReuse()
    }
}
