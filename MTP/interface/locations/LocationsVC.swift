// @copyright Trollwerks Inc.

// swiftlint:disable file_length

import Anchorage
import DropDown
import MapKit
import RealmSwift
import SwiftEntryKit
import UserNotifications

final class LocationsVC: UIViewController, ServiceProvider {

    private typealias Segues = R.segue.locationsVC

    @IBOutlet private var mapView: MKMapView?
    @IBOutlet private var searchBar: UISearchBar?
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
    var dropdownItems: [String] = []

    let locationManager = CLLocationManager()
    private var trackingButton: MKUserTrackingButton?
    private var mapCentered = false
    private var mapLoaded = false
    private var shownRect = MKMapRect.null

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
    private var allAnnotations: [Set<PlaceAnnotation>] {
        return [beachesAnnotations,
                divesitesAnnotations,
                golfcoursesAnnotations,
                locationsAnnotations,
                restaurantsAnnotations,
                whssAnnotations]
    }
    private var annotationsSet = false

    func shown(list: Checklist) -> Set<PlaceAnnotation> {
        switch list {
        case .beaches: return beachesAnnotations
        case .divesites: return divesitesAnnotations
        case .golfcourses: return golfcoursesAnnotations
        case .locations: return locationsAnnotations
        case .restaurants: return restaurantsAnnotations
        case .uncountries: return []
        case .whss: return whssAnnotations
        }
    }

    private var selected: PlaceAnnotation?
    private var lastUserLocation: CLLocation?

    private let constants = (
        filterTrigger: CLLocationDistance(20),
        filterNearby: CLLocationDistance(20)
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        if let searchBar = searchBar {
            let searchBarStyle = searchBar.value(forKey: "searchField") as? UITextField
            searchBarStyle?.clearButtonMode = .never

            dropdown.anchorView = searchBar
            dropdown.bottomOffset = CGPoint(x: 0, y: searchBar.bounds.height)
            //let inset: CGFloat = 12.0
            //dropdown.topOffset = CGPoint(x: inset, y: 0)
            //dropdown.width = UIScreen.main.bounds.width - (2 * inset)
            dropdown.selectionAction = { [weak self] (index: Int, item: String) in
                self?.dropdown(selected: index)
            }
        }

        mapDisplay = data.mapDisplay
        setupCompass()
        setupTracking()
        trackingButton?.set(visibility: start(tracking: .dontAsk))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .map)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        trackingButton?.set(visibility: start(tracking: .ask))
        centerOnDevice()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        log.verbose("prepare for \(segue.name)")
        switch segue.identifier {
        case Segues.showFilter.identifier:
            break
        case Segues.showNearby.identifier:
            let nearby = Segues.showNearby(segue: segue)?.destination
            let center: CLLocation?
            switch (lastUserLocation?.coordinate, mapView?.centerCoordinate) {
            case (nil, let map?):
                center = map.location
            case let (user?, map?):
                let distance = user.distance(from: map)
                center = distance < constants.filterNearby ? nil : map.location
            default:
                center = nil
            }
            // log.todo("handle non-annotated places")
            nearby?.inject(model: (center: center, annotations: allAnnotations))
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
        mapDisplay = data.mapDisplay
        showAnnotations()
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

extension LocationsVC: PlaceAnnotationDelegate {

    func close(place: PlaceAnnotation) {
        mapView?.deselectAnnotation(place, animated: true)
    }

    func notify(place: PlaceAnnotation) {
        notify(list: place.list,
               info: place.info)
    }

    func reveal(place: PlaceAnnotation?,
                callout: Bool) {
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

    func centerOnDevice() {
        guard !mapCentered,
              let here = locationManager.location?.coordinate else { return }

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
                    self?.setupAnnotations()
                }
            )
        }
    }

    func setupAnnotations() {
        guard !annotationsSet, mapCentered, mapLoaded else { return }

        annotationsSet = true
        registerAnnotationViews()
        updateAnnotations()
        observe()
    }

    func updateAnnotations() {
        shownRect = mapView?.visibleMapRect ?? .null
        showAnnotations()
    }

    func showAnnotations() {
        guard annotationsSet else { return }

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
        guard shown, !shownRect.isNull else { return [] }

        return Set<PlaceAnnotation>(list.places.compactMap { place in
            guard place.placeIsMappable else { return nil }

            let coordinate = place.placeCoordinate
            guard !coordinate.isZero else {
                log.warning("Coordinates missing: \(list) \(place.placeId), \(place.placeTitle)")
                return nil
            }
            guard shownRect.contains(MKMapPoint(coordinate)) else { return nil }

            return PlaceAnnotation(
                list: list,
                info: place,
                delegate: self
            )
        })
    }

    func showBeaches() {
        guard annotationsSet else { return }
        let new = annotations(list: .beaches, shown: mapDisplay.beaches)

        let subtracted = beachesAnnotations.subtracting(new)
        mapView?.removeAnnotations(Array(subtracted))
        beachesAnnotations.subtract(subtracted)

        let added = new.subtracting(beachesAnnotations)
        mapView?.addAnnotations(Array(added))
        beachesAnnotations.formUnion(added)
    }

    func showDiveSites() {
        guard annotationsSet else { return }
        let new = annotations(list: .divesites, shown: mapDisplay.divesites)

        let subtracted = divesitesAnnotations.subtracting(new)
        mapView?.removeAnnotations(Array(subtracted))
        divesitesAnnotations.subtract(subtracted)

        let added = new.subtracting(divesitesAnnotations)
        mapView?.addAnnotations(Array(added))
        divesitesAnnotations.formUnion(added)
    }

