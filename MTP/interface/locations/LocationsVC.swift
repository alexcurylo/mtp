// @copyright Trollwerks Inc.

// swiftlint:disable file_length

import Anchorage
import DropDown
import MapKit
import RealmSwift
import SwiftEntryKit

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
        checkTriggered()
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
        zoom(annotation: coordinate)
    }
}

// MARK: - PlaceAnnotationDelegate

extension LocationsVC: PlaceAnnotationDelegate {

    func close(place: PlaceAnnotation) {
        mapView?.deselectAnnotation(place, animated: true)
    }

    func notify(place: PlaceAnnotation) {
        notify(list: place.list, id: place.id)
    }

    func reveal(place: PlaceAnnotation?, callout: Bool) {
        guard let place = place else { return }

        navigationController?.popToRootViewController(animated: false)
        zoom(annotation: place.coordinate)
        if callout {
            mapView?.selectAnnotation(place, animated: false)
        }
    }

    func show(place: PlaceAnnotation) {
        selected = place
        close(place: place)
        performSegue(withIdentifier: Segues.showLocation, sender: self)
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

        zoom(to: here, span: 160_000)
    }

    func zoom(annotation center: CLLocationCoordinate2D) {
        zoom(to: center, span: 1_600)
    }

    func zoom(to center: CLLocationCoordinate2D,
              span meters: CLLocationDistance) {
        mapCentered = true
        let region = MKCoordinateRegion(center: center,
                                        latitudinalMeters: meters,
                                        longitudinalMeters: meters)
        zoom(region: region)
    }

    func zoom(cluster annotation: MKClusterAnnotation?) {
        guard let center = annotation?.coordinate,
            var region = mapView?.region else { return }

        // log.todo("smart zoom to split annotations?")
        region.center = center
        region.span.latitudeDelta *= 0.5
        region.span.longitudeDelta *= 0.5
        zoom(region: region)
    }

