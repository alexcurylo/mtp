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

    var distances: Distances = [:]

    private var beachesObserver: Observer?
    private var divesitesObserver: Observer?
    private var golfcoursesObserver: Observer?
    private var locationsObserver: Observer?
    private var restaurantsObserver: Observer?
    private var whssObserver: Observer?

    private var queue = OperationQueue {
        $0.name = typeName
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

    private var distanceFilter = CLLocationDistance(50)
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
                                             mappables: data.mappables,
                                             handler: self,
                                             world: data.worldMap)
        update.completionBlock = {
            DispatchQueue.main.async {
                self.distances = update.distances
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
        #if CREATE_ANNOTATIONS
        guard !queue.contains(list: list) else { return }

        let update = UpdateListOperation(list: list,
                                         trigger: data.isVisitsLoaded,
                                         delegate: self)
        update.completionBlock = {
            DispatchQueue.main.async {
                self.updated(list: list, new: update.mappables)
                self.placesUpdating -= 1
            }
        }
        placesUpdating += 1
        queue.addOperation(update)
        #else
        log.todo("remove UpdateListOperation?")
        checkDistanceUpdate()
        #endif
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
    let world: WorldMap
    let places: [ThreadSafeReference<Object>]

    var distances: Distances = [:]

    init(trigger: Bool,
         mappables: [Mappable],
         handler: LocationHandler,
         world: WorldMap) {
        self.trigger = trigger
        self.handler = handler
        self.world = world
        places = mappables.compactMap {
            ThreadSafeReference(to: $0)
        }
    }

    override func operate() {
        guard let here = handler.lastCoordinate?.coordinate,
              let realm = try? Realm() else { return }

        #if INSTRUMENT_DISTANCE
        let start = Date()
        #endif

        places.forEach {
            guard let place = realm.resolve($0) as? Mappable else { return }

            let distance = place.coordinate.distance(from: here)
            distances[place.dbKey] = distance
            guard trigger else { return }

            switch place.checklist {
            case .locations:
                if place.trigger(contains: here, world: world) {
                    handler.lastInside = place.checklistId
                }
            #if TEST_TRIGGERED_NEARBY
            case .whss where place.checklistId == WHS.Children.tornea.rawValue:
                place._testTriggeredNearby()
            case .whss where place.checklistId == WHS.Singles.angkor.rawValue:
                place._testTriggeredNearby()
            #endif
            default:
                place.trigger(distance: distance)
            }
        }

        #if INSTRUMENT_DISTANCE
        let time = -start.timeIntervalSinceNow
        let title = "Distances: \(places.count) in \(Int(time * 1_000)) ms"
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
