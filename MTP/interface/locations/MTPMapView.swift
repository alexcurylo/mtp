// @copyright Trollwerks Inc.

import MapKit

extension CLLocationDistance {

    /// Default map span for an annotation
    static let annotationSpan = CLLocationDistance(500)
    /// Default map span for device location
    static let deviceSpan = CLLocationDistance(160_000)
}

/// Displays locations
final class MTPMapView: RealmMapView, ServiceProvider {

    /// Callback handler type
    typealias Completion = () -> Void

    /// Which location types to display
    var displayed = ChecklistFlags() {
        didSet {
            if displayed != oldValue {
                updateFilter()
            }
        }
    }

    /// Compass button
    var compass: MKCompassButton? {
        guard showsCompass else { return nil }

        showsCompass = false
        return MKCompassButton(mapView: self).with {
            $0.compassVisibility = .visible
        }
    }

    /// Tracking and legend stack
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

    /// Has the map been centered on a location?
    var isCentered = false
    private var completions: [Completion] = []
    private var visitedObserver: Observer?

    /// :nodoc:
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        defer {
            displayed = data.mapDisplay
        }
        configure()
        register()
        observe()
    }

    /// Center map on device
    func centerOnDevice() {
        guard !isCentered, let here = loc.here else { return }

        zoom(center: here,
             latitudeSpan: .deviceSpan,
             longitudeSpan: .deviceSpan)
    }

    /// Zoom map to coordinate
    ///
    /// - Parameter center: Center
    func zoom(to center: CLLocationCoordinate2D) {
        zoom(center: center)
    }

    /// Zoom map to place
    ///
    /// - Parameters:
    ///   - mappable: Place
    ///   - callout: Show callout?
    func zoom(to mappable: Mappable, callout: Bool) {
        zoom(center: mappable.coordinate) { [weak self] in
            if callout {
                self?.select(mappable: mappable)
            }
        }
    }

    /// Close place annotation view
    ///
    /// - Parameter mappable: Place
    func close(mappable: Mappable) {
        guard let shown = shown(for: mappable) else { return }

        deselectAnnotation(shown, animated: false)
    }

    /// Update place display
    ///
    /// - Parameter mappable: Place
    func update(mappable: Mappable) {
        guard let contains = contains(mappable: mappable) else { return }

        removeAnnotation(contains)
        addAnnotation(contains)
    }

    /// Handle annotation view display
    ///
    /// - Parameter view: Place view
    func display(view: MappableAnnotationView) {
        guard let mappable = view.mappable else { return }

        view.prepareForCallout()
        update(overlays: mappable)
        #if TEST_TRIGGER_ON_SELECTION
        mappable._testTrigger(background: false)
        #endif
    }

    /// Expand to region covered by annotation
    ///
    /// - Parameter view: Places view
    func expand(view: MappablesAnnotationView) {
        guard let mapped = view.mapped else { return }

        deselectAnnotation(mapped, animated: false)
        zoom(into: mapped)
    }

    /// Refresh region override to expand enough to collect just offscreens
    ///
    /// - Parameters:
    ///   - refreshRegion: Region to refresh
    ///   - refreshMapRect: Map rect to refresh
    override func refreshMapView(refreshRegion: MKCoordinateRegion? = nil,
                                 refreshMapRect: MKMapRect? = nil) {
        let bigger = refreshRegion ?? region.expanded(by: 1.2)
        super.refreshMapView(refreshRegion: bigger,
                             refreshMapRect: refreshMapRect)
    }

    /// Schedule operations after map update
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
        basePredicate = nil
    }

    func register() {
        MappableAnnotationView.register(view: self)
        MappablesAnnotationView.register(view: self)
    }

    func observe() {
        visitedObserver = data.observer(of: .visited) { [weak self] _ in
            guard let self = self else { return }

            if let selected = self.selected {
                self.update(overlays: selected)
            }
            let center = self.centerCoordinate
            self.centerCoordinate = .zero
            self.centerCoordinate = center
        }
    }

    var selected: Mappable? {
        switch selectedAnnotations.first {
        case let mappables as MappablesAnnotation:
            return mappables.mappable
        default:
            return nil
        }
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

        log.info("Could not find annotation for \(mappable)")
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

    /// Convenience accessor for uniqueness
    var isSingle: Bool {
        return type == .unique
    }
    /// Convenience accessor for multiplicity
    var isMultiple: Bool {
        return type == .cluster
    }
    /// Number of places
    var count: Int {
        return safeObjects.count
    }

    /// Convenience accessor for unique place
    var mappable: Mappable? {
        return isSingle ? mappables[0] : nil
    }
    /// Convenience accessor for place(s) list
    var mappables: [Mappable] {
        return safeObjects.map { $0.toObject(Mappable.self) }
    }
    /// Region containing place(s)
    var region: ClusterRegion {
        return ClusterRegion(mappables: self)
    }

    /// Whether this annotation contains a particular place
    ///
    /// - Parameter mappable: Place
    /// - Returns: Containment
    func contains(mappable: Mappable) -> Bool {
        return mappables.contains { $0 == mappable }
    }

    /// Whether this annotation is a particular place
    ///
    /// - Parameter only: Place
    /// - Returns: Identity
    func shows(only: Mappable) -> Bool {
        return only == mappable
    }
}

private extension MKCoordinateRegion {

    var mapRect: MKMapRect { return MKMapRect() }

    func expanded(by factor: Double) -> MKCoordinateRegion {
        var expanded = self
        expanded.span.latitudeDelta *= factor
        expanded.span.longitudeDelta *= factor
        return expanded
    }
}
