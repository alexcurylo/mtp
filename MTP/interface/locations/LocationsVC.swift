// @copyright Trollwerks Inc.

// swiftlint:disable file_length

import Anchorage
import DropDown
import MapKit
import RealmMapView

final class LocationsVC: UIViewController, ServiceProvider {

    private typealias Segues = R.segue.locationsVC

    @IBOutlet private var mtpMapView: MTPMapView?
    @IBOutlet private var searchBar: UISearchBar? {
        didSet { searchBar?.removeClearButton() }
    }
    @IBOutlet private var showMoreButton: UIButton?

    let dropdown = DropDown {
        $0.dismissMode = .manual
        $0.backgroundColor = .white
        $0.selectionBackgroundColor = UIColor(red: 0.649, green: 0.815, blue: 1.0, alpha: 0.2)
        $0.separatorColor = UIColor(white: 0.7, alpha: 0.8)
        $0.direction = .bottom
        $0.cellHeight = 30
        $0.setupCornerRadius(10)
        $0.shadowColor = UIColor(white: 0.6, alpha: 1)
        $0.shadowOpacity = 0.9
        $0.shadowRadius = 25
        $0.animationduration = 0.25
        $0.textColor = .darkGray
        $0.textFont = Avenir.book.of(size: 14)
    }
    var dropdownPlaces: [PlaceInfo] = []

    private var trackingButton: MKUserTrackingButton?

    private var mapCentered = false

    private var selected: PlaceAnnotation?

    deinit {
        loc.remove(tracker: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        setupCompass()
        setupTracking()
        configureSearchBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .map)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        mtpMapView?.refreshMapView()
        updateTracking()
        note.checkTriggered()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.showFilter.identifier:
            break
        case Segues.showNearby.identifier:
            let nearby = Segues.showNearby(segue: segue)?.destination
            nearby?.inject(model: (loc.mappables, loc.distances))
        case Segues.showLocation.identifier:
            if let location = Segues.showLocation(segue: segue)?.destination,
               let selected = selected {
                location.inject(model: selected)
            }
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }

    func updateFilter() {
        mtpMapView?.displayed = data.mapDisplay
    }

    func reveal(user: User?) {
        guard let name = user?.locationName, !name.isEmpty else { return }

        let place = data.locations
                        .first { $0.description == name }
        guard let coordinate = place?.placeCoordinate else { return }

        navigationController?.popToRootViewController(animated: false)
        zoom(annotation: coordinate, then: nil)
    }
}

// MARK: - PlaceAnnotationDelegate

extension LocationsVC: PlaceAnnotationDelegate {

    func close(place: PlaceAnnotation) {
        mtpMapView?.deselectAnnotation(place, animated: true)
    }

    func notify(place: PlaceAnnotation) {
        note.notify(list: place.list, id: place.id)
    }

    func reveal(place: PlaceAnnotation?, callout: Bool) {
        guard let place = place else { return }

        navigationController?.popToRootViewController(animated: false)
        zoom(annotation: place.coordinate) { [weak self] in
            if callout {
                self?.mtpMapView?.selectAnnotation(place, animated: false)
            }
        }
    }

    func reveal(place: MapInfo?, callout: Bool) {
        guard let place = place else { return }

        navigationController?.popToRootViewController(animated: false)
        zoom(annotation: place.coordinate) { [weak self] in
            if callout {
                self?.log.todo("MapInfo to annotation")
                self?.note.unimplemented()
            }
        }
    }

    func show(place: PlaceAnnotation) {
        selected = place
        close(place: place)

        performSegue(withIdentifier: Segues.showLocation,
                     sender: self)
    }

    func update(place: PlaceAnnotation) {
        guard let map = mtpMapView else { return }

        map.removeAnnotation(place)
        map.addAnnotation(place)
    }
}

// MARK: - LocationTracker

extension LocationsVC: LocationTracker {

    func accessRefused() {
        mapCentered = true
    }

    func authorization(changed: CLAuthorizationStatus) {
        updateTracking()
    }

