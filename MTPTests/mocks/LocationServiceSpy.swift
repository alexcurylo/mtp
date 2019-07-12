// @copyright Trollwerks Inc.

import CoreLocation
@testable import MTP

// generated by https://github.com/seanhenry/SwiftMockGeneratorForXcode
// swiftlint:disable all

final class LocationServiceSpy: LocationService {
    var invokedHereGetter = false
    var invokedHereGetterCount = 0
    var stubbedHere: CLLocationCoordinate2D!
    var here: CLLocationCoordinate2D? {
        invokedHereGetter = true
        invokedHereGetterCount += 1
        return stubbedHere
    }
    var invokedInsideGetter = false
    var invokedInsideGetterCount = 0
    var stubbedInside: Location!
    var inside: Location? {
        invokedInsideGetter = true
        invokedInsideGetterCount += 1
        return stubbedInside
    }
    var invokedDistancesGetter = false
    var invokedDistancesGetterCount = 0
    var stubbedDistances: Distances!
    var distances: Distances {
        invokedDistancesGetter = true
        invokedDistancesGetterCount += 1
        return stubbedDistances
    }
    var invokedAppGetter = false
    var invokedAppGetterCount = 0
    var stubbedApp: ApplicationService!
    var app: ApplicationService {
        invokedAppGetter = true
        invokedAppGetterCount += 1
        return stubbedApp
    }
    var invokedDataGetter = false
    var invokedDataGetterCount = 0
    var stubbedData: DataService!
    var data: DataService {
        invokedDataGetter = true
        invokedDataGetterCount += 1
        return stubbedData
    }
    var invokedLocGetter = false
    var invokedLocGetterCount = 0
    var stubbedLoc: LocationService!
    var loc: LocationService {
        invokedLocGetter = true
        invokedLocGetterCount += 1
        return stubbedLoc
    }
    var invokedLogGetter = false
    var invokedLogGetterCount = 0
    var stubbedLog: LoggingService!
    var log: LoggingService {
        invokedLogGetter = true
        invokedLogGetterCount += 1
        return stubbedLog
    }
    var invokedMtpGetter = false
    var invokedMtpGetterCount = 0
    var stubbedMtp: MTPNetworkService!
    var mtp: MTPNetworkService {
        invokedMtpGetter = true
        invokedMtpGetterCount += 1
        return stubbedMtp
    }
    var invokedNoteGetter = false
    var invokedNoteGetterCount = 0
    var stubbedNote: NotificationService!
    var note: NotificationService {
        invokedNoteGetter = true
        invokedNoteGetterCount += 1
        return stubbedNote
    }
    var invokedDistance = false
    var invokedDistanceCount = 0
    var invokedDistanceParameters: (to: Mappable, Void)?
    var invokedDistanceParametersList = [(to: Mappable, Void)]()
    var stubbedDistanceResult: CLLocationDistance!
    func distance(to: Mappable) -> CLLocationDistance {
        invokedDistance = true
        invokedDistanceCount += 1
        invokedDistanceParameters = (to, ())
        invokedDistanceParametersList.append((to, ()))
        return stubbedDistanceResult
    }
    var invokedNearest = false
    var invokedNearestCount = 0
    var invokedNearestParameters: (list: Checklist, id: Int, coordinate: CLLocationCoordinate2D)?
    var invokedNearestParametersList = [(list: Checklist, id: Int, coordinate: CLLocationCoordinate2D)]()
    var stubbedNearestResult: Mappable!
    func nearest(list: Checklist,
    id: Int,
    to coordinate: CLLocationCoordinate2D) -> Mappable? {
        invokedNearest = true
        invokedNearestCount += 1
        invokedNearestParameters = (list, id, coordinate)
        invokedNearestParametersList.append((list, id, coordinate))
        return stubbedNearestResult
    }
    var invokedRequest = false
    var invokedRequestCount = 0
    var invokedRequestParameters: (permission: LocationPermission, Void)?
    var invokedRequestParametersList = [(permission: LocationPermission, Void)]()
    func request(permission: LocationPermission) {
        invokedRequest = true
        invokedRequestCount += 1
        invokedRequestParameters = (permission, ())
        invokedRequestParametersList.append((permission, ()))
    }
    var invokedStart = false
    var invokedStartCount = 0
    var invokedStartParameters: (permission: LocationPermission, Void)?
    var invokedStartParametersList = [(permission: LocationPermission, Void)]()
    func start(permission: LocationPermission) {
        invokedStart = true
        invokedStartCount += 1
        invokedStartParameters = (permission, ())
        invokedStartParametersList.append((permission, ()))
    }
    var invokedInsert = false
    var invokedInsertCount = 0
    var invokedInsertParameters: (tracker: Any, Void)?
    var invokedInsertParametersList = [(tracker: Any, Void)]()
    func insert<T>(tracker: T) where T: LocationTracker, T: Hashable {
        invokedInsert = true
        invokedInsertCount += 1
        invokedInsertParameters = (tracker, ())
        invokedInsertParametersList.append((tracker, ()))
    }
    var invokedRemove = false
    var invokedRemoveCount = 0
    var invokedRemoveParameters: (tracker: Any, Void)?
    var invokedRemoveParametersList = [(tracker: Any, Void)]()
    func remove<T>(tracker: T) where T: LocationTracker, T: Hashable {
        invokedRemove = true
        invokedRemoveCount += 1
        invokedRemoveParameters = (tracker, ())
        invokedRemoveParametersList.append((tracker, ()))
    }
    var invokedInject = false
    var invokedInjectCount = 0
    var invokedInjectParameters: (handler: LocationHandler, Void)?
    var invokedInjectParametersList = [(handler: LocationHandler, Void)]()
    func inject(handler: LocationHandler) {
        invokedInject = true
        invokedInjectCount += 1
        invokedInjectParameters = (handler, ())
        invokedInjectParametersList.append((handler, ()))
    }
    var invokedClose = false
    var invokedCloseCount = 0
    var invokedCloseParameters: (mappable: Mappable, Void)?
    var invokedCloseParametersList = [(mappable: Mappable, Void)]()
    func close(mappable: Mappable) {
        invokedClose = true
        invokedCloseCount += 1
        invokedCloseParameters = (mappable, ())
        invokedCloseParametersList.append((mappable, ()))
    }
    var invokedNotify = false
    var invokedNotifyCount = 0
    var invokedNotifyParameters: (mappable: Mappable, triggered: Date)?
    var invokedNotifyParametersList = [(mappable: Mappable, triggered: Date)]()
    func notify(mappable: Mappable, triggered: Date) {
        invokedNotify = true
        invokedNotifyCount += 1
        invokedNotifyParameters = (mappable, triggered)
        invokedNotifyParametersList.append((mappable, triggered))
    }
    var invokedReveal = false
    var invokedRevealCount = 0
    var invokedRevealParameters: (mappable: Mappable, callout: Bool)?
    var invokedRevealParametersList = [(mappable: Mappable, callout: Bool)]()
    func reveal(mappable: Mappable, callout: Bool) {
        invokedReveal = true
        invokedRevealCount += 1
        invokedRevealParameters = (mappable, callout)
        invokedRevealParametersList.append((mappable, callout))
    }
    var invokedShow = false
    var invokedShowCount = 0
    var invokedShowParameters: (mappable: Mappable, Void)?
    var invokedShowParametersList = [(mappable: Mappable, Void)]()
    func show(mappable: Mappable) {
        invokedShow = true
        invokedShowCount += 1
        invokedShowParameters = (mappable, ())
        invokedShowParametersList.append((mappable, ()))
    }
    var invokedUpdate = false
    var invokedUpdateCount = 0
    var invokedUpdateParameters: (mappable: Mappable, Void)?
    var invokedUpdateParametersList = [(mappable: Mappable, Void)]()
    func update(mappable: Mappable) {
        invokedUpdate = true
        invokedUpdateCount += 1
        invokedUpdateParameters = (mappable, ())
        invokedUpdateParametersList.append((mappable, ()))
    }
}
