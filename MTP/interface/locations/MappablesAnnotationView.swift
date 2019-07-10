// @copyright Trollwerks Inc.

import MapKit
import RealmMapView

final class MappablesAnnotationView: ClusterAnnotationView, ServiceProvider {

    static var identifier = typeName

    static func register(view: MKMapView) {
        view.register(self, forAnnotationViewWithReuseIdentifier: identifier)
    }

    static func view(on map: MKMapView,
                     for annotation: MappablesAnnotation) -> MappablesAnnotationView {
        let view = map.dequeueReusableAnnotationView(
            withIdentifier: MappablesAnnotationView.identifier
        //swiftlint:disable:next force_cast
        ) as! MappablesAnnotationView

        view.annotation = annotation
        view.canShowCallout = true

        view.log.todo("implement safeObjects to count directly")
        view.count = annotation.count

        return view
    }

    func prepareForCallout() {
        log.todo("implement prepareForCallout")
        #if OBSOLETE
        guard let place = place,
            placeImage.image == nil else { return }

        placeImage.load(image: place)
        #endif
    }

    override func draw(_ rect: CGRect) {
        log.todo("implement draw")
        super.draw(rect)
    }
}
