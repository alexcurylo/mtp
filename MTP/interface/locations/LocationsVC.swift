// @copyright Trollwerks Inc.

// swiftlint:disable file_length

import Anchorage
import DropDown
import MapKit
import RealmSwift

final class LocationsVC: UIViewController, ServiceProvider {

    private typealias Segues = R.segue.locationsVC

    @IBOutlet private var mapView: MKMapView? {
        didSet {
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
    }
    @IBOutlet private var searchBar: UISearchBar? {
        didSet {
            searchBar?.removeClearButton()
        }
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
    private var mapLoaded = false
    private var mapAnnotated = false
    private var shownRect = MKMapRect.null

    private var displayed = ChecklistFlags()

    private var selected: PlaceAnnotation?

    deinit {
        loc.remove(tracker: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        displayed = data.mapDisplay
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
            nearby?.inject(model: loc.annotations())
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
        updateAnnotations(old: displayed, new: data.mapDisplay)
        displayed = data.mapDisplay
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
        mapView?.deselectAnnotation(place, animated: true)
    }

    func notify(place: PlaceAnnotation) {
        note.notify(list: place.list, id: place.id)
    }

    func reveal(place: PlaceAnnotation?, callout: Bool) {
        guard let place = place else { return }

        navigationController?.popToRootViewController(animated: false)
        zoom(annotation: place.coordinate) { [weak self] in
            if callout {
                self?.mapView?.selectAnnotation(place, animated: false)
            }
        }
    }

    func show(place: PlaceAnnotation) {
        selected = place
        close(place: place)

        if place.canPost {
            performSegue(withIdentifier: Segues.showLocation,
                         sender: self)
        } else if let url = place.webUrl {
            app.launch(url: url)
        } else {
            note.message(error: L.noWebsite())
        }
    }

    func update(place: PlaceAnnotation) {
        guard let map = mapView else { return }

        map.removeAnnotation(place)
        map.addAnnotation(place)
    }
}

// MARK: - LocationTracker

extension LocationsVC: LocationTracker {

    func accessRefused() {
        mapCentered = true
        annotate()
    }

    func annotations(changed list: Checklist,
                     added: Set<PlaceAnnotation>,
                     removed: Set<PlaceAnnotation>) {
        guard mapAnnotated,
              displayed.display(list: list) else { return }

        changedAnnotations(added: added, removed: removed)
    }

    func authorization(changed: CLAuthorizationStatus) {
        updateTracking()
    }

    func location(changed: CLLocation) {
    }
}

// MARK: - Private

private extension LocationsVC {

    enum Layout {
        static let margin = CGFloat(16)
    }

    @IBAction func unwindToLocations(segue: UIStoryboardSegue) {
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
        //let centerOffset = span / 3
        //let metersToDegrees = CLLocationDistance(111_111)
        //let offset = CLLocationCoordinate2D(
            //latitude: center.latitude - (centerOffset / metersToDegrees),
            //longitude: center.longitude)
        zoom(to: center, span: span) { then?() }
    }

    func zoom(to center: CLLocationCoordinate2D,
              span meters: CLLocationDistance,
              then: (() -> Void)?) {
        mapCentered = true
        let region = MKCoordinateRegion(center: center,
                                        latitudinalMeters: meters,
                                        longitudinalMeters: meters)
        zoom(region: region) { then?() }
    }

    func zoom(cluster: MKClusterAnnotation?) {
        guard let cluster = cluster,
              var region = mapView?.region else { return }

        let clustered = cluster.region

        region.center = cluster.coordinate
        region.span.latitudeDelta = clustered.maxDelta * 1.3
        region.span.longitudeDelta = clustered.maxDelta * 1.3
        zoom(region: region, then: nil)
    }

    func zoom(region: MKCoordinateRegion,
              then: (() -> Void)?) {
        DispatchQueue.main.async { [weak self] in
            MKMapView.animate(
                withDuration: 1,
                animations: {
                    self?.mapView?.setRegion(region, animated: true)
                },
                completion: { _ in
                    self?.annotate()
                    then?()
                }
            )
        }
    }

    func annotate() {
        guard !mapAnnotated, mapCentered, mapLoaded else { return }

        mapAnnotated = true
        updateShownRect()
        updateAnnotations(old: ChecklistFlags(flagged: false),
                          new: displayed)
    }

    func updateShownRect() {
        shownRect = mapView?.visibleMapRect ?? .null
        // log.todo("filter by shownRect?")
    }

    func updateAnnotations(old: ChecklistFlags,
                           new: ChecklistFlags) {
        guard mapAnnotated else { return }

        var added: Set<PlaceAnnotation> = []
        var removed: Set<PlaceAnnotation> = []
        Checklist.allCases.forEach { list in
            guard list.isMappable else { return }

            switch (old.display(list: list), new.display(list: list)) {
            case (false, true):
                added.formUnion(loc.annotations(list: list))
            case (true, false):
                removed.formUnion(loc.annotations(list: list))
            default:
                break
            }
        }
        changedAnnotations(added: added, removed: removed)
    }

    func changedAnnotations(added: Set<PlaceAnnotation>,
                            removed: Set<PlaceAnnotation>) {
        guard mapAnnotated, let map = mapView else { return }

        if !removed.isEmpty {
            map.removeAnnotations(Array(removed))
        }
        if !added.isEmpty {
            map.addAnnotations(Array(added))
        }
    }

    func update(overlays place: PlaceAnnotationView) {
        guard let map = mapView else { return }

        let current = map.overlays.filter { $0 is PlaceOverlay }
        if let first = current.first as? PlaceOverlay,
           first.shows(view: place) {
                return
        }

        map.removeOverlays(current)
        let overlays = place.overlays
        if !overlays.isEmpty {
            map.addOverlays(overlays)
        }
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
        let annotations = mapView?.annotations ?? []
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
                 regionWillChangeAnimated: Bool) {
    }
    func mapView(_ mapView: MKMapView,
                 regionDidChangeAnimated: Bool) {
        updateShownRect()
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
        mapLoaded = true
        annotate()
    }

    func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
    }
    func mapViewDidStopLocatingUser(_ mapView: MKMapView) {
    }
    func mapView(_ mapView: MKMapView,
                 didUpdate userLocation: MKUserLocation) {
        centerOnDevice()
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
                withIdentifier: place.reuseIdentifier,
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
        switch view {
        case let place as PlaceAnnotationView:
            place.prepareForCallout()
            update(overlays: place)
        case let cluster as PlaceClusterAnnotationView:
            zoom(cluster: cluster.annotation as? MKClusterAnnotation)
            mapView.deselectAnnotation(cluster.annotation, animated: false)
        default:
            break
        }
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
                 didAdd renderers: [MKOverlayRenderer]) {
    }

    func mapView(_ mapView: MKMapView,
                 clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
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
        mapView.require()
        searchBar.require()
        showMoreButton.require()
    }
}
