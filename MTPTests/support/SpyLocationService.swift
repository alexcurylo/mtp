// @copyright Trollwerks Inc.

import CoreLocation
@testable import MTP

// swiftlint:disable let_var_whitespace implicitly_unwrapped_optional
final class SpyLocationService: LocationService {
    var invokedHereGetter = false
    var invokedHereGetterCount = 0
    var stubbedHere: CLLocationCoordinate2D!
    var here: CLLocationCoordinate2D? {
        invokedHereGetter = true
        invokedHereGetterCount += 1
        return stubbedHere
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
}
