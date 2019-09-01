// @copyright Trollwerks Inc.

import Anchorage
import DropDown
import MapKit

// swiftlint:disable file_length

/// Root controller for the map displaying tab
class LocationsVC: UIViewController {

    private typealias Segues = R.segue.locationsVC

    // verified in requireOutlets
    @IBOutlet private var mtpMapView: MTPMapView!
    @IBOutlet private var searchBar: UISearchBar! {
        didSet { searchBar.removeClearButton() }
    }
    @IBOutlet private var showMoreButton: UIButton!

    private var trackingButton: MKUserTrackingButton?

    private let dropdown = DropDown {
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
    private var matches: [Mappable] = []

    private var injectMappable: Mappable?

    /// Remove observers
    deinit {
        loc.remove(tracker: self)
    }

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireOutlets()

        setupCompass()
        setupTracking()
        configureSearchBar()
    }

    /// Prepare for reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .map)
        expose()
    }

    /// Actions to take after reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        report(screen: "Locations")

        mtpMapView.refreshMapView()
        updateTracking()
        note.checkPending()
    }

    /// Instrument and inject navigation
    ///
    /// - Parameters:
    ///   - segue: Navigation action
    ///   - sender: Action originator
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nearby = Segues.showNearby(segue: segue)?
                              .destination {
            nearby.inject(model: (data.mappables,
                                  mtpMapView.centerCoordinate))
        } else if let show = Segues.showLocation(segue: segue)?
                                   .destination,
                  let inject = injectMappable {
            show.inject(model: inject)
            injectMappable = nil
        }
    }

    /// Update place types shown
    func updateFilter() {
        mtpMapView.displayed = data.mapDisplay
    }

    /// Reveal user
    ///
    /// - Parameter user: User to display
    func reveal(user: User?) {
        guard let name = user?.locationName, !name.isEmpty else { return }

        let place = data.locations
                        .first { $0.description == name }
        guard let coordinate = place?.placeCoordinate else { return }

        navigationController?.popToRootViewController(animated: false)
        mtpMapView.zoom(to: coordinate)
    }
}

// MARK: - Mapper

extension LocationsVC: Mapper {

    /// Close
    ///
    /// - Parameter mappable: Place
    func close(mappable: Mappable) {
        mtpMapView.close(mappable: mappable)
    }

    /// Notify
    ///
    /// - Parameters:
    ///   - mappable: Place
    ///   - triggered: Date
    func notify(mappable: Mappable, triggered: Date) {
        note.notify(mappable: mappable,
                    triggered: triggered) { _ in }
    }

    /// Reveal
    ///
    /// - Parameters:
    ///   - mappable: Place
    ///   - callout: Show callout
    func reveal(mappable: Mappable, callout: Bool) {
        navigationController?.popToRootViewController(animated: false)
        mtpMapView.zoom(to: mappable, callout: callout)
    }

    /// Show
    ///
    /// - Parameter mappable: Place
    func show(mappable: Mappable) {
        injectMappable = mappable
        close(mappable: mappable)
        performSegue(withIdentifier: Segues.showLocation,
                     sender: self)
    }

    /// Update
    ///
    /// - Parameter mappable: Place
    func update(mappable: Mappable) {
        mtpMapView.update(mappable: mappable)
    }
}

// MARK: - LocationTracker

extension LocationsVC: LocationTracker {

    /// User refused access
    func accessRefused() {
        mtpMapView.isCentered = true
    }

    /// Authorization changed
    ///
    /// - Parameter changed: New status
    func authorization(changed: CLAuthorizationStatus) {
        updateTracking()
    }

    /// Location changed
    ///
    /// - Parameter changed: New location
    func location(changed: CLLocation) { }
}

// MARK: - Private

private extension LocationsVC {

    enum Layout {
        static let margin = CGFloat(16)
    }

    @IBAction func unwindToLocations(segue: UIStoryboardSegue) { }

    func setupCompass() {
        guard let compass = mtpMapView.compass else { return }

        view.addSubview(compass)
        compass.topAnchor == view.safeAreaLayoutGuide.topAnchor + Layout.margin
        compass.trailingAnchor == view.trailingAnchor - Layout.margin
    }

    func setupTracking() {
        let stack = mtpMapView.infoStack
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
        mtpMapView.centerOnDevice()
    }

    func dropdown(selected index: Int) {
        if let searchBar = searchBar {
            searchBarCancelButtonClicked(searchBar)
        }
        reveal(mappable: matches[index], callout: true)
    }
}

// MARK: - Exposing

extension LocationsVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        let bar = navigationController?.navigationBar
        UILocations.nav.expose(item: bar)
        let items = navigationItem.rightBarButtonItems
        UILocations.nearby.expose(item: items?.first)
        UILocations.filter.expose(item: items?.last)
    }
}

// MARK: - UISearchBarDelegate

extension LocationsVC: UISearchBarDelegate {

