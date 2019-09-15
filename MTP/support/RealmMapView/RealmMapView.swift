// @copyright Trollwerks Inc.

// original: RealmMapViewExample

// swiftlint:disable file_length

import MapKit
import RealmSwift

typealias MappablesAnnotation = ABFAnnotation
private typealias AnnotationType = ABFAnnotationType
private typealias ClusterAnnotationView = ABFClusterAnnotationView
private typealias LocationFetchedResultsController = ABFLocationFetchedResultsController
private typealias LocationSafeRealmObject = ABFLocationSafeRealmObject
private typealias ResultsLimit = ABFResultsLimit
private typealias ZoomLevel = ABFZoomLevel

/// Creates an interface object that inherits MKMapView and manages fetching and displaying
/// annotations for a Realm Swift object class that contains coordinate data.
class RealmMapView: MKMapView {
    // MARK: Properties

    /// The configuration for the Realm in which the entity resides
    ///
    /// Default is [RLMRealmConfiguration defaultConfiguration]
    var realmConfiguration: Realm.Configuration {
        set {
            self.internalConfiguration = newValue
        }
        get {
            if let configuration = self.internalConfiguration {
                return configuration
            }

            return Realm.Configuration.defaultConfiguration
        }
    }

    /// The Realm in which the given entity resides in
    var realm: Realm {
        // swiftlint:disable:next force_try
        return try! Realm(configuration: self.realmConfiguration)
    }

    /// The internal controller that fetches the Realm objects
    fileprivate var fetchedResultsController: LocationFetchedResultsController = {
        let controller = LocationFetchedResultsController()

        return controller
    }()

    /// The Realm object's name being fetched for the map view
    @IBInspectable var entityName: String?

    /// The key path on fetched Realm objects for the latitude value
    @IBInspectable var latitudeKeyPath: String?

    /// The key path on fetched Realm objects for the longitude value
    @IBInspectable var longitudeKeyPath: String?

    /// The key path on fetched Realm objects for the title of the annotation view
    ///
    /// If nil, then no title will be shown
    @IBInspectable var titleKeyPath: String?

    /// The key path on fetched Realm objects for the subtitle of the annotation view
    ///
    /// If nil, then no subtitle
    @IBInspectable var subtitleKeyPath: String?

    /// Designates if the map view will cluster the annotations
    @IBInspectable var clusterAnnotations: Bool = true

    /// Designates if the map view automatically refreshes when the map moves
    @IBInspectable var autoRefresh: Bool = true

    /// Designates if the map view will zoom to a region that contains all points
    /// on the first refresh of the map annotations (presumably on viewWillAppear)
    @IBInspectable var zoomOnFirstRefresh: Bool = true

    /// If enabled, annotation views will be animated when added to the map.
    ///
    /// Default is YES
    @IBInspectable var animateAnnotations: Bool = true

    /// If YES, a standard callout bubble will be shown when the annotation is selected.
    /// The annotation must have a title for the callout to be shown.
    @IBInspectable var canShowCallout: Bool = true

    /// Max zoom level of the map view to perform clustering on.
    ///
    /// ZoomLevel is inherited from MapKit's Google days:
    /// 0 is the entire 2D Earth
    /// 20 is max zoom
    ///
    /// Default is 20, which means clustering will occur at every zoom level if clusterAnnotations is YES
    fileprivate var maxZoomLevelForClustering: ZoomLevel = 20

    /// The limit on how many results from Realm will be added to the map.
    ///
    /// This applies whether or not clustering is enabled.
    ///
    /// Default is -1, or unlimited results.
    fileprivate var resultsLimit: ResultsLimit {
        set {
            self.fetchedResultsController.resultsLimit = newValue
        }
        get {
            return self.fetchedResultsController.resultsLimit
        }
    }

    /// Use this property to filter items found by the map. This predicate will be included, via AND,
    /// along with the generated predicate for the location bounding box.
    var basePredicate: NSPredicate?

    /// Provide annotation update state notification entry points
    var isChangingRegion = false {
        didSet { isUpdatingAnnotations = isRefreshingMapCount > 0 || isChangingRegion }
    }
    var isRefreshingMapCount = 0 {
        didSet { isUpdatingAnnotations = isRefreshingMapCount > 0 || isChangingRegion }
    }
    var isUpdatingAnnotations = false {
        didSet {
            switch (oldValue, isUpdatingAnnotations) {
            case (false, true):
                willUpdateAnnotations()
            case (true, false):
                didUpdateAnnotations()
            default:
                break
            }
        }
    }

    func willUpdateAnnotations() {
        // override entry point
    }
    func didUpdateAnnotations() {
        // override entry point
    }

    /// Expose serial work queue for scheduling
    var serialWorkQueue: OperationQueue { return mapQueue }

    // MARK: Functions

