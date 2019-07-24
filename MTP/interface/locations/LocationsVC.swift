// @copyright Trollwerks Inc.

import Anchorage
import DropDown
import MapKit

final class LocationsVC: UIViewController, ServiceProvider {

    private typealias Segues = R.segue.locationsVC

    @IBOutlet private var mtpMapView: MTPMapView?
    @IBOutlet private var searchBar: UISearchBar? {
        didSet { searchBar?.removeClearButton() }
    }
    @IBOutlet private var showMoreButton: UIButton?

    private var trackingButton: MKUserTrackingButton?

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
    var matches: [Mappable] = []

    private var injectMappable: Mappable?

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
        expose()
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
            nearby?.inject(model: (data.mappables,
                                   mtpMapView?.centerCoordinate ?? .zero))
        case Segues.showLocation.identifier:
            guard let show = Segues.showLocation(segue: segue)?.destination else { break }
            if let inject = injectMappable {
                show.inject(model: inject)
                injectMappable = nil
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
        mtpMapView?.zoom(to: coordinate)
    }
}

// MARK: - Mapper

extension LocationsVC: Mapper {

    func close(mappable: Mappable) {
        mtpMapView?.close(mappable: mappable)
    }

    func notify(mappable: Mappable, triggered: Date) {
        note.notify(mappable: mappable,
                    triggered: triggered) { _ in }
    }

    func reveal(mappable: Mappable, callout: Bool) {
        navigationController?.popToRootViewController(animated: false)
        mtpMapView?.zoom(to: mappable, callout: callout)
    }

    func show(mappable: Mappable) {
        injectMappable = mappable
        close(mappable: mappable)
        performSegue(withIdentifier: Segues.showLocation,
                     sender: self)
    }

    func update(mappable: Mappable) {
        mtpMapView?.update(mappable: mappable)
    }
}

// MARK: - LocationTracker

extension LocationsVC: LocationTracker {

    func accessRefused() {
        mtpMapView?.isCentered = true
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
        mtpMapView?.centerOnDevice()
    }

    func expose() {
        let bar = navigationController?.navigationBar
        LocationsVCs.nav.expose(item: bar)
        let items = navigationItem.rightBarButtonItems
        LocationsVCs.nearby.expose(item: items?.first)
        LocationsVCs.filter.expose(item: items?.last)
    }
}

// MARK: - UISearchBarDelegate

extension LocationsVC: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {
        matches = data.get(mappables: searchText)
        let names = matches.map { $0.title }
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

    func dropdown(selected index: Int) {
        if let searchBar = searchBar {
            searchBarCancelButtonClicked(searchBar)
        }
        reveal(mappable: matches[index], callout: true)
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
        mtpMapView?.centerOnDevice()
    }
    func mapView(_ mapView: MKMapView,
                 didFailToLocateUserWithError error: Error) { }
    func mapView(_ mapView: MKMapView,
                 didChange mode: MKUserTrackingMode,
                 animated: Bool) { }

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

    func mapView(_ mapView: MKMapView,
                 didAdd views: [MKAnnotationView]) { }

    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) { }

    func mapView(_ mapView: MKMapView,
                 didSelect view: MKAnnotationView) {
        switch view {
        case let mappable as MappableAnnotationView:
            mtpMapView?.display(view: mappable)
        case let mappables as MappablesAnnotationView:
            mtpMapView?.expand(view: mappables)
        default:
            // MKModernUserLocationView for instance
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
        case let mappable as MappableOverlay:
            return mappable.renderer
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
