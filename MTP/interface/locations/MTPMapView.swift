// @copyright Trollwerks Inc.

import MapKit
import RealmMapView

final class MTPMapView: RealmMapView, ServiceProvider {

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

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        defer {
            displayed = data.mapDisplay
        }
        configure()
        register()
    }

    func zoom(cluster: MKClusterAnnotation?) {
        guard let cluster = cluster else { return }

        let clustered = cluster.region
        var newRegion = region
        newRegion.center = cluster.coordinate
        newRegion.span.latitudeDelta = clustered.maxDelta * 1.3
        newRegion.span.longitudeDelta = clustered.maxDelta * 1.3
        zoom(region: newRegion, then: nil)
    }

    func zoom(region: MKCoordinateRegion,
              then: (() -> Void)?) {
        DispatchQueue.main.async { [weak self] in
            MKMapView.animate(
                withDuration: 1,
                animations: {
                    self?.setRegion(region, animated: true)
                },
                completion: { _ in
                    then?()
                }
            )
        }
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
}
