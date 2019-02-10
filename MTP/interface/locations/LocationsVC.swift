// @copyright Trollwerks Inc.

// swiftlint:disable file_length

import Anchorage
import MapKit

final class LocationsVC: UIViewController {

    @IBOutlet private var mapView: MKMapView?
    @IBOutlet private var searchBar: UISearchBar?

    let locationManager = CLLocationManager()
    private var trackingButton: MKUserTrackingButton?
    private var centered = false

    private var beachesObserver: Observer?
    private var divesitesObserver: Observer?
    private var golfcoursesObserver: Observer?
    private var locationsObserver: Observer?
    private var restaurantsObserver: Observer?
    private var uncountriesObserver: Observer?
    private var whssObserver: Observer?

    private var beachesAnnotations: Set<PlaceAnnotation> = []
    private var divesitesAnnotations: Set<PlaceAnnotation> = []
    private var golfcoursesAnnotations: Set<PlaceAnnotation> = []
    private var locationsAnnotations: Set<PlaceAnnotation> = []
    private var restaurantsAnnotations: Set<PlaceAnnotation> = []
    private var uncountriesAnnotations: Set<PlaceAnnotation> = []
    private var whssAnnotations: Set<PlaceAnnotation> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCompass()
        setupTracking()
        setupAnnotations()
        trackingButton?.set(visibility: start(tracking: .dontAsk))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .map)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        trackingButton?.set(visibility: start(tracking: .ask))
        zoomAndCenter()
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        log.verbose("prepare for \(segue.name)")
        switch segue.identifier {
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

private extension LocationsVC {

    enum Layout {
        static let margin = CGFloat(16)
    }

    @IBAction func unwindToLocations(segue: UIStoryboardSegue) {
        log.verbose(segue.name)
    }

    func setupCompass() {
        guard let map = mapView, map.showsCompass == true else { return }
        let compass = MKCompassButton(mapView: mapView)
        compass.compassVisibility = .visible
        view.addSubview(compass)
        compass.topAnchor == view.safeAreaLayoutGuide.topAnchor + Layout.margin
        compass.trailingAnchor == view.trailingAnchor - Layout.margin
        map.showsCompass = false
    }

    func setupTracking() {
        mapView?.showsUserLocation = true

        let tracker = MKUserTrackingButton(mapView: mapView)
        tracker.layer.backgroundColor = UIColor(white: 1, alpha: 0.8).cgColor
        tracker.layer.borderColor = UIColor.white.cgColor
        tracker.layer.borderWidth = 1
        tracker.layer.cornerRadius = 5
        tracker.isHidden = true
        view.addSubview(tracker)
        trackingButton = tracker

        let scale = MKScaleView(mapView: mapView)
        scale.legendAlignment = .trailing
        view.addSubview(scale)

        let stack = UIStackView(arrangedSubviews: [scale, tracker])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10
        view.addSubview(stack)

        stack.bottomAnchor == view.safeAreaLayoutGuide.bottomAnchor - Layout.margin
        stack.trailingAnchor == view.trailingAnchor - Layout.margin
    }

    func zoomAndCenter() {
        guard !centered,
              let here = locationManager.location?.coordinate else { return }

        centered = true
        let viewRegion = MKCoordinateRegion(center: here,
                                            latitudinalMeters: 200,
                                            longitudinalMeters: 200)
        DispatchQueue.main.async { [weak self] in
            self?.mapView?.setRegion(viewRegion, animated: true)
        }
    }

    func setupAnnotations() {
        registerAnnotationViews()
        observe()

        showBeaches()
        showDiveSites()
        showGolfCourses()
        showLocations()
        showRestaurants()
        showUNCountries()
        showWHSs()
    }

    func observe() {
        beachesObserver = Checklist.beaches.observer { [weak self] _ in
            self?.showBeaches()
        }
        divesitesObserver = Checklist.divesites.observer { [weak self] _ in
            self?.showDiveSites()
        }
        golfcoursesObserver = Checklist.golfcourses.observer { [weak self] _ in
            self?.showGolfCourses()
        }
        locationsObserver = Checklist.locations.observer { [weak self] _ in
            self?.showBeaches()
        }
        restaurantsObserver = Checklist.restaurants.observer { [weak self] _ in
            self?.showRestaurants()
        }
        uncountriesObserver = Checklist.uncountries.observer { [weak self] _ in
            self?.showUNCountries()
        }
        whssObserver = Checklist.whss.observer { [weak self] _ in
            self?.showWHSs()
        }
    }

    func registerAnnotationViews() {
        Checklist.allCases.forEach {
            mapView?.register(
                PlaceAnnotationView.self,
                forAnnotationViewWithReuseIdentifier: $0.rawValue
            )
        }
        mapView?.register(
            PlaceClusterAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: PlaceClusterAnnotationView.identifier
        )
    }

    func showBeaches() {
        let new = Set<PlaceAnnotation>(data.beaches.map { place in
            PlaceAnnotation(type: .beaches,
                            id: place.id,
                            coordinate: place.coordinate,
                            title: place.title,
                            subtitle: place.subtitle)
        })

        let subtracted = beachesAnnotations.subtracting(new)
        mapView?.removeAnnotations(Array(subtracted))
        beachesAnnotations.subtract(subtracted)

        let added = new.subtracting(beachesAnnotations)
        mapView?.addAnnotations(Array(added))
        beachesAnnotations.formUnion(added)
    }

    func showDiveSites() {
        let new = Set<PlaceAnnotation>(data.divesites.map { place in
            PlaceAnnotation(type: .divesites,
                            id: place.id,
                            coordinate: place.coordinate,
                            title: place.title,
                            subtitle: place.subtitle)
        })

        let subtracted = divesitesAnnotations.subtracting(new)
        mapView?.removeAnnotations(Array(subtracted))
        divesitesAnnotations.subtract(subtracted)

        let added = new.subtracting(divesitesAnnotations)
        mapView?.addAnnotations(Array(added))
        divesitesAnnotations.formUnion(added)
    }

    func showGolfCourses() {
        let new = Set<PlaceAnnotation>(data.golfcourses.map { place in
            PlaceAnnotation(type: .golfcourses,
                            id: place.id,
                            coordinate: place.coordinate,
                            title: place.title,
                            subtitle: place.subtitle)
        })

        let subtracted = golfcoursesAnnotations.subtracting(new)
        mapView?.removeAnnotations(Array(subtracted))
        golfcoursesAnnotations.subtract(subtracted)

        let added = new.subtracting(golfcoursesAnnotations)
        mapView?.addAnnotations(Array(added))
        golfcoursesAnnotations.formUnion(added)
    }

    func showLocations() {
        let new = Set<PlaceAnnotation>(data.locations.map { place in
            PlaceAnnotation(type: .locations,
                            id: place.id,
                            coordinate: place.coordinate,
                            title: place.title,
                            subtitle: place.subtitle)
        })

        let subtracted = locationsAnnotations.subtracting(new)
        mapView?.removeAnnotations(Array(subtracted))
        locationsAnnotations.subtract(subtracted)

        let added = new.subtracting(locationsAnnotations)
        mapView?.addAnnotations(Array(added))
        locationsAnnotations.formUnion(added)
    }

    func showRestaurants() {
        let new = Set<PlaceAnnotation>(data.restaurants.map { place in
            PlaceAnnotation(type: .restaurants,
                            id: place.id,
                            coordinate: place.coordinate,
                            title: place.title,
                            subtitle: place.subtitle)
        })

        let subtracted = restaurantsAnnotations.subtracting(new)
        mapView?.removeAnnotations(Array(subtracted))
        restaurantsAnnotations.subtract(subtracted)

        let added = new.subtracting(restaurantsAnnotations)
        mapView?.addAnnotations(Array(added))
        restaurantsAnnotations.formUnion(added)
    }

    func showUNCountries() {
        let new = Set<PlaceAnnotation>(data.uncountries.map { place in
            PlaceAnnotation(type: .uncountries,
                            id: place.id,
                            coordinate: place.coordinate,
                            title: place.title,
                            subtitle: place.subtitle)
        })

        let subtracted = uncountriesAnnotations.subtracting(new)
        mapView?.removeAnnotations(Array(subtracted))
        uncountriesAnnotations.subtract(subtracted)

        let added = new.subtracting(uncountriesAnnotations)
        mapView?.addAnnotations(Array(added))
        uncountriesAnnotations.formUnion(added)
    }

    func showWHSs() {
        let new = Set<PlaceAnnotation>(data.whss.map { place in
            PlaceAnnotation(type: .whss,
                            id: place.id,
                            coordinate: place.coordinate,
                            title: place.title,
                            subtitle: place.subtitle)
        })

        let subtracted = whssAnnotations.subtracting(new)
        mapView?.removeAnnotations(Array(subtracted))
        whssAnnotations.subtract(subtracted)

        let added = new.subtracting(whssAnnotations)
        mapView?.addAnnotations(Array(added))
        whssAnnotations.formUnion(added)
    }
}

extension LocationsVC: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView,
                 regionWillChangeAnimated: Bool) {
    }
    func mapView(_ mapView: MKMapView,
                 regionDidChangeAnimated: Bool) {
    }

    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
    }
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
    }
    func mapViewDidFailLoadingMap(_ mapView: MKMapView) {
        log.error(#function)
    }

    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
    }
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView,
                                      fullyRendered: Bool) {
    }

    func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
    }
    func mapViewDidStopLocatingUser(_ mapView: MKMapView) {
    }
    func mapView(_ mapView: MKMapView,
                 didUpdate userLocation: MKUserLocation) {
        zoomAndCenter()
    }
    func mapView(_ mapView: MKMapView,
                 didFailToLocateUserWithError error: Error) {
        log.error(#function)
    }
    func mapView(_ mapView: MKMapView,
                 didChange mode: MKUserTrackingMode,
                 animated: Bool) {
    }

    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case let place as PlaceAnnotation:
            return mapView.dequeueReusableAnnotationView(
                withIdentifier: place.identifier,
                for: place
            )
        case let cluster as MKClusterAnnotation:
            return mapView.dequeueReusableAnnotationView(
                withIdentifier: PlaceClusterAnnotationView.identifier,
                for: cluster
            )
        case is MKUserLocation:
            return nil
        default:
            log.debug("unexpected annotation: \(annotation)")
            return nil
        }
    }
    func mapView(_ mapView: MKMapView,
                 didAdd views: [MKAnnotationView]) {
    }
    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        guard !(control is UISwitch) else { return }
        log.verbose(#function)
    }
    func mapView(_ mapView: MKMapView,
                 didSelect view: MKAnnotationView) {
    }
    func mapView(_ mapView: MKMapView,
                 didDeselect view: MKAnnotationView) {
    }
    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 didChange newState: MKAnnotationView.DragState,
                 fromOldState oldState: MKAnnotationView.DragState) {
    }

    func mapView(_ mapView: MKMapView,
                 rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        log.verbose(#function)
        return MKOverlayRenderer(overlay: overlay)
    }
    func mapView(_ mapView: MKMapView,
                 didAdd renderers: [MKOverlayRenderer]) {
        log.verbose(#function)
    }

    func mapView(_ mapView: MKMapView,
                 clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
        return MKClusterAnnotation(memberAnnotations: memberAnnotations)
    }
}

extension LocationsVC: LocationTracker {

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
    }
    func locationManager(_ manager: CLLocationManager,
                         didUpdateHeading newHeading: CLHeading) {
    }
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }

    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
    }
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
    }

    func locationManager(_ manager: CLLocationManager,
                         didDetermineState state: CLRegionState,
                         for region: CLRegion) {
    }
    func locationManager(_ manager: CLLocationManager,
                         didEnterRegion region: CLRegion) {
    }
    func locationManager(_ manager: CLLocationManager,
                         didExitRegion region: CLRegion) {
    }
    func locationManager(_ manager: CLLocationManager,
                         didRangeBeacons beacons: [CLBeacon],
                         in region: CLBeaconRegion) {
    }
    func locationManager(_ manager: CLLocationManager,
                         rangingBeaconsDidFailFor region: CLBeaconRegion,
                         withError error: Error) {
    }

    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        log.error(#function)
    }

    func locationManager(_ manager: CLLocationManager,
                         didStartMonitoringFor region: CLRegion) {
    }
    func locationManager(_ manager: CLLocationManager,
                         monitoringDidFailFor region: CLRegion?,
                         withError error: Error) {
        log.error(#function)
    }

    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.trackingButton?.set(visibility: self.start(tracking: .ask))
            self.zoomAndCenter()
        }
    }

    func locationManager(_ manager: CLLocationManager,
                         didFinishDeferredUpdatesWithError error: Error?) {
        log.error(#function)
    }

    func locationManager(_ manager: CLLocationManager,
                         didVisit visit: CLVisit) {
    }
}

private extension MKUserTrackingButton {

    func set(visibility forStatus: CLAuthorizationStatus) {
        let authorized: Bool
        switch forStatus {
        case .authorizedWhenInUse,
             .authorizedAlways:
            authorized = true
        case .denied,
             .notDetermined,
             .restricted:
            authorized = false
        }
        isHidden = !authorized
    }
}
