// @copyright Trollwerks Inc.

import MapKit
import RealmMapView

typealias MappablesAnnotation = Annotation

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

    func zoom(to mappable: Mappable, callout: Bool) {
        zoom(center: mappable.coordinate) { [weak self] in
            if callout {
                self?.select(mappable: mappable)
            }
        }
    }

    func close(mappable: Mappable) {
        guard let shown = shown(for: mappable) else { return }

        deselectAnnotation(shown, animated: false)
    }

    func update(mappable: Mappable) {
        guard let contains = contains(mappable: mappable) else { return }

        removeAnnotation(contains)
        addAnnotation(contains)
    }

    func display(view: MappableAnnotationView) {
        guard let mappable = view.mappable else { return }

        view.prepareForCallout()
        update(overlays: mappable)
        #if TEST_TRIGGER_ON_SELECTION
        mappable._testTrigger(background: false)
        #endif
    }

    func expand(view: MappablesAnnotationView) {
        guard let mapped = view.mapped else { return }

        deselectAnnotation(mapped, animated: false)
        zoom(into: mapped)
    }

    override func refreshMapView(refreshRegion: MKCoordinateRegion? = nil,
                                 refreshMapRect: MKMapRect? = nil) {
        let bigger = refreshRegion ?? region.expanded(by: 1.2)
        super.refreshMapView(refreshRegion: bigger,
                             refreshMapRect: refreshMapRect)
    }

    override func didUpdateAnnotations() {
        guard !completions.isEmpty else { return }

        let pending = completions
        completions = []
        serialWorkQueue.addOperation {
            DispatchQueue.main.async {
                pending.forEach { $0() }
            }
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
        MappableAnnotationView.register(view: self)
        MappablesAnnotationView.register(view: self)
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
        guard let shown = shown(for: mappable) else { return }

        selectAnnotation(shown, animated: true)
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

    func contains(mappable: Mappable) -> MappablesAnnotation? {
        for contains in annotations {
            if let contains = contains as? MappablesAnnotation,
                contains.contains(mappable: mappable) {
                return contains
            }
        }
        return nil
    }

    func shown(for mappable: Mappable) -> MappablesAnnotation? {
        for shown in annotations {
            if let shown = shown as? MappablesAnnotation,
               shown.shows(only: mappable) {
                return shown
            }
        }

        log.error("Could not find annotation for \(mappable)")
        return nil
    }

    func zoom(into shown: MappablesAnnotation) {
        var zoomed = region
        let contents = shown.region
        zoomed.center = shown.coordinate
        zoomed.span.latitudeDelta = contents.maxDelta * 1.3
        zoomed.span.longitudeDelta = contents.maxDelta * 1.3
        zoom(region: zoomed)
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
            if let then = then {
                self?.animateZoom(region: region, then: then)
            } else {
                self?.setRegion(region, animated: true)
            }
        }
    }

    func animateZoom(region: MKCoordinateRegion,
                     then: @escaping Completion) {
        assert(Thread.isMainThread)

        MKMapView.animate(
            withDuration: 1,
            animations: {
                self.setRegion(region, animated: true)
            },
            completion: { [weak self] _ in
                self?.animated(then: then)
            }
        )
    }

    func animated(then: @escaping Completion) {
        assert(Thread.isMainThread)

        if isUpdatingAnnotations {
            objc_sync_enter(self)
            completions.append(then)
            objc_sync_exit(self)
        } else {
            then()
        }
    }
}

extension MappablesAnnotation {

    var isSingle: Bool {
        return type == .unique
    }
    var isMultiple: Bool {
        return type == .cluster
    }
    var count: Int {
        return safeObjects.count
    }

    var mappable: Mappable? {
        return isSingle ? mappables[0] : nil
    }
    var mappables: [Mappable] {
        return safeObjects.map { $0.toObject(Mappable.self) }
    }
    var region: ClusterRegion {
        return ClusterRegion(mappables: self)
    }

    func contains(mappable: Mappable) -> Bool {
        return mappables.contains { $0 == mappable }
    }

    func shows(only: Mappable) -> Bool {
        return only == mappable
    }
}

extension MKCoordinateRegion {

    var mapRect: MKMapRect { return MKMapRect() }

    func expanded(by factor: Double) -> MKCoordinateRegion {
        var expanded = self
        expanded.span.latitudeDelta *= factor
        expanded.span.longitudeDelta *= factor
        return expanded
    }
}