    /// Performs a fresh fetch for Realm objects based on the current visible map rect
    // swiftlint:disable:next function_body_length
    func refreshMapView(refreshRegion: MKCoordinateRegion? = nil,
                        refreshMapRect: MKMapRect? = nil) {
        objc_sync_enter(self)
        isRefreshingMapCount += 1

        let refreshingRegion = refreshRegion ?? region
        let refreshingMapRect = refreshMapRect ?? visibleMapRect
        let rlmConfig = ObjectiveCSupport.convert(object: realmConfiguration)

        do {
            let rlmRealm = try RLMRealm(configuration: rlmConfig)
            let fetchRequest = ABFLocationFetchRequest(
                // swiftlint:disable:next force_unwrapping
                entityName: entityName!,
                in: rlmRealm,
                // swiftlint:disable:next force_unwrapping
                latitudeKeyPath: latitudeKeyPath!,
                // swiftlint:disable:next force_unwrapping
                longitudeKeyPath: longitudeKeyPath!,
                for: refreshingRegion
            )
            fetchRequest.predicate = NSPredicateForCoordinateRegion(
                refreshingRegion,
                // swiftlint:disable:next force_unwrapping
                latitudeKeyPath!,
                // swiftlint:disable:next force_unwrapping
                longitudeKeyPath!
            )

            var predicates = [NSPredicate]()
            if let basePred = self.basePredicate {
                predicates.append(basePred)
            }
            if let fetchPred = fetchRequest.predicate {
                predicates.append(fetchPred)
            }
            if !predicates.isEmpty {
                let compPred = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
                fetchRequest.predicate = compPred
            }

            self.fetchedResultsController.update(fetchRequest,
                                                 titleKeyPath: self.titleKeyPath,
                                                 subtitleKeyPath: self.subtitleKeyPath)

            let currentZoomLevel = ABFZoomLevelForVisibleMapRect(refreshingMapRect)

            let refreshOperation: BlockOperation
            if self.clusterAnnotations && currentZoomLevel <= self.maxZoomLevelForClustering {

                let zoomScale = MKZoomScaleForMapView(self)

                refreshOperation = BlockOperation { [weak self, refreshingMapRect] in
                    guard let self = self else { return }
                    self.fetchedResultsController.performClusteringFetch(forVisibleMapRect: refreshingMapRect,
                                                                         zoomScale: zoomScale)

                    let annotations = self.fetchedResultsController.annotations
                    self.addAnnotationsToMapView(annotations)
                }
            } else {
                refreshOperation = BlockOperation { [weak self] in
                    guard let self = self else { return }
                    self.fetchedResultsController.performFetch()

                    let annotations = self.fetchedResultsController.annotations
                    self.addAnnotationsToMapView(annotations)
                }
            }

            self.mapQueue.addOperation(refreshOperation)
        } catch {
            isRefreshingMapCount -= 1
            #if DEBUG
            print("configuration error: \(error)")
            #endif
        }

        objc_sync_exit(self)
    }

    // MARK: Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        super.delegate = self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        super.delegate = self
    }

    // MARK: Setters
    override weak var delegate: MKMapViewDelegate? {
        get {
            return externalDelegate
        }
        set(newDelegate) {
            self.externalDelegate = newDelegate
        }
    }

    // MARK: Private
    private var internalConfiguration: Realm.Configuration?

    private let ABFAnnotationViewReuseId = "ABFAnnotationViewReuseId"

    private let mapQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "RealmMapView"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInteractive

        return queue
    }()

    private weak var externalDelegate: MKMapViewDelegate?

    private func addAnnotationsToMapView(_ annotations: Set<MappablesAnnotation>) {
        let safeObjects = self.fetchedResultsController.safeObjects
        // swiftlint:disable:next closure_body_length
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }

            let currentAnnotations: NSMutableSet
            if self.annotations.isEmpty {
                currentAnnotations = NSMutableSet()
            } else {
                currentAnnotations = NSMutableSet(array: self.annotations)
            }

            let newAnnotations = annotations

            let toKeep = NSMutableSet(set: currentAnnotations)

            toKeep.intersect(newAnnotations as Set<NSObject>)

            let toAdd = NSMutableSet(set: newAnnotations)

            toAdd.minus(toKeep as Set<NSObject>)

            let toRemove = NSMutableSet(set: currentAnnotations)

            toRemove.minus(newAnnotations)

            if self.zoomOnFirstRefresh && !safeObjects.isEmpty {

                self.zoomOnFirstRefresh = false

                let region = self.coordinateRegion(safeObjects)

                self.setRegion(region, animated: true)
            } else {
                if let addAnnotations = toAdd.allObjects as? [MKAnnotation] {

                    if let removeAnnotations = toRemove.allObjects as? [MKAnnotation] {

                        self.addAnnotations(addAnnotations)
                        self.removeAnnotations(removeAnnotations)
                    }
                }
            }
            self.isRefreshingMapCount -= 1
        }
    }

    private func addAnimation(_ view: UIView) {
        view.transform = CGAffineTransform.identity.scaledBy(x: 0.05, y: 0.05)

        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 1,
            options: UIView.AnimationOptions(),
            animations: {
                view.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
            },
            completion: nil
        )
    }

    private func coordinateRegion(_ safeObjects: [LocationSafeRealmObject]) -> MKCoordinateRegion {
        var rect = MKMapRect.null

        for safeObject in safeObjects {
            let point = MKMapPoint(safeObject.coordinate)

            rect = rect.union(MKMapRect(x: point.x, y: point.y, width: 0, height: 0))
        }

        let outset = -0.3
        let outsetRect = rect.insetBy(dx: rect.width * outset,
                                      dy: rect.height * outset)
        let outsetRegion = MKCoordinateRegion(outsetRect)
        let fittedRegion = regionThatFits(outsetRegion)

        return fittedRegion
    }
}

