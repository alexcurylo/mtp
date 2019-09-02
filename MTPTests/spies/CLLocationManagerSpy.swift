// @copyright Trollwerks Inc.

import CoreLocation
@testable import MTP

// generated by https://github.com/seanhenry/SwiftMockGeneratorForXcode
// swiftlint:disable all

final class CLLocationManagerSpy: CLLocationManager {
    var invokedDelegateSetter = false
    var invokedDelegateSetterCount = 0
    var invokedDelegate: CLLocationManagerDelegate?
    var invokedDelegateList = [CLLocationManagerDelegate?]()
    var invokedDelegateGetter = false
    var invokedDelegateGetterCount = 0
    var stubbedDelegate: CLLocationManagerDelegate!
    override var delegate: CLLocationManagerDelegate? {
        set {
            invokedDelegateSetter = true
            invokedDelegateSetterCount += 1
            invokedDelegate = newValue
            invokedDelegateList.append(newValue)
        }
        get {
            invokedDelegateGetter = true
            invokedDelegateGetterCount += 1
            return stubbedDelegate
        }
    }
    var invokedActivityTypeSetter = false
    var invokedActivityTypeSetterCount = 0
    var invokedActivityType: CLActivityType?
    var invokedActivityTypeList = [CLActivityType]()
    var invokedActivityTypeGetter = false
    var invokedActivityTypeGetterCount = 0
    var stubbedActivityType: CLActivityType!
    override var activityType: CLActivityType {
        set {
            invokedActivityTypeSetter = true
            invokedActivityTypeSetterCount += 1
            invokedActivityType = newValue
            invokedActivityTypeList.append(newValue)
        }
        get {
            invokedActivityTypeGetter = true
            invokedActivityTypeGetterCount += 1
            return stubbedActivityType
        }
    }
    var invokedDistanceFilterSetter = false
    var invokedDistanceFilterSetterCount = 0
    var invokedDistanceFilter: CLLocationDistance?
    var invokedDistanceFilterList = [CLLocationDistance]()
    var invokedDistanceFilterGetter = false
    var invokedDistanceFilterGetterCount = 0
    var stubbedDistanceFilter: CLLocationDistance!
    override var distanceFilter: CLLocationDistance {
        set {
            invokedDistanceFilterSetter = true
            invokedDistanceFilterSetterCount += 1
            invokedDistanceFilter = newValue
            invokedDistanceFilterList.append(newValue)
        }
        get {
            invokedDistanceFilterGetter = true
            invokedDistanceFilterGetterCount += 1
            return stubbedDistanceFilter
        }
    }
    var invokedDesiredAccuracySetter = false
    var invokedDesiredAccuracySetterCount = 0
    var invokedDesiredAccuracy: CLLocationAccuracy?
    var invokedDesiredAccuracyList = [CLLocationAccuracy]()
    var invokedDesiredAccuracyGetter = false
    var invokedDesiredAccuracyGetterCount = 0
    var stubbedDesiredAccuracy: CLLocationAccuracy!
    override var desiredAccuracy: CLLocationAccuracy {
        set {
            invokedDesiredAccuracySetter = true
            invokedDesiredAccuracySetterCount += 1
            invokedDesiredAccuracy = newValue
            invokedDesiredAccuracyList.append(newValue)
        }
        get {
            invokedDesiredAccuracyGetter = true
            invokedDesiredAccuracyGetterCount += 1
            return stubbedDesiredAccuracy
        }
    }
    var invokedPausesLocationUpdatesAutomaticallySetter = false
    var invokedPausesLocationUpdatesAutomaticallySetterCount = 0
    var invokedPausesLocationUpdatesAutomatically: Bool?
    var invokedPausesLocationUpdatesAutomaticallyList = [Bool]()
    var invokedPausesLocationUpdatesAutomaticallyGetter = false
    var invokedPausesLocationUpdatesAutomaticallyGetterCount = 0
    var stubbedPausesLocationUpdatesAutomatically: Bool! = false
    override var pausesLocationUpdatesAutomatically: Bool {
        set {
            invokedPausesLocationUpdatesAutomaticallySetter = true
            invokedPausesLocationUpdatesAutomaticallySetterCount += 1
            invokedPausesLocationUpdatesAutomatically = newValue
            invokedPausesLocationUpdatesAutomaticallyList.append(newValue)
        }
        get {
            invokedPausesLocationUpdatesAutomaticallyGetter = true
            invokedPausesLocationUpdatesAutomaticallyGetterCount += 1
            return stubbedPausesLocationUpdatesAutomatically
        }
    }
    var invokedAllowsBackgroundLocationUpdatesSetter = false
    var invokedAllowsBackgroundLocationUpdatesSetterCount = 0
    var invokedAllowsBackgroundLocationUpdates: Bool?
    var invokedAllowsBackgroundLocationUpdatesList = [Bool]()
    var invokedAllowsBackgroundLocationUpdatesGetter = false
    var invokedAllowsBackgroundLocationUpdatesGetterCount = 0
    var stubbedAllowsBackgroundLocationUpdates: Bool! = false
    override var allowsBackgroundLocationUpdates: Bool {
        set {
            invokedAllowsBackgroundLocationUpdatesSetter = true
            invokedAllowsBackgroundLocationUpdatesSetterCount += 1
            invokedAllowsBackgroundLocationUpdates = newValue
            invokedAllowsBackgroundLocationUpdatesList.append(newValue)
        }
        get {
            invokedAllowsBackgroundLocationUpdatesGetter = true
            invokedAllowsBackgroundLocationUpdatesGetterCount += 1
            return stubbedAllowsBackgroundLocationUpdates
        }
    }
    var invokedShowsBackgroundLocationIndicatorSetter = false
    var invokedShowsBackgroundLocationIndicatorSetterCount = 0
    var invokedShowsBackgroundLocationIndicator: Bool?
    var invokedShowsBackgroundLocationIndicatorList = [Bool]()
    var invokedShowsBackgroundLocationIndicatorGetter = false
    var invokedShowsBackgroundLocationIndicatorGetterCount = 0
    var stubbedShowsBackgroundLocationIndicator: Bool! = false
    override var showsBackgroundLocationIndicator: Bool {
        set {
            invokedShowsBackgroundLocationIndicatorSetter = true
            invokedShowsBackgroundLocationIndicatorSetterCount += 1
            invokedShowsBackgroundLocationIndicator = newValue
            invokedShowsBackgroundLocationIndicatorList.append(newValue)
        }
        get {
            invokedShowsBackgroundLocationIndicatorGetter = true
            invokedShowsBackgroundLocationIndicatorGetterCount += 1
            return stubbedShowsBackgroundLocationIndicator
        }
    }
    var invokedLocationSetter = false
    var invokedLocationSetterCount = 0
    var invokedLocation: CLLocation?
    var invokedLocationList = [CLLocation?]()
    var invokedLocationGetter = false
    var invokedLocationGetterCount = 0
    var stubbedLocation: CLLocation!
    override var location: CLLocation? {
        set {
            invokedLocationSetter = true
            invokedLocationSetterCount += 1
            invokedLocation = newValue
            invokedLocationList.append(newValue)
        }
        get {
            invokedLocationGetter = true
            invokedLocationGetterCount += 1
            return stubbedLocation
        }
    }
    var invokedHeadingFilterSetter = false
    var invokedHeadingFilterSetterCount = 0
    var invokedHeadingFilter: CLLocationDegrees?
    var invokedHeadingFilterList = [CLLocationDegrees]()
    var invokedHeadingFilterGetter = false
    var invokedHeadingFilterGetterCount = 0
    var stubbedHeadingFilter: CLLocationDegrees!
    override var headingFilter: CLLocationDegrees {
        set {
            invokedHeadingFilterSetter = true
            invokedHeadingFilterSetterCount += 1
            invokedHeadingFilter = newValue
            invokedHeadingFilterList.append(newValue)
        }
        get {
            invokedHeadingFilterGetter = true
            invokedHeadingFilterGetterCount += 1
            return stubbedHeadingFilter
        }
    }
    var invokedHeadingOrientationSetter = false
    var invokedHeadingOrientationSetterCount = 0
    var invokedHeadingOrientation: CLDeviceOrientation?
    var invokedHeadingOrientationList = [CLDeviceOrientation]()
    var invokedHeadingOrientationGetter = false
    var invokedHeadingOrientationGetterCount = 0
    var stubbedHeadingOrientation: CLDeviceOrientation!
    override var headingOrientation: CLDeviceOrientation {
        set {
            invokedHeadingOrientationSetter = true
            invokedHeadingOrientationSetterCount += 1
            invokedHeadingOrientation = newValue
            invokedHeadingOrientationList.append(newValue)
        }
        get {
            invokedHeadingOrientationGetter = true
            invokedHeadingOrientationGetterCount += 1
            return stubbedHeadingOrientation
        }
    }
    var invokedHeadingSetter = false
    var invokedHeadingSetterCount = 0
    var invokedHeading: CLHeading?
    var invokedHeadingList = [CLHeading?]()
    var invokedHeadingGetter = false
    var invokedHeadingGetterCount = 0
    var stubbedHeading: CLHeading!
    override var heading: CLHeading? {
        set {
            invokedHeadingSetter = true
            invokedHeadingSetterCount += 1
            invokedHeading = newValue
            invokedHeadingList.append(newValue)
        }
        get {
            invokedHeadingGetter = true
            invokedHeadingGetterCount += 1
            return stubbedHeading
        }
    }
    var invokedMaximumRegionMonitoringDistanceSetter = false
    var invokedMaximumRegionMonitoringDistanceSetterCount = 0
    var invokedMaximumRegionMonitoringDistance: CLLocationDistance?
    var invokedMaximumRegionMonitoringDistanceList = [CLLocationDistance]()
    var invokedMaximumRegionMonitoringDistanceGetter = false
    var invokedMaximumRegionMonitoringDistanceGetterCount = 0
    var stubbedMaximumRegionMonitoringDistance: CLLocationDistance!
    override var maximumRegionMonitoringDistance: CLLocationDistance {
        set {
            invokedMaximumRegionMonitoringDistanceSetter = true
            invokedMaximumRegionMonitoringDistanceSetterCount += 1
            invokedMaximumRegionMonitoringDistance = newValue
            invokedMaximumRegionMonitoringDistanceList.append(newValue)
        }
        get {
            invokedMaximumRegionMonitoringDistanceGetter = true
            invokedMaximumRegionMonitoringDistanceGetterCount += 1
            return stubbedMaximumRegionMonitoringDistance
        }
    }
    var invokedMonitoredRegionsSetter = false
    var invokedMonitoredRegionsSetterCount = 0
    var invokedMonitoredRegions: Set<CLRegion>?
    var invokedMonitoredRegionsList = [Set<CLRegion>]()
    var invokedMonitoredRegionsGetter = false
    var invokedMonitoredRegionsGetterCount = 0
    var stubbedMonitoredRegions: Set<CLRegion>! = []
    override var monitoredRegions: Set<CLRegion> {
        set {
            invokedMonitoredRegionsSetter = true
            invokedMonitoredRegionsSetterCount += 1
            invokedMonitoredRegions = newValue
            invokedMonitoredRegionsList.append(newValue)
        }
        get {
            invokedMonitoredRegionsGetter = true
            invokedMonitoredRegionsGetterCount += 1
            return stubbedMonitoredRegions
        }
    }
    var invokedRangedRegionsSetter = false
    var invokedRangedRegionsSetterCount = 0
    var invokedRangedRegions: Set<CLRegion>?
    var invokedRangedRegionsList = [Set<CLRegion>]()
    var invokedRangedRegionsGetter = false
    var invokedRangedRegionsGetterCount = 0
    var stubbedRangedRegions: Set<CLRegion>! = []
    override var rangedRegions: Set<CLRegion> {
        set {
            invokedRangedRegionsSetter = true
            invokedRangedRegionsSetterCount += 1
            invokedRangedRegions = newValue
            invokedRangedRegionsList.append(newValue)
        }
        get {
            invokedRangedRegionsGetter = true
            invokedRangedRegionsGetterCount += 1
            return stubbedRangedRegions
        }
    }
    var invokedRequestWhenInUseAuthorization = false
    var invokedRequestWhenInUseAuthorizationCount = 0
    override func requestWhenInUseAuthorization() {
        invokedRequestWhenInUseAuthorization = true
        invokedRequestWhenInUseAuthorizationCount += 1
    }
    var invokedRequestAlwaysAuthorization = false
    var invokedRequestAlwaysAuthorizationCount = 0
    override func requestAlwaysAuthorization() {
        invokedRequestAlwaysAuthorization = true
        invokedRequestAlwaysAuthorizationCount += 1
    }
    var invokedStartUpdatingLocation = false
    var invokedStartUpdatingLocationCount = 0
    override func startUpdatingLocation() {
        invokedStartUpdatingLocation = true
        invokedStartUpdatingLocationCount += 1
    }
    var invokedStopUpdatingLocation = false
    var invokedStopUpdatingLocationCount = 0
    override func stopUpdatingLocation() {
        invokedStopUpdatingLocation = true
        invokedStopUpdatingLocationCount += 1
    }
    var invokedRequestLocation = false
    var invokedRequestLocationCount = 0
    override func requestLocation() {
        invokedRequestLocation = true
        invokedRequestLocationCount += 1
    }
    var invokedStartUpdatingHeading = false
    var invokedStartUpdatingHeadingCount = 0
    override func startUpdatingHeading() {
        invokedStartUpdatingHeading = true
        invokedStartUpdatingHeadingCount += 1
    }
    var invokedStopUpdatingHeading = false
    var invokedStopUpdatingHeadingCount = 0
    override func stopUpdatingHeading() {
        invokedStopUpdatingHeading = true
        invokedStopUpdatingHeadingCount += 1
    }
    var invokedDismissHeadingCalibrationDisplay = false
    var invokedDismissHeadingCalibrationDisplayCount = 0
    override func dismissHeadingCalibrationDisplay() {
        invokedDismissHeadingCalibrationDisplay = true
        invokedDismissHeadingCalibrationDisplayCount += 1
    }
    var invokedStartMonitoringSignificantLocationChanges = false
    var invokedStartMonitoringSignificantLocationChangesCount = 0
    override func startMonitoringSignificantLocationChanges() {
        invokedStartMonitoringSignificantLocationChanges = true
        invokedStartMonitoringSignificantLocationChangesCount += 1
    }
    var invokedStopMonitoringSignificantLocationChanges = false
    var invokedStopMonitoringSignificantLocationChangesCount = 0
    override func stopMonitoringSignificantLocationChanges() {
        invokedStopMonitoringSignificantLocationChanges = true
        invokedStopMonitoringSignificantLocationChangesCount += 1
    }
    var invokedStopMonitoring = false
    var invokedStopMonitoringCount = 0
    var invokedStopMonitoringParameters: (region: CLRegion, Void)?
    var invokedStopMonitoringParametersList = [(region: CLRegion, Void)]()
    override func stopMonitoring(for region: CLRegion) {
        invokedStopMonitoring = true
        invokedStopMonitoringCount += 1
        invokedStopMonitoringParameters = (region, ())
        invokedStopMonitoringParametersList.append((region, ()))
    }
    var invokedStartMonitoring = false
    var invokedStartMonitoringCount = 0
    var invokedStartMonitoringParameters: (region: CLRegion, Void)?
    var invokedStartMonitoringParametersList = [(region: CLRegion, Void)]()
    override func startMonitoring(for region: CLRegion) {
        invokedStartMonitoring = true
        invokedStartMonitoringCount += 1
        invokedStartMonitoringParameters = (region, ())
        invokedStartMonitoringParametersList.append((region, ()))
    }
    var invokedRequestState = false
    var invokedRequestStateCount = 0
    var invokedRequestStateParameters: (region: CLRegion, Void)?
    var invokedRequestStateParametersList = [(region: CLRegion, Void)]()
    override func requestState(for region: CLRegion) {
        invokedRequestState = true
        invokedRequestStateCount += 1
        invokedRequestStateParameters = (region, ())
        invokedRequestStateParametersList.append((region, ()))
    }
    var invokedStartRangingBeacons = false
    var invokedStartRangingBeaconsCount = 0
    var invokedStartRangingBeaconsParameters: (region: CLBeaconRegion, Void)?
    var invokedStartRangingBeaconsParametersList = [(region: CLBeaconRegion, Void)]()
    override func startRangingBeacons(in region: CLBeaconRegion) {
        invokedStartRangingBeacons = true
        invokedStartRangingBeaconsCount += 1
        invokedStartRangingBeaconsParameters = (region, ())
        invokedStartRangingBeaconsParametersList.append((region, ()))
    }
    var invokedStopRangingBeacons = false
    var invokedStopRangingBeaconsCount = 0
    var invokedStopRangingBeaconsParameters: (region: CLBeaconRegion, Void)?
    var invokedStopRangingBeaconsParametersList = [(region: CLBeaconRegion, Void)]()
    override func stopRangingBeacons(in region: CLBeaconRegion) {
        invokedStopRangingBeacons = true
        invokedStopRangingBeaconsCount += 1
        invokedStopRangingBeaconsParameters = (region, ())
        invokedStopRangingBeaconsParametersList.append((region, ()))
    }
    var invokedAllowDeferredLocationUpdates = false
    var invokedAllowDeferredLocationUpdatesCount = 0
    var invokedAllowDeferredLocationUpdatesParameters: (distance: CLLocationDistance, timeout: TimeInterval)?
    var invokedAllowDeferredLocationUpdatesParametersList = [(distance: CLLocationDistance, timeout: TimeInterval)]()
    override func allowDeferredLocationUpdates(untilTraveled distance: CLLocationDistance,
    timeout: TimeInterval) {
        invokedAllowDeferredLocationUpdates = true
        invokedAllowDeferredLocationUpdatesCount += 1
        invokedAllowDeferredLocationUpdatesParameters = (distance, timeout)
        invokedAllowDeferredLocationUpdatesParametersList.append((distance, timeout))
    }
    var invokedDisallowDeferredLocationUpdates = false
    var invokedDisallowDeferredLocationUpdatesCount = 0
    override func disallowDeferredLocationUpdates() {
        invokedDisallowDeferredLocationUpdates = true
        invokedDisallowDeferredLocationUpdatesCount += 1
    }
}

