// @copyright Trollwerks Inc.

import MapKit
import RealmMapView

typealias MappableAnnotation = Annotation
typealias MappableClusterAnnotationView = ClusterAnnotationView

extension CLLocationDistance {

    static let annotationSpan = CLLocationDistance(500)
    static let deviceSpan = CLLocationDistance(160_000)
}

final class MTPMapView: RealmMapView, ServiceProvider {

    typealias Completion = () -> Void

    var displayed = ChecklistFlags() {
        didSet {
            if displayed != oldValue {
                updateFilter()
            }
        }
    }

    var compass: MKCompassButton? {
        guard showsCompass else { return nil }

        showsCompass = false
        return MKCompassButton(mapView: self).with {
            $0.compassVisibility = .visible
        }
    }

    var infoStack: UIStackView {
        showsUserLocation = true

        let tracker = MKUserTrackingButton(mapView: self).with {
            $0.layer.backgroundColor = UIColor(white: 1, alpha: 0.8).cgColor
            $0.layer.borderColor = UIColor.white.cgColor
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 5
            $0.isHidden = true
        }

        let scale = MKScaleView(mapView: self)
        scale.legendAlignment = .trailing

        let stack = UIStackView(arrangedSubviews: [scale,
                                                   tracker]).with {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.spacing = 10
        }

        return stack
    }

    var isCentered = false

    var completions: [Completion] = []

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        defer {
            displayed = data.mapDisplay
        }
        configure()
        register()
    }

    func centerOnDevice() {
        guard !isCentered, let here = loc.here else { return }

        zoom(center: here,
             latitudeSpan: .deviceSpan,
             longitudeSpan: .deviceSpan)
    }

    func zoom(to center: CLLocationCoordinate2D) {
        zoom(center: center)
    }

    func zoom(to place: PlaceAnnotation, callout: Bool) {
        zoom(center: place.coordinate) { [weak self] in
            if callout {
                self?.selectAnnotation(place, animated: false)
            }
        }
    }

    func zoom(to mappable: Mappable, callout: Bool) {
        zoom(center: mappable.coordinate) { [weak self] in
            if callout {
                self?.select(mappable: mappable)
            }
        }
    }

    func zoom(to cluster: MKClusterAnnotation) {
        let clustered = cluster.region
        var newRegion = region
        newRegion.center = cluster.coordinate
        newRegion.span.latitudeDelta = clustered.maxDelta * 1.3
        newRegion.span.longitudeDelta = clustered.maxDelta * 1.3
        zoom(region: newRegion)
    }

    func update(overlays mappable: Mappable) {
        let current = overlays.filter { $0 is MappableOverlay }
        if let first = current.first as? MappableOverlay,
           first.shows(mappable: mappable) {
            return
        }

        removeOverlays(current)
        let overlays = mappable.overlays
        if !overlays.isEmpty {
            addOverlays(overlays)
        }
    }

    override func didRefreshMap() {
        // log.todo("don't trigger until addAnnotationsToMapView completes!")
        // log.todo("expose mapQueue and BlockOperation this")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            objc_sync_enter(self)
            self.completions.forEach { $0() }
            self.completions = []
            objc_sync_exit(self)
        }
    }
}

// MARK: - Private

private extension MTPMapView {

    func configure() {
        Mappable.configure(map: self)

        clusterAnnotations = true
        autoRefresh = true
        zoomOnFirstRefresh = false
        animateAnnotations = true
        canShowCallout = true
        maxZoomLevelForClustering = 20
        resultsLimit = -1
        basePredicate = nil
    }

    func register() {
        Checklist.allCases.forEach {
            register(PlaceAnnotationView.self,
                     forAnnotationViewWithReuseIdentifier: $0.key)
        }
        register(PlaceClusterAnnotationView.self,
                 forAnnotationViewWithReuseIdentifier: PlaceClusterAnnotationView.identifier)
    }

    func updateFilter() {
        let show = Checklist.allCases.compactMap {
            $0.isMappable && displayed.display(list: $0) ? $0.rawValue : nil
        }
        if show.count == ChecklistFlags.mappableCount {
            basePredicate = nil
        } else {
            basePredicate = NSPredicate(format: "checklistValue IN %@", show)
        }
        refreshMapView()
    }

    func select(mappable: Mappable) {
        guard let shown = annotation(mappable: mappable) else { return }

        selectAnnotation(shown, animated: false)
    }

    func annotation(mappable: Mappable) -> MappableAnnotation? {
        for annotation in annotations {
            if let annotation = annotation as? MappableAnnotation,
               annotation.shows(mappable: mappable) {
                return annotation
            }
        }

        log.error("Could not find annotation for \(mappable)")
        note.unimplemented()
        return nil
    }

    func zoom(center: CLLocationCoordinate2D,
              latitudeSpan: CLLocationDistance = .annotationSpan,
              longitudeSpan: CLLocationDistance = .annotationSpan,
              then: Completion? = nil) {
        isCentered = true
        let region = MKCoordinateRegion(center: center,
                                        latitudinalMeters: latitudeSpan,
                                        longitudinalMeters: longitudeSpan)
        zoom(region: region, then: then)
    }

    func zoom(region: MKCoordinateRegion,
              then: Completion? = nil) {
        DispatchQueue.main.async { [weak self] in
            MKMapView.animate(
                withDuration: 1,
                animations: {
                    self?.setRegion(region, animated: true)
                },
                completion: { _ in
                    guard let then = then else { return }

                    if let self = self, self.isRefreshingMap {
                        objc_sync_enter(self)
                        self.completions.append(then)
                        objc_sync_exit(self)
                    } else {
                        then()
                    }
                }
            )
        }
    }
}

extension MappableAnnotation {

    var only: Mappable? {
        if safeObjects.count != 1 {
            return nil
        } else {
            return safeObjects.first?.toObject(Mappable.self)
        }
    }

    func shows(mappable: Mappable) -> Bool {
        guard let only = only else {
            return false
        }

        let same = only == mappable
        return same
    }
}

extension MappableClusterAnnotationView {

    var objects: [LocationSafeRealmObject] {
        return MappableClusterAnnotationView.safeObjects(forClusterAnnotationView: self) ?? []
    }

    var only: Mappable? {
        let array = objects
        if array.count != 1 {
            return nil
        } else {
            return array.first?.toObject(Mappable.self)
        }
    }
}
