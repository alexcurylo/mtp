// @copyright Trollwerks Inc.

import CoreLocation
import RealmSwift
import UIKit

// swiftlint:disable file_length

final class LocationHandler: NSObject, AppHandler, ServiceProvider {

    let locationManager = CLLocationManager {
        $0.distanceFilter = 50
        $0.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    var lastCoordinate: CLLocation?
    var lastInside: Int?

    private var trackers: Set<AnyHashable> = []

    func insert<T>(tracker: T) where T: LocationTracker, T: Hashable {
        trackers.insert(AnyHashable(tracker))
    }

    func remove<T>(tracker: T) where T: LocationTracker, T: Hashable {
        trackers.remove(tracker)
    }

     func annotations(list: Checklist?) -> Set<PlaceAnnotation> {
        switch list {
        case .beaches?: return beaches
        case .divesites?: return divesites
        case .golfcourses?: return golfcourses
        case .locations?: return locations
        case .restaurants?: return restaurants
        case .uncountries?: return []
        case .whss?: return whss
        case nil: return all
        }
    }

    private var beaches: Set<PlaceAnnotation> = []
    private var divesites: Set<PlaceAnnotation> = []
    private var golfcourses: Set<PlaceAnnotation> = []
    private var locations: Set<PlaceAnnotation> = []
    private var restaurants: Set<PlaceAnnotation> = []
    private var whss: Set<PlaceAnnotation> = []
    // UN Countries not mapped
    private var all: Set<PlaceAnnotation> {
        return beaches
            .union(golfcourses)
            .union(divesites)
            .union(locations)
            .union(restaurants)
            .union(whss)
    }

    private var beachesObserver: Observer?
    private var divesitesObserver: Observer?
    private var golfcoursesObserver: Observer?
    private var locationsObserver: Observer?
    private var restaurantsObserver: Observer?
    private var whssObserver: Observer?

    private var queue = OperationQueue {
        $0.name = "annotations"
        $0.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
        $0.qualityOfService = .userInteractive
    }
    private var distanceUpdate: UpdateDistanceOperation?
    private var distancesUpdating: Int = 0 {
        didSet { checkDistanceUpdate() }
    }
    private var placesUpdating: Int = 0 {
        didSet { checkDistanceUpdate() }
    }

    // log.todo("adjust to half of minimum unvisited? Separate for countries?")
    //private let minFilter = CLLocationDistance(20)
    private var distanceFilter = CLLocationDistance(20)
    private var timeFilter = TimeInterval(5)
    private var lastFilter: Date?
}

// MARK: - AppLaunchHandler

extension LocationHandler: AppLaunchHandler {

    func application(_ application: UIApplication,
                     // swiftlint:disable:next discouraged_optional_collection
                     willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        locationManager.delegate = self
        loc.inject(handler: self)
        observe()

        return true
    }

    func application(_ application: UIApplication,
                     // swiftlint:disable:next discouraged_optional_collection
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //let options = launchOptions ?? [:]
        //if options.keys.contains(.location) { }

        return true
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationHandler: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let now = locations.last else { return }
        if let last = lastCoordinate,
           last.distance(from: now) < distanceFilter {
            return
        }
        if let lastFilter = lastFilter,
            -lastFilter.timeIntervalSinceNow < timeFilter {
            return
        }

        lastCoordinate = now
        broadcast { $0.location(changed: now) }
        update(distances: now)
        lastFilter = Date()
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
        broadcast { $0.authorization(changed: status) }
    }

    func locationManager(_ manager: CLLocationManager,
                         didFinishDeferredUpdatesWithError error: Error?) {
        log.error(#function)
    }

    func locationManager(_ manager: CLLocationManager,
                         didVisit visit: CLVisit) {
    }
}

// MARK: - PlaceAnnotationDelegate

extension LocationHandler: PlaceAnnotationDelegate {

    func close(place: PlaceAnnotation) {
        broadcast { $0.close(place: place) }
    }

    func notify(place: PlaceAnnotation) {
        broadcast { $0.notify(place: place) }
    }

    func reveal(place: PlaceAnnotation?,
                callout: Bool) {
        broadcast { $0.reveal(place: place, callout: callout) }
    }

    func show(place: PlaceAnnotation) {
        broadcast { $0.show(place: place) }
    }

    func update(place: PlaceAnnotation) {
        broadcast { $0.update(place: place) }
    }
}

// MARK: - Private

private extension LocationHandler {

    func broadcast(then: @escaping (LocationTracker) -> Void) {
        DispatchQueue.main.async {
            self.trackers.forEach {
                guard let tracker = $0 as? LocationTracker else { return }
                then(tracker)
            }
        }
    }

    func update(distances from: CLLocation) {
        let trigger = data.isVisitsLoaded
        guard distanceUpdate == nil else { return }

        let update = UpdateDistanceOperation(trigger: trigger,
                                             handler: self,
                                             map: data.worldMap)
        update.completionBlock = {
            DispatchQueue.main.async {
                self.distancesUpdating -= 1
                self.note.checkTriggered()
            }
        }

        if placesUpdating > 0 || distancesUpdating > 0 {
            distanceUpdate = update
        } else {
            start(distance: update)
        }
    }

    func checkDistanceUpdate() {
        if let update = distanceUpdate,
           placesUpdating == 0,
           distancesUpdating == 0 {
            start(distance: update)
        }
    }