class CLLocationManagerStub : NSObject {
    class func locationServicesEnabled() -> Bool { return true }
    class func headingAvailable() -> Bool { return true }
    class func significantLocationChangeMonitoringAvailable() -> Bool { return true }
    class func isMonitoringAvailable(for regionClass: AnyClass) -> Bool { return true }
    class func isRangingAvailable() -> Bool { return true }
    class func authorizationStatus() -> CLAuthorizationStatus { return .denied }
    unowned(unsafe) var delegate: CLLocationManagerDelegate?
    var activityType: CLActivityType = .other
    var distanceFilter: CLLocationDistance = 0
    var desiredAccuracy: CLLocationAccuracy = 0
    var pausesLocationUpdatesAutomatically: Bool = true
    var allowsBackgroundLocationUpdates: Bool = true
    var showsBackgroundLocationIndicator: Bool = true
    @NSCopying var location: CLLocation?
    var headingFilter: CLLocationDegrees = 0
    var headingOrientation: CLDeviceOrientation = .unknown
    @NSCopying var heading: CLHeading?
    var maximumRegionMonitoringDistance: CLLocationDistance = 0
    var monitoredRegions: Set<CLRegion> = []
    var rangedRegions: Set<CLRegion> = []
    func requestWhenInUseAuthorization() { }
    func requestAlwaysAuthorization() { }
    func startUpdatingLocation() { }
    func stopUpdatingLocation() { }
    func requestLocation() { }
    func startUpdatingHeading() { }
    func stopUpdatingHeading() { }
    func dismissHeadingCalibrationDisplay() { }
    func startMonitoringSignificantLocationChanges() { }
    func stopMonitoringSignificantLocationChanges() { }
    func stopMonitoring(for region: CLRegion) { }
    func startMonitoring(for region: CLRegion) { }
    func requestState(for region: CLRegion) { }
    func startRangingBeacons(in region: CLBeaconRegion) { }
    func stopRangingBeacons(in region: CLBeaconRegion) { }
    func allowDeferredLocationUpdates(untilTraveled distance: CLLocationDistance,
                                      timeout: TimeInterval) { }
    func disallowDeferredLocationUpdates() { }
    class func deferredLocationUpdatesAvailable() -> Bool { return true }
}