    func location(changed: CLLocation) { }
}

// MARK: - Private

private extension LocationsVC {

    enum Layout {
        static let margin = CGFloat(16)
    }

    @IBAction func unwindToLocations(segue: UIStoryboardSegue) { }

    func setupCompass() {
        guard let compass = mtpMapView?.compass else { return }

        view.addSubview(compass)
        compass.topAnchor == view.safeAreaLayoutGuide.topAnchor + Layout.margin
        compass.trailingAnchor == view.trailingAnchor - Layout.margin
    }

    func setupTracking() {
        guard let stack = mtpMapView?.infoStack else { return }

        trackingButton = stack.arrangedSubviews.first as? MKUserTrackingButton
        view.addSubview(stack)
        stack.bottomAnchor == view.safeAreaLayoutGuide.bottomAnchor - Layout.margin
        stack.trailingAnchor == view.trailingAnchor - Layout.margin

        loc.insert(tracker: self)
    }

    func configureSearchBar() {
        guard let searchBar = searchBar else { return }
        dropdown.anchorView = searchBar
        dropdown.bottomOffset = CGPoint(x: 0, y: searchBar.bounds.height)
        dropdown.selectionAction = { [weak self] (index: Int, item: String) in
            self?.dropdown(selected: index)
        }
    }

    func updateTracking() {
        let permission = loc.start(tracker: self)
        trackingButton?.set(visibility: permission)
        centerOnDevice()
    }

    func centerOnDevice() {
        guard !mapCentered,
              let here = loc.here else { return }

        zoom(to: here, span: 160_000, then: nil)
    }

    func zoom(annotation center: CLLocationCoordinate2D,
              then: (() -> Void)?) {
        let span = CLLocationDistance(500)
        #if OFFCENTER_ORIGIN
        let centerOffset = span / 3
        let metersToDegrees = CLLocationDistance(111_111)
        let offset = CLLocationCoordinate2D(
            latitude: center.latitude - (centerOffset / metersToDegrees),
            longitude: center.longitude)
        #endif
        zoom(to: center, span: span) { then?() }
    }

    func zoom(to center: CLLocationCoordinate2D,
              span meters: CLLocationDistance,
              then: (() -> Void)?) {
        mapCentered = true
        let region = MKCoordinateRegion(center: center,
                                        latitudinalMeters: meters,
                                        longitudinalMeters: meters)
        mtpMapView?.zoom(region: region) { then?() }
    }
}

// MARK: - UISearchBarDelegate

extension LocationsVC: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {
        if searchText.isEmpty {
            dropdownPlaces = []
        } else {
            dropdownPlaces = Checklist.allCases.flatMap { list in
                list.places.compactMap { place in
                    guard place.placeIsMappable else { return nil }

                    let name = place.placeTitle
                    let match = name.range(of: searchText, options: .caseInsensitive) != nil
                    return match ? place : nil
                }
            }
        }

        let names = dropdownPlaces.map { $0.placeTitle }
        dropdown.dataSource = names
        if names.isEmpty {
            dropdown.hide()
            searchBar.setShowsCancelButton(true, animated: true)
        } else {
            searchBar.showsCancelButton = false
            dropdown.show()
        }
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBarCancelButtonClicked(searchBar)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        dropdown.hide()
        searchBar.resignFirstResponder()
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }

    func annotation(place: PlaceInfo) -> PlaceAnnotation? {
        let annotations = mtpMapView?.annotations ?? []
        for annotation in annotations {
            if let annotation = annotation as? PlaceAnnotation,
                   annotation.id == place.placeId,
                   annotation.name == place.placeTitle {
                return annotation
            }
        }
        return nil
    }

    func dropdown(selected index: Int) {
        if let searchBar = searchBar {
            searchBarCancelButtonClicked(searchBar)
        }
        let info = dropdownPlaces[index]
        let place = annotation(place: info)
        reveal(place: place, callout: true)
    }
}

