// @copyright Trollwerks Inc.

import Anchorage
import MapKit
import RealmMapView

final class MappablesAnnotationView: MKAnnotationView, ServiceProvider {

    static var identifier = typeName

    static func register(view: MKMapView) {
        view.register(self, forAnnotationViewWithReuseIdentifier: identifier)
    }

    static func view(on map: MKMapView,
                     for annotation: MappablesAnnotation) -> MKAnnotationView {
        let view = map.dequeueReusableAnnotationView(
            withIdentifier: MappablesAnnotationView.identifier,
            for: annotation
        )

        (view as? MappablesAnnotationView)?.annotation = annotation
        view.canShowCallout = annotation.isSingle

        return view
    }

    var mapped: MappablesAnnotation? {
        return annotation as? MappablesAnnotation
    }
    var isSingle: Bool {
        return mapped?.isSingle ?? false
    }
    var isMultiple: Bool {
        return mapped?.isMultiple ?? false
    }

    var mappable: Mappable? {
        return mapped?.mappable
    }
    var mappables: [Mappable] {
        return mapped?.mappables ?? []
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        canShowCallout = true
        collisionMode = .circle
        centerOffset = CGPoint(x: 0, y: -10)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()

        switch mapped {
        case let single? where single.isSingle:
            image = mapped?.drawSingle()
        case let multiple? where multiple.isMultiple:
            image = mapped?.drawMultiple()
        default:
            break
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        headerImageView.prepareForReuse()
        image = nil
        annotation = nil
    }

    private enum Layout {
        static let width = CGFloat(260)
        static let imageSize = CGSize(width: width, height: 150)
        static let closeOutset = CGFloat(6)
    }

    private let headerImageView = UIImageView {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFill
        $0.sizeAnchors == Layout.imageSize
        $0.clipsToBounds = true
    }

    func prepareForCallout() {
        guard let mappable = mappable,
                  headerImageView.image == nil else { return }

        headerImageView.load(image: mappable)
    }
}