    func zoom(region: MKCoordinateRegion) {
        DispatchQueue.main.async { [weak self] in
            MKMapView.animate(
                withDuration: 1,
                animations: {
                    self?.mapView?.setRegion(region, animated: true)
                },
                completion: { _ in
                    self?.annotate()
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

        let start = Date()

        if !removed.isEmpty {
            map.removeAnnotations(Array(removed))
        }
        if !added.isEmpty {
            map.addAnnotations(Array(added))
        }
    }

    func checkTriggered() {
        for list in Checklist.allCases {
            for next in data.triggered?[list] ?? [] {
                if list.isVisited(id: next) ||
                   list.isDismissed(id: next) {
                    list.set(triggered: false, id: next)
                } else {
                    notify(list: list, id: next)
                    return
                }
            }
        }
    }

    func notify(list: Checklist, id: Int) {
        if let info = list.place(id: id) {
            notify(list: list, info: info)
        }
    }

    func notify(list: Checklist, info: PlaceInfo) {
        notifyForeground(list: list, info: info)
        notifyBackground(list: list, info: info)
    }

    // swiftlint:disable:next function_body_length
    func notifyForeground(list: Checklist,
                          info: PlaceInfo) {
        let visitId = info.placeId

        let contentTitle = Localized.checkinTitle(list.category)
        let contentMessage: String
        switch list {
        case .locations:
            contentMessage = Localized.checkinInside(info.placeTitle)
        default:
            contentMessage = Localized.checkinNear(info.placeTitle)
        }
        let simpleMessage = notifyMessage(contentTitle: contentTitle,
                                          contentMessage: contentMessage)

        // Dismiss
        let buttonFont = Avenir.heavy.of(size: 16)
        let dismissColor = UIColor(rgb: 0xD0021B)
        let closeButtonLabelStyle = EKProperty.LabelStyle(font: buttonFont, color: dismissColor)
        let closeButtonLabel = EKProperty.LabelContent(
            text: Localized.dismissAction(),
            style: closeButtonLabelStyle)
        let closeButton = EKProperty.ButtonContent(
            label: closeButtonLabel,
            backgroundColor: .clear,
            highlightedBackgroundColor: dismissColor.withAlphaComponent(0.05)) { [list, visitId] in
                list.set(dismissed: true, id: visitId)
                SwiftEntryKit.dismiss { [weak self] in
                    self?.checkTriggered()
                }
        }

        // Checkin
        let checkinColor = UIColor(rgb: 0x028DFF)
        let okButtonLabelStyle = EKProperty.LabelStyle(font: buttonFont, color: checkinColor)
        let okButtonLabel = EKProperty.LabelContent(
            text: Localized.checkinAction(),
            style: okButtonLabelStyle)
        let okButton = EKProperty.ButtonContent(
            label: okButtonLabel,
            backgroundColor: .clear,
            highlightedBackgroundColor: checkinColor.withAlphaComponent(0.05)) { [list, visitId] in
                list.set(visited: true, id: visitId)
                SwiftEntryKit.dismiss { [weak self] in
                    self?.congratulate(list: list, id: visitId)
                }
        }
        let grayLight = UIColor(white: 230.0 / 255.0, alpha: 1)
        let buttonsBarContent = EKProperty.ButtonBarContent(
            // swiftlint:disable:next multiline_arguments
            with: closeButton, okButton,
            separatorColor: grayLight,
            buttonHeight: 60,
            expandAnimatedly: true)

        // Generate
        let alertMessage = EKAlertMessage(
            simpleMessage: simpleMessage,
            imagePosition: .left,
            buttonBarContent: buttonsBarContent)
        let contentView = EKAlertMessageView(with: alertMessage)
        SwiftEntryKit.display(entry: contentView,
                              using: notifyAttributes(priority: .min))
    }

    // swiftlint:disable:next function_body_length
    func congratulate(list: Checklist, id: Int) {
        if let user = data.user,
           let annotation = loc.annotations(list: list)
                            .first(where: { $0.id == id }) {
            mainTBC?.route(to: annotation)

            let contentTitle = Localized.congratulations(annotation.name)

            let (single, plural) = list.names
            let (visited, remaining) = list.status(of: user)
            let contentVisited = Localized.status(visited, plural, remaining)

            let contentMilestone = list.milestone(visited: visited)

            let contentNearest: String
            if remaining > 0,
                let place = nearest(place: annotation) {
                contentNearest = Localized.nearest(single, place)
            } else {
                contentNearest = ""
            }

            let contentMessage = contentMilestone + contentVisited + contentNearest

            let simpleMessage = notifyMessage(contentTitle: contentTitle,
                                              contentMessage: contentMessage)

            // OK
            let buttonFont = Avenir.heavy.of(size: 16)
            let checkinColor = UIColor(rgb: 0x028DFF)
            let okButtonLabelStyle = EKProperty.LabelStyle(font: buttonFont, color: checkinColor)
            let okButtonLabel = EKProperty.LabelContent(
                text: Localized.ok(),
                style: okButtonLabelStyle)
            let okButton = EKProperty.ButtonContent(
                label: okButtonLabel,
                backgroundColor: .clear,
                highlightedBackgroundColor: checkinColor.withAlphaComponent(0.05)) {
                    SwiftEntryKit.dismiss { [weak self] in
                        self?.checkTriggered()
                    }
            }
            let grayLight = UIColor(white: 230.0 / 255.0, alpha: 1)
            let buttonsBarContent = EKProperty.ButtonBarContent(
                with: okButton,
                separatorColor: grayLight,
                buttonHeight: 60,
                expandAnimatedly: true)

            // Generate
            let alertMessage = EKAlertMessage(
                simpleMessage: simpleMessage,
                imagePosition: .left,
                buttonBarContent: buttonsBarContent)
            let contentView = EKAlertMessageView(with: alertMessage)
            SwiftEntryKit.display(entry: contentView,
                                  using: notifyAttributes(priority: .max))
        } else {
            checkTriggered()
        }
    }

    func nearest(place: PlaceAnnotation) -> String? {
        var distance: CLLocationDistance = 99_999
        var nearest: String?
        for other in loc.annotations(list: place.list) {
            guard other.id != place.id,
                  !other.isVisited else { continue }

            let otherDistance = other.coordinate.distance(from: place.coordinate)
            if otherDistance < distance {
                nearest = other.name
                distance = otherDistance
            }
        }
        return nearest
    }

    func notifyAttributes(priority: EKAttributes.Precedence.Priority) -> EKAttributes {
        var attributes = EKAttributes.bottomFloat

        let dimmedLightBackground = UIColor(white: 100.0 / 255.0, alpha: 0.3)
        attributes.screenBackground = .color(color: dimmedLightBackground)
        attributes.hapticFeedbackType = .success
        attributes.displayDuration = .infinity
        attributes.entryBackground = .color(color: .white)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 8))
        attributes.roundCorners = .all(radius: 4)
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.2)))
        attributes.positionConstraints.verticalOffset = 10
        attributes.positionConstraints.size = .init(width: .offset(value: 20), height: .intrinsic)
        attributes.positionConstraints.maxSize = .init(
            width: .constant(value: UIScreen.main.bounds.minEdge),
            height: .intrinsic)
        attributes.statusBar = .dark
        attributes.border = .value(color: .black, width: 0.5)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 5))
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.exitAnimation = .init(translate: .init(duration: 0.2))
        attributes.entranceAnimation = .init(
            translate: .init(duration: 0.7,
                             spring: .init(damping: 1, initialVelocity: 0)),
            scale: .init(from: 0.6, to: 1, duration: 0.7),
            fade: .init(from: 0.8, to: 1, duration: 0.3))
        attributes.exitAnimation = .init(translate: .init(duration: 0.2))
        attributes.screenInteraction = .absorbTouches
        attributes.entryInteraction = .absorbTouches
        attributes.precedence = .enqueue(priority: priority)

        return attributes
    }

    func notifyMessage(contentTitle: String,
                       contentMessage: String) -> EKSimpleMessage {
        let title = EKProperty.LabelContent(
            text: contentTitle,
            style: .init(font: Avenir.medium.of(size: 15),
                         color: .black))
        let description = EKProperty.LabelContent(
            text: contentMessage,
            style: .init(font: Avenir.light.of(size: 13),
                         color: .black))
        let simpleMessage = EKSimpleMessage(image: nil,
                                            title: title,
                                            description: description)
        return simpleMessage
    }

    func notifyBackground(list: Checklist,
                          info: PlaceInfo) {
        note.background { [weak self] in
            self?.postLocalNotification(list: list,
                                        info: info)
        }
    }

    func postLocalNotification(list: Checklist,
                               info: PlaceInfo) {
        let title = Localized.checkinTitle(list.category)
        let body: String
        switch list {
        case .locations:
            body = Localized.checkinInside(info.placeTitle)
        default:
            body = Localized.checkinNear(info.placeTitle)
        }
        let info: NotificationService.Info = [
            NotificationsHandler.visitList: list.rawValue,
            NotificationsHandler.visitId: info.placeId
        ]

        note.visit(title: title, body: body, info: info)
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