// MARK: - MKMapViewDelegate

extension LocationsVC: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView,
                 regionWillChangeAnimated: Bool) { }
    func mapView(_ mapView: MKMapView,
                 regionDidChangeAnimated: Bool) { }

    func mapViewWillStartLoadingMap(_ mapView: MKMapView) { }
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) { }
    func mapViewDidFailLoadingMap(_ mapView: MKMapView) { }

    func mapViewWillStartRenderingMap(_ mapView: MKMapView) { }
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView,
                                      fullyRendered: Bool) { }

    func mapViewWillStartLocatingUser(_ mapView: MKMapView) { }
    func mapViewDidStopLocatingUser(_ mapView: MKMapView) { }
    func mapView(_ mapView: MKMapView,
                 didUpdate userLocation: MKUserLocation) {
        centerOnDevice()
    }
    func mapView(_ mapView: MKMapView,
                 didFailToLocateUserWithError error: Error) { }
    func mapView(_ mapView: MKMapView,
                 didChange mode: MKUserTrackingMode,
                 animated: Bool) { }

    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case let realm as Annotation:
            log.todo("produce annotation view for \(realm)")
            return nil

        case let place as PlaceAnnotation:
            return mapView.dequeueReusableAnnotationView(
                withIdentifier: place.reuseIdentifier,
                for: place
            )
        case let cluster as MKClusterAnnotation:
            log.error("MKMapView should not be clustering")
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
                 didAdd views: [MKAnnotationView]) { }

    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) { }

    func mapView(_ mapView: MKMapView,
                 didSelect view: MKAnnotationView) {
        switch view {

        case let realm as ClusterAnnotationView:
            log.todo("handle selection for \(realm)")
            if let safeObjects = ClusterAnnotationView.safeObjects(forClusterAnnotationView: realm),
                safeObjects.count == 1,
                let first = safeObjects.first?.toObject(MapInfo.self) {

                mtpMapView?.update(overlays: first)
            }

        case let place as PlaceAnnotationView:
            place.prepareForCallout()
            if let mapInfo = place.mapInfo {
                mtpMapView?.update(overlays: mapInfo)
            }
            #if TEST_TRIGGER_ON_SELECTION
            (place.annotation as? PlaceAnnotation)?._testTrigger(background: false)
            #endif
        case let cluster as PlaceClusterAnnotationView:
            log.error("MKMapView should not be clustering")
            mtpMapView?.zoom(cluster: cluster.annotation as? MKClusterAnnotation)
            mapView.deselectAnnotation(cluster.annotation, animated: false)

        default:
            break
        }
    }

    func mapView(_ mapView: MKMapView,
                 didDeselect view: MKAnnotationView) { }

    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 didChange newState: MKAnnotationView.DragState,
                 fromOldState oldState: MKAnnotationView.DragState) { }

    func mapView(_ mapView: MKMapView,
                 rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        switch overlay {
        case let place as PlaceOverlay:
            let renderer = MKPolygonRenderer(polygon: place)
            renderer.fillColor = place.color.withAlphaComponent(0.25)
            renderer.strokeColor = place.color.withAlphaComponent(0.5)
            renderer.lineWidth = 1
            return renderer
        default:
            return MKOverlayRenderer(overlay: overlay)
        }
    }

    func mapView(_ mapView: MKMapView,
                 didAdd renderers: [MKOverlayRenderer]) { }

    func mapView(_ mapView: MKMapView,
                 clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
        log.error("MKMapView should not be clustering")
        return MKClusterAnnotation(memberAnnotations: memberAnnotations)
    }
}

// MARK: - MKUserTrackingButton

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
        @unknown default:
            authorized = false
        }
        isHidden = !authorized
    }
}

// MARK: - Injectable

extension LocationsVC: Injectable {

    typealias Model = ()

    @discardableResult func inject(model: Model) -> Self {
        return self
    }

    func requireInjections() {
        mtpMapView.require()
        searchBar.require()
        showMoreButton.require()
    }
}
