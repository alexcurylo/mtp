// @copyright Trollwerks Inc.

import CoreLocation
import RealmSwift
import UIKit

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
        $0.maxConcurrentOperationCount = 1
        $0.qualityOfService = .userInteractive
    }
    private var distanceUpdate: DistancesOperation?
    private var distancesUpdating: Int = 0 {
        didSet { checkDistanceUpdate() }
    }

    private var distanceFilter = CLLocationDistance(50)
    private var timeFilter = TimeInterval(5)
    private var lastFilter: Date?

    func broadcast(then: @escaping (LocationTracker) -> Void) {
        DispatchQueue.main.async {
            self.trackers.forEach {
                guard let tracker = $0 as? LocationTracker else { return }
                then(tracker)
            }
        }
    }

    func broadcast(mappable: Mappable,
                   then: @escaping (LocationTracker, Mappable) -> Void) {
        let reference = mappable.reference
        DispatchQueue.main.async {
            guard let resolved = self.data.resolve(reference: reference) else { return }

            self.trackers.forEach {
                guard let tracker = $0 as? LocationTracker else { return }
                then(tracker, resolved)
            }
        }
    }
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
                         didUpdateHeading newHeading: CLHeading) { }
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }

    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) { }
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) { }
    func locationManager(_ manager: CLLocationManager,
                         didDetermineState state: CLRegionState,
                         for region: CLRegion) { }
    func locationManager(_ manager: CLLocationManager,
                         didEnterRegion region: CLRegion) { }
    func locationManager(_ manager: CLLocationManager,
                         didExitRegion region: CLRegion) { }
    func locationManager(_ manager: CLLocationManager,
                         didRangeBeacons beacons: [CLBeacon],
                         in region: CLBeaconRegion) { }
    func locationManager(_ manager: CLLocationManager,
                         rangingBeaconsDidFailFor region: CLBeaconRegion,
                         withError error: Error) { }
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) { }
    func locationManager(_ manager: CLLocationManager,
                         didStartMonitoringFor region: CLRegion) { }
    func locationManager(_ manager: CLLocationManager,
                         monitoringDidFailFor region: CLRegion?,
                         withError error: Error) { }

    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        broadcast { $0.authorization(changed: status) }
    }

    func locationManager(_ manager: CLLocationManager,
                         didFinishDeferredUpdatesWithError error: Error?) {}
    func locationManager(_ manager: CLLocationManager,
                         didVisit visit: CLVisit) { }
}

// MARK: - Private

private extension LocationHandler {

    func update(distances from: CLLocation) {
        let trigger = data.isVisitsLoaded
        guard let here = lastCoordinate?.coordinate,
              distanceUpdate == nil else { return }
        let update = DistancesOperation(center: here,
                                        mappables: data.mappables,
                                        handler: self,
                                        trigger: trigger,
                                        world: data.worldMap)
        update.completionBlock = {
            DispatchQueue.main.async {
                self.distances = update.distances
                self.distancesUpdating -= 1
                self.note.checkTriggered()
            }
        }

        if distancesUpdating > 0 {
            distanceUpdate = update
        } else {
            start(distance: update)
        }
    }

    func checkDistanceUpdate() {
        if let update = distanceUpdate,
           distancesUpdating == 0 {
            start(distance: update)
        }
    }

    func start(distance: DistancesOperation) {
        distanceUpdate = nil
        distancesUpdating += 1
        queue.addOperation(distance)
    }

    func observe() {
        beachesObserver = Checklist.beaches.observer { _ in
            self.checkDistanceUpdate()
        }
        divesitesObserver = Checklist.divesites.observer { _ in
            self.checkDistanceUpdate()
        }
        golfcoursesObserver = Checklist.golfcourses.observer { _ in
            self.checkDistanceUpdate()
        }
        locationsObserver = Checklist.locations.observer { _ in
            self.checkDistanceUpdate()
        }
        restaurantsObserver = Checklist.restaurants.observer { _ in
            self.checkDistanceUpdate()
        }
        whssObserver = Checklist.whss.observer { _ in
            self.checkDistanceUpdate()
        }
    }
}

final class DistancesOperation: KVNOperation {

    var distances: Distances = [:]

    private let center: CLLocationCoordinate2D
    private let handler: LocationHandler?
    private let trigger: Bool
    private let references: [Mappable.Reference]
    private let world: WorldMap

    init(center: CLLocationCoordinate2D,
         mappables: [Mappable],
         handler: LocationHandler?,
         trigger: Bool,
         world: WorldMap) {
        self.center = center
        self.handler = handler
        self.trigger = trigger
        self.references = mappables.compactMap { $0.reference }
        self.world = world
    }

    override func operate() {
        guard let realm = try? Realm() else { return }

        #if INSTRUMENT_DISTANCE
        let start = Date()
        #endif

        references.forEach {
            guard let mappable = realm.resolve($0) else { return }

            let distance = mappable.coordinate.distance(from: center)
            distances[mappable.dbKey] = distance
            guard trigger, let handler = handler else { return }

            switch mappable.checklist {
            case .locations:
                if mappable.trigger(contains: center, world: world) {
                    handler.lastInside = mappable.checklistId
                }
            #if TEST_TRIGGERED_NEARBY
            case .whss where mappable.checklistId == WHS.Children.tornea.rawValue:
                mappable._testTriggeredNearby()
            case .whss where mappable.checklistId == WHS.Singles.angkor.rawValue:
                mappable._testTriggeredNearby()
            #endif
            default:
                mappable.trigger(distance: distance)
            }
        }

        #if INSTRUMENT_DISTANCE
        let time = -start.timeIntervalSinceNow
        let results = "Distances: \(references.count) in \(Int(time * 1_000)) ms"
        ConsoleLoggingService().info(results)
        handler?.note.postInfo(title: results, body: "")
        #endif
    }
}
