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
        beachesObserver = Checklist.beaches.observer { [weak self] in
            self?.showBeaches()
        }
        divesitesObserver = Checklist.divesites.observer { [weak self] in
            self?.showDiveSites()
        }
        golfcoursesObserver = Checklist.golfcourses.observer { [weak self] in
            self?.showGolfCourses()
        }
        locationsObserver = Checklist.locations.observer { [weak self] in
            self?.showBeaches()
        }
        restaurantsObserver = Checklist.restaurants.observer { [weak self] in
            self?.showRestaurants()
        }
        uncountriesObserver = Checklist.uncountries.observer { [weak self] in
            self?.showUNCountries()
        }
        whssObserver = Checklist.whss.observer { [weak self] in
            self?.showWHSs()
        }
    }

    func showBeaches() {
        let new = Set<PlaceAnnotation>(gestalt.beaches.map { place in
            PlaceAnnotation(type: .beaches,
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
        let new = Set<PlaceAnnotation>(gestalt.divesites.map { place in
            PlaceAnnotation(type: .divesites,
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
        let new = Set<PlaceAnnotation>(gestalt.golfcourses.map { place in
            PlaceAnnotation(type: .golfcourses,
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
        let new = Set<PlaceAnnotation>(gestalt.locations.map { place in
            PlaceAnnotation(type: .locations,
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
        let new = Set<PlaceAnnotation>(gestalt.restaurants.map { place in
            PlaceAnnotation(type: .restaurants,
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
        let new = Set<PlaceAnnotation>(gestalt.uncountries.map { place in
            PlaceAnnotation(type: .uncountries,
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
        let new = Set<PlaceAnnotation>(gestalt.whss.map { whs in
            PlaceAnnotation(type: .whss,
                            coordinate: whs.coordinate,
                            title: whs.title,
                            subtitle: whs.subtitle)
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

    func mapView(_ mapView: MKMapView, regionWillChangeAnimated: Bool) {
        log.verbose(#function)
    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated: Bool) {
        log.verbose(#function)
    }

    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        log.verbose(#function)
    }
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        log.verbose(#function)
    }
    func mapViewDidFailLoadingMap(_ mapView: MKMapView) {
        log.verbose(#function)
    }

    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
        log.verbose(#function)
    }
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        log.verbose(#function)
    }

    func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
        log.verbose(#function)
    }
    func mapViewDidStopLocatingUser(_ mapView: MKMapView) {
        log.verbose(#function)
    }
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        log.verbose(#function)
        zoomAndCenter()
    }
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        log.verbose(#function)
    }
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        log.verbose(#function)
    }

    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        log.verbose(#function)
        if annotation is MKUserLocation { return nil }

        let annotationView = mapView.dequeueReusableAnnotationView(
            withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier,
            for: annotation)
        annotationView.clusteringIdentifier = "identifier"
        return annotationView
    }
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        log.verbose(#function)
    }
    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        log.verbose(#function)
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        log.verbose(#function)
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        log.verbose(#function)
    }
    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 didChange newState: MKAnnotationView.DragState,
                 fromOldState oldState: MKAnnotationView.DragState) {
        log.verbose(#function)
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        log.verbose(#function)
        return MKOverlayRenderer(overlay: overlay)
    }
    func mapView(_ mapView: MKMapView, didAdd renderers: [MKOverlayRenderer]) {
        log.verbose(#function)
    }

    func mapView(_ mapView: MKMapView,
                 clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
        log.verbose(#function)
        return MKClusterAnnotation(memberAnnotations: memberAnnotations)
    }
}

extension LocationsVC: LocationTracker {

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        log.verbose(#function)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        log.verbose(#function)
    }
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        log.verbose(#function)
        return true
    }

    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        log.verbose(#function)
    }
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        log.verbose(#function)
    }

    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        log.verbose(#function)
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        log.verbose(#function)
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        log.verbose(#function)
    }
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        log.verbose(#function)
    }
    func locationManager(_ manager: CLLocationManager,
                         rangingBeaconsDidFailFor region: CLBeaconRegion,
                         withError error: Error) {
        log.verbose(#function)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        log.verbose(#function)
    }

    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        log.verbose(#function)
    }
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        log.verbose(#function)
    }

    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.trackingButton?.set(visibility: self.start(tracking: .ask))
            self.zoomAndCenter()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        log.verbose(#function)
    }

    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        log.verbose(#function)
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