    /// Changed search text notification
    ///
    /// - Parameters:
    ///   - searchBar: Searcher
    ///   - searchText: Contents
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {
        matches = data.get(mappables: searchText)
        let names = matches.map { $0.title }
        let ids = (0..<names.count).map { UILocations.result($0).identifier }
        dropdown.localizationKeysDataSource = ids
        dropdown.dataSource = names
        if names.isEmpty {
            dropdown.hide()
            searchBar.setShowsCancelButton(true, animated: true)
        } else {
            searchBar.showsCancelButton = false
            dropdown.show()
        }
    }

    /// Begin search editing
    ///
    /// - Parameter searchBar: Searcher
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    /// Handle search button click
    ///
    /// - Parameter searchBar: Searcher
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBarCancelButtonClicked(searchBar)
    }

    /// Handle cancel button click
    ///
    /// - Parameter searchBar: Searcher
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        dropdown.hide()
        searchBar.resignFirstResponder()
    }

    /// Search ended notification
    ///
    /// - Parameter searchBar: Searcher
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
}

// MARK: - MKMapViewDelegate

extension LocationsVC: MKMapViewDelegate {

    //func mapView(_ mapView: MKMapView,
                 //regionWillChangeAnimated: Bool) { }
    //func mapView(_ mapView: MKMapView,
                 //regionDidChangeAnimated: Bool) { }

    //func mapViewWillStartLoadingMap(_ mapView: MKMapView) { }
    //func mapViewDidFinishLoadingMap(_ mapView: MKMapView) { }
    //func mapViewDidFailLoadingMap(_ mapView: MKMapView) { }

    //func mapViewWillStartRenderingMap(_ mapView: MKMapView) { }
    //func mapViewDidFinishRenderingMap(_ mapView: MKMapView,
                                      //fullyRendered: Bool) { }

    //func mapViewWillStartLocatingUser(_ mapView: MKMapView) { }
    //func mapViewDidStopLocatingUser(_ mapView: MKMapView) { }

    /// Update user location
    ///
    /// - Parameters:
    ///   - mapView: Map view
    ///   - userLocation: Location
    func mapView(_ mapView: MKMapView,
                 didUpdate userLocation: MKUserLocation) {
        mtpMapView.centerOnDevice()
    }
    //func mapView(_ mapView: MKMapView,
                 //didFailToLocateUserWithError error: Error) { }
    //func mapView(_ mapView: MKMapView,
                 //didChange mode: MKUserTrackingMode,
                 //animated: Bool) { }

    /// Produce annotation view
    ///
    /// - Parameters:
    ///   - mapView: Map view
    ///   - annotation: Annotation
    /// - Returns: Mappable[s]AnnotationView
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case let mappable as MappablesAnnotation where mappable.isSingle:
            return MappableAnnotationView.view(on: mapView, for: mappable)
        case let mappables as MappablesAnnotation where mappables.isMultiple:
            return MappablesAnnotationView.view(on: mapView, for: mappables)
        case is MKUserLocation:
            break
        default:
            log.debug("unexpected annotation: \(annotation)")
        }
        return nil
    }

    //func mapView(_ mapView: MKMapView,
                 //didAdd views: [MKAnnotationView]) { }

    //func mapView(_ mapView: MKMapView,
                 //annotationView view: MKAnnotationView,
                 //calloutAccessoryControlTapped control: UIControl) { }

    /// Handle annoation selection
    ///
    /// - Parameters:
    ///   - mapView: Map view
    ///   - view: Annotation view
    func mapView(_ mapView: MKMapView,
                 didSelect view: MKAnnotationView) {
        switch view {
        case let mappable as MappableAnnotationView:
            mtpMapView.display(view: mappable)
        case let mappables as MappablesAnnotationView:
            mtpMapView.expand(view: mappables)
        default:
            // MKModernUserLocationView for instance
            break
        }
    }

    //func mapView(_ mapView: MKMapView,
                 //didDeselect view: MKAnnotationView) { }

    //func mapView(_ mapView: MKMapView,
                 //annotationView view: MKAnnotationView,
                 //didChange newState: MKAnnotationView.DragState,
                 //fromOldState oldState: MKAnnotationView.DragState) { }

    /// Provide overlay renderer
    ///
    /// - Parameters:
    ///   - mapView: Map view
    ///   - overlay: Overlay
    /// - Returns: Renderer
    func mapView(_ mapView: MKMapView,
                 rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        switch overlay {
        case let mappable as MappableOverlay:
            return mappable.renderer
        default:
            return MKOverlayRenderer(overlay: overlay)
        }
    }

    //func mapView(_ mapView: MKMapView,
                 //didAdd renderers: [MKOverlayRenderer]) { }

    //func mapView(_ mapView: MKMapView,
                 //clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
        //log.error("MKMapView should not be clustering")
        //return MKClusterAnnotation(memberAnnotations: memberAnnotations)
    //}
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

// MARK: - InterfaceBuildable

extension LocationsVC: InterfaceBuildable {

    /// Injection enforcement for viewDidLoad
    func requireOutlets() {
        mtpMapView.require()
        searchBar.require()
        showMoreButton.require()
    }
}