/**
Delegate proxy that allows the controller to trigger auto refresh and then rebroadcast to main delegate.
*/
extension RealmMapView: MKMapViewDelegate {

    public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        isChangingRegion = true

        self.externalDelegate?.mapView?(mapView, regionWillChangeAnimated: animated)
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if self.autoRefresh {
            self.refreshMapView()
        }
        isChangingRegion = false

        self.externalDelegate?.mapView?(mapView, regionDidChangeAnimated: animated)
    }

    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        self.externalDelegate?.mapViewWillStartLoadingMap?(mapView)
    }

    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        self.externalDelegate?.mapViewDidFinishLoadingMap?(mapView)
    }

    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        self.externalDelegate?.mapViewDidFailLoadingMap?(mapView, withError: error)
    }

    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
        self.externalDelegate?.mapViewWillStartRenderingMap?(mapView)
    }

    func mapViewDidFinishRenderingMap(_ mapView: MKMapView,
                                      fullyRendered: Bool) {
        self.externalDelegate?.mapViewDidFinishRenderingMap?(mapView, fullyRendered: fullyRendered)
    }

    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let delegate = self.externalDelegate,
           let method = delegate.mapView?(mapView, viewFor: annotation) {
            return method
        } else if let fetchedAnnotation = annotation as? MappablesAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationView(
                withIdentifier: ABFAnnotationViewReuseId
            ) as! ClusterAnnotationView?
            // swiftlint:disable:previous force_cast

            if annotationView == nil {
                annotationView = ClusterAnnotationView(
                    annotation: fetchedAnnotation, reuseIdentifier: ABFAnnotationViewReuseId
                )

                // swiftlint:disable:next force_unwrapping
                annotationView!.canShowCallout = self.canShowCallout
            }

            // swiftlint:disable:next force_unwrapping
            annotationView!.count = UInt(fetchedAnnotation.safeObjects.count)
            // swiftlint:disable:next force_unwrapping
            annotationView!.annotation = fetchedAnnotation

            // swiftlint:disable:next force_unwrapping
            return annotationView!
        }

        return nil
    }

    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {

        if self.animateAnnotations {
            for view in views {
                self.addAnimation(view)
            }
        }

        self.externalDelegate?.mapView?(mapView, didAdd: views)
    }

    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        self.externalDelegate?.mapView?(mapView, annotationView: view, calloutAccessoryControlTapped: control)
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.externalDelegate?.mapView?(mapView, didSelect: view)
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        self.externalDelegate?.mapView?(mapView, didDeselect: view)
    }

    func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
        self.externalDelegate?.mapViewWillStartLocatingUser?(mapView)
    }

    func mapViewDidStopLocatingUser(_ mapView: MKMapView) {
        self.externalDelegate?.mapViewDidStopLocatingUser?(mapView)
    }

    func mapView(_ mapView: MKMapView,
                 didUpdate userLocation: MKUserLocation) {
        self.externalDelegate?.mapView?(mapView, didUpdate: userLocation)
    }

    func mapView(_ mapView: MKMapView,
                 didFailToLocateUserWithError error: Error) {
        self.externalDelegate?.mapView?(mapView, didFailToLocateUserWithError: error)
    }

    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 didChange newState: MKAnnotationView.DragState,
                 fromOldState oldState: MKAnnotationView.DragState) {
        self.externalDelegate?.mapView?(mapView, annotationView: view, didChange: newState, fromOldState: oldState)
    }

    func mapView(_ mapView: MKMapView,
                 didChange mode: MKUserTrackingMode,
                 animated: Bool) {
        self.externalDelegate?.mapView?(mapView, didChange: mode, animated: animated)
    }

    func mapView(_ mapView: MKMapView,
                 rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // swiftlint:disable:next force_unwrapping
        return (self.externalDelegate?.mapView?(mapView, rendererFor: overlay))!
    }

    func mapView(_ mapView: MKMapView,
                 didAdd renderers: [MKOverlayRenderer]) {
        self.externalDelegate?.mapView?(mapView, didAdd: renderers)
    }

    func mapView(_ mapView: MKMapView,
                 clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
        // Setting clusteringIdentifier with RealmMapView is a usage error
        // swiftlint:disable:next force_unwrapping
        return (self.externalDelegate?.mapView?(mapView, clusterAnnotationForMemberAnnotations: memberAnnotations))!
    }
}

/// Extension to LocationSafeRealmObject to convert back to original Object type
extension LocationSafeRealmObject {
    func toObject<T>(_ type: T.Type) -> T {
        // swiftlint:disable:next force_cast
        let object = self.rlmObject() as! RLMObjectBase
        return unsafeBitCast(object, to: T.self)
    }
}