    func start(distance: UpdateDistanceOperation) {
        distanceUpdate = nil
        distancesUpdating += 1
        queue.addOperation(distance)
    }

    func update(list: Checklist) {
        guard !queue.contains(list: list) else { return }

        let update = UpdateListOperation(list: list,
                                         trigger: data.isVisitsLoaded,
                                         delegate: self)
        update.completionBlock = {
            DispatchQueue.main.async {
                self.updated(list: list, new: update.annotations)
                self.placesUpdating -= 1
            }
        }
        placesUpdating += 1
        queue.addOperation(update)
    }

    func updated(list: Checklist,
                 new: Set<PlaceAnnotation>) {
        switch list {
        case .beaches: updated(list: list, set: &beaches, new: new)
        case .divesites: updated(list: list, set: &divesites, new: new)
        case .golfcourses: updated(list: list, set: &golfcourses, new: new)
        case .locations: updated(list: list, set: &locations, new: new)
        case .restaurants: updated(list: list, set: &restaurants, new: new)
        case .uncountries: break
        case .whss: updated(list: list, set: &whss, new: new)
        }
    }

    func updated(list: Checklist,
                 set: inout Set<PlaceAnnotation>,
                 new: Set<PlaceAnnotation>) {
        let removed = set.subtracting(new)
        set.subtract(removed)

        let added = new.subtracting(set)
        set.formUnion(added)

        broadcast {
            $0.annotations(changed: list,
                           added: added,
                           removed: removed)
        }
    }

    func observe() {
        update(list: .beaches)
        beachesObserver = Checklist.beaches.observer { _ in
            self.update(list: .beaches)
        }
        update(list: .divesites)
        divesitesObserver = Checklist.divesites.observer { _ in
            self.update(list: .divesites)
        }
        update(list: .golfcourses)
        golfcoursesObserver = Checklist.golfcourses.observer { _ in
            self.update(list: .golfcourses)
        }
        update(list: .locations)
        locationsObserver = Checklist.locations.observer { _ in
            self.update(list: .locations)
        }
        update(list: .restaurants)
        restaurantsObserver = Checklist.restaurants.observer { _ in
            self.update(list: .restaurants)
        }
        update(list: .whss)
        whssObserver = Checklist.whss.observer { _ in
            self.update(list: .whss)
        }
    }
}

private class UpdateListOperation: KVNOperation, ServiceProvider {

    let list: Checklist
    let places: [ThreadSafeReference<Object>]
    private weak var delegate: LocationHandler?
    let here: CLLocationCoordinate2D
    let trigger: Bool

    var annotations: Set<PlaceAnnotation> = []

    init(list: Checklist,
         trigger: Bool,
         delegate: LocationHandler) {
        self.list = list
        self.delegate = delegate
        self.trigger = trigger
        here = delegate.lastCoordinate?.coordinate ?? .zero
        places = list.places.compactMap {
            guard let object = $0 as? Object else { return nil }
            return ThreadSafeReference(to: object)
        }
    }

    override func operate() {
        guard let realm = try? Realm() else { return }

        annotations = Set<PlaceAnnotation>(places.compactMap { placeRef in
            guard let place = realm.resolve(placeRef) as? PlaceInfo,
                  place.placeIsMappable,
                  let delegate = delegate else { return nil }

            let coordinate = place.placeCoordinate
            guard !coordinate.isZero else {
                log.warning("Coordinates missing: \(list) \(place.placeId), \(place.placeTitle)")
                return nil
            }

            guard let annotation = PlaceAnnotation(
                list: list,
                info: place,
                coordinate: coordinate,
                delegate: delegate
                ) else { return nil }
            if !here.isZero {
                annotation.setDistance(from: here)
            }

            return annotation
        })
    }
}

private class UpdateDistanceOperation: KVNOperation {

    let trigger: Bool
    let handler: LocationHandler
    let map: WorldMap

    init(trigger: Bool,
         handler: LocationHandler,
         map: WorldMap) {
        self.trigger = trigger
        self.handler = handler
        self.map = map
    }

    override func operate() {
        guard let here = handler.lastCoordinate?.coordinate else { return }

        #if INSTRUMENT_DISTANCE
        let start = Date()
        #endif
        let annotations = handler.annotations(list: nil)
        annotations.forEach {
            $0.setDistance(from: here)
            guard trigger else { return }

            switch $0.list {
            case .locations:
                if $0.trigger(contains: here, map: map) {
                    handler.lastInside = $0.id
                }
            #if TEST_TRIGGERED_NEARBY
            case .whss where $0.id == WHS.Children.tornea.rawValue:
                $0._testTriggeredNearby()
            case .whss where $0.id == WHS.Singles.angkor.rawValue:
                $0._testTriggeredNearby()
            #endif
            default:
                $0.triggerDistance()
            }
        }
        #if INSTRUMENT_DISTANCE
        let time = -start.timeIntervalSinceNow
        let title = "Distances: \(annotations.count) in \(Int(time * 1_000)) ms"
        let body = ""
        handler.note.infoBackground(title: title, body: body)
        #endif
    }
}

private extension OperationQueue {

    func contains(list: Checklist) -> Bool {
        for operation in operations {
            if let update = operation as? UpdateListOperation,
                update.list == list { return true }
        }
        return false
    }

    func contains(distance trigger: Bool) -> Bool {
        for operation in operations {
            if let update = operation as? UpdateDistanceOperation,
               update.trigger == trigger { return true }
        }
        return false
    }
}
