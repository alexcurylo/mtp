// @copyright Trollwerks Inc.

// swiftlint:disable file_length

import Anchorage
import MapKit

final class LocationsVC: UIViewController {

    private typealias Segues = R.segue.locationsVC

    @IBOutlet private var mapView: MKMapView?
    @IBOutlet private var searchBar: UISearchBar?
    @IBOutlet private var showMoreButton: UIButton?

    let locationManager = CLLocationManager()
    private var trackingButton: MKUserTrackingButton?
    private var centered = false

    private var mapDisplay = ChecklistFlags()

    private var beachesObserver: Observer?
    private var divesitesObserver: Observer?
    private var golfcoursesObserver: Observer?
    private var locationsObserver: Observer?
    private var restaurantsObserver: Observer?
    private var whssObserver: Observer?
    // UN Countries not mapped

    private var beachesAnnotations: Set<PlaceAnnotation> = []
    private var divesitesAnnotations: Set<PlaceAnnotation> = []
    private var golfcoursesAnnotations: Set<PlaceAnnotation> = []
    private var locationsAnnotations: Set<PlaceAnnotation> = []
    private var restaurantsAnnotations: Set<PlaceAnnotation> = []
    private var whssAnnotations: Set<PlaceAnnotation> = []

    private var selected: PlaceAnnotation?

    override func viewDidLoad() {
        super.viewDidLoad()

        mapDisplay = data.mapDisplay
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
        case Segues.showFilter.identifier,
             Segues.showList.identifier:
            break
        case Segues.showLocation.identifier:
            log.todo("inject selected")
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }

    func updateFilter() {
        mapDisplay = data.mapDisplay
        showAnnotations()
    }
}

extension LocationsVC: PlaceAnnotationDelegate {

    func show(location: PlaceAnnotation) {
        selected = location
        performSegue(withIdentifier: Segues.showLocation, sender: self)
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
        showAnnotations()
    }

    func showAnnotations() {
        showBeaches()
        showDiveSites()
        showGolfCourses()
        showLocations()
        showRestaurants()
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

    func annotations(list: Checklist,
                     shown: Bool) -> Set<PlaceAnnotation> {
        guard shown else { return [] }

        return Set<PlaceAnnotation>(list.places.compactMap { place in
            guard place.placeIsMappable else {
                return nil
            }

            let coordinate = place.placeCoordinate
            guard !coordinate.isZero else {
                log.warning("Coordinates missing: \(list) \(place.placeId), \(place.placeTitle)")
                return nil
            }

            return PlaceAnnotation(
                type: list,
                id: place.placeId,
                coordinate: coordinate,
                delegate: self,
                title: place.placeTitle,
                subtitle: place.placeSubtitle
            )
        })
    }

    func showBeaches() {
        let new = annotations(list: .beaches, shown: mapDisplay.beaches)

        let subtracted = beachesAnnotations.subtracting(new)
        mapView?.removeAnnotations(Array(subtracted))
        beachesAnnotations.subtract(subtracted)

        let added = new.subtracting(beachesAnnotations)
        mapView?.addAnnotations(Array(added))
        beachesAnnotations.formUnion(added)
    }

    func showDiveSites() {
        let new = annotations(list: .divesites, shown: mapDisplay.divesites)

        let subtracted = divesitesAnnotations.subtracting(new)
        mapView?.removeAnnotations(Array(subtracted))
        divesitesAnnotations.subtract(subtracted)

        let added = new.subtracting(divesitesAnnotations)
        mapView?.addAnnotations(Array(added))
        divesitesAnnotations.formUnion(added)
    }

    func showGolfCourses() {
        let new = annotations(list: .golfcourses, shown: mapDisplay.golfcourses)

        let subtracted = golfcoursesAnnotations.subtracting(new)
        mapView?.removeAnnotations(Array(subtracted))
        golfcoursesAnnotations.subtract(subtracted)

        let added = new.subtracting(golfcoursesAnnotations)
        mapView?.addAnnotations(Array(added))
        golfcoursesAnnotations.formUnion(added)
    }

    func showLocations() {
        let new = annotations(list: .locations, shown: mapDisplay.locations)

        let subtracted = locationsAnnotations.subtracting(new)
        mapView?.removeAnnotations(Array(subtracted))
        locationsAnnotations.subtract(subtracted)

        let added = new.subtracting(locationsAnnotations)
        mapView?.addAnnotations(Array(added))
        locationsAnnotations.formUnion(added)
    }

    func showRestaurants() {
        let new = annotations(list: .restaurants, shown: mapDisplay.restaurants)

        let subtracted = restaurantsAnnotations.subtracting(new)
        mapView?.removeAnnotations(Array(subtracted))
        restaurantsAnnotations.subtract(subtracted)

        let added = new.subtracting(restaurantsAnnotations)
        mapView?.addAnnotations(Array(added))
        restaurantsAnnotations.formUnion(added)
    }

    func showWHSs() {
        let new = annotations(list: .whss, shown: mapDisplay.whss)

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