    func showGolfCourses() {
        guard annotationsSet else { return }
        let new = annotations(list: .golfcourses, shown: mapDisplay.golfcourses)

        let subtracted = golfcoursesAnnotations.subtracting(new)
        mapView?.removeAnnotations(Array(subtracted))
        golfcoursesAnnotations.subtract(subtracted)

        let added = new.subtracting(golfcoursesAnnotations)
        mapView?.addAnnotations(Array(added))
        golfcoursesAnnotations.formUnion(added)
    }

    func showLocations() {
        guard annotationsSet else { return }
        let new = annotations(list: .locations, shown: mapDisplay.locations)

        let subtracted = locationsAnnotations.subtracting(new)
        mapView?.removeAnnotations(Array(subtracted))
        locationsAnnotations.subtract(subtracted)

        let added = new.subtracting(locationsAnnotations)
        mapView?.addAnnotations(Array(added))
        locationsAnnotations.formUnion(added)
    }

    func showRestaurants() {
        guard annotationsSet else { return }
        let new = annotations(list: .restaurants, shown: mapDisplay.restaurants)

        let subtracted = restaurantsAnnotations.subtracting(new)
        mapView?.removeAnnotations(Array(subtracted))
        restaurantsAnnotations.subtract(subtracted)

        let added = new.subtracting(restaurantsAnnotations)
        mapView?.addAnnotations(Array(added))
        restaurantsAnnotations.formUnion(added)
    }

    func showWHSs() {
        guard annotationsSet else { return }
        let new = annotations(list: .whss, shown: mapDisplay.whss)

        let subtracted = whssAnnotations.subtracting(new)
        mapView?.removeAnnotations(Array(subtracted))
        whssAnnotations.subtract(subtracted)

        let added = new.subtracting(whssAnnotations)
        mapView?.addAnnotations(Array(added))
        whssAnnotations.formUnion(added)
    }

    func updateDistances() {
        guard let location = lastUserLocation else { return }

        allAnnotations.forEach {
            $0.forEach {
                $0.setDistance(from: location, trigger: true)
            }
        }

        guard data.isVisitsLoaded else { return }

        let list = Checklist.locations
        for place in list.places {
            guard place.placeIsMappable,
                  !list.isVisited(id: place.placeId),
                  !list.isTriggered(id: place.placeId),
                  !list.isDismissed(id: place.placeId),
                  data.worldMap.contains(
                      coordinate: location.coordinate,
                      location: place.placeId) else { continue }

            list.set(triggered: true, id: place.placeId)
            notify(list: list, info: place)
        }
    }

    func checkTriggered() {
        for list in Checklist.allCases {
            for next in data.triggered?[list] ?? [] {
                if list.isVisited(id: next) ||
                   list.isDismissed(id: next) {
                    list.set(triggered: false, id: next)
                } else if let info = list.place(id: next) {
                    notify(list: list, info: info)
                    return
                }
            }
        }
    }

    func notify(list: Checklist,
                info: PlaceInfo) {
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
        log.todo("go to not shown annotations too")
        if let user = data.user,
           let annotation = shown(list: list)
                            .first(where: { $0.id == id }) {
            mainTBC?.route(to: annotation)

            let contentTitle = Localized.congratulations(annotation.info.placeTitle)

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
        for other in shown(list: place.list) {
            guard other.id != place.id,
                  !other.isVisited else { continue }

            let otherDistance = other.coordinate.distance(from: place.coordinate)
            if otherDistance < distance {
                nearest = other.info.placeTitle
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
        guard UIApplication.shared.applicationState == .background else { return }

        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            switch settings.authorizationStatus {
            case .authorized:
                DispatchQueue.main.async { [weak self] in
                    self?.postLocalNotification(list: list,
                                                info: info)
                }
            default:
                break
            }
        }
    }

    func postLocalNotification(list: Checklist,
                               info: PlaceInfo) {
        let content = UNMutableNotificationContent()
        content.title = Localized.checkinTitle(list.category)
        switch list {
        case .locations:
            content.body = Localized.checkinInside(info.placeTitle)
        default:
            content.body = Localized.checkinNear(info.placeTitle)
        }
        content.categoryIdentifier = NotificationsHandler.visitCategory
        content.userInfo = [NotificationsHandler.visitList: list.rawValue,
                            NotificationsHandler.visitId: info.placeId]
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}

extension LocationsVC: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {
        if searchText.isEmpty {
            dropdownItems = []
        } else {
            dropdownItems = Checklist.allCases.flatMap { list in
                list.places.compactMap { place in
                    guard place.placeIsMappable else { return nil }

                    let name = place.placeTitle
                    let match = name.range(of: searchText, options: .caseInsensitive) != nil
                    return match ? name : nil
                }
            }
        }

        dropdown.dataSource = dropdownItems
        if dropdownItems.isEmpty {
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
        log.todo("Selected item at index: \(index)")
    }
}

extension LocationsVC: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView,
                 regionWillChangeAnimated: Bool) {
    }
    func mapView(_ mapView: MKMapView,
                 regionDidChangeAnimated: Bool) {
        updateAnnotations()
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
        setupAnnotations()
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

extension LocationsVC: LocationTracker {

    func accessRefused() {
        mapCentered = true
        setupAnnotations()
    }

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let newUser = locations.last else { return }

        if let lastUser = lastUserLocation,
           lastUser.distance(from: newUser) < constants.filterTrigger {
            return
        }

        lastUserLocation = newUser
        updateDistances()
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
            self.centerOnDevice()
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
        @unknown default:
            authorized = false
        }
        isHidden = !authorized
    }
}

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
