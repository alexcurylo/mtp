//
//  RealmMapView.swift
//  RealmMapViewExample
//
//  Created by Adam Fish on 9/29/15.
//  Copyright © 2015 Adam Fish. All rights reserved.
//

import MapKit
import RealmSwift
import ABFRealmMapView

public typealias ClusterAnnotationView = ABFClusterAnnotationView
public typealias LocationSafeRealmObject = ABFLocationSafeRealmObject
public typealias LocationFetchedResultsController = ABFLocationFetchedResultsController
public typealias ZoomLevel = ABFZoomLevel
public typealias ResultsLimit = ABFResultsLimit
public typealias Annotation = ABFAnnotation
public typealias AnnotationType = ABFAnnotationType

/**
The RealmMapView class creates an interface object that inherits MKMapView and manages fetching and displaying annotations for a Realm Swift object class that contains coordinate data.
*/
open class RealmMapView: MKMapView {
    // MARK: Properties
    
    /// The configuration for the Realm in which the entity resides
    ///
    /// Default is [RLMRealmConfiguration defaultConfiguration]
    open var realmConfiguration: Realm.Configuration {
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
    open var realm: Realm {
        return try! Realm(configuration: self.realmConfiguration)
    }
    
    /// The internal controller that fetches the Realm objects
    open var fetchedResultsController: LocationFetchedResultsController = {
        let controller = ABFLocationFetchedResultsController()
        
        return controller
    }()
    
    /// The Realm object's name being fetched for the map view
    @IBInspectable open var entityName: String?
    
    /// The key path on fetched Realm objects for the latitude value
    @IBInspectable open var latitudeKeyPath: String?
    
    /// The key path on fetched Realm objects for the longitude value
    @IBInspectable open var longitudeKeyPath: String?
    
    /// The key path on fetched Realm objects for the title of the annotation view
    ///
    /// If nil, then no title will be shown
    @IBInspectable open var titleKeyPath: String?
    
    /// The key path on fetched Realm objects for the subtitle of the annotation view
    ///
    /// If nil, then no subtitle
    @IBInspectable open var subtitleKeyPath: String?
    
    /// Designates if the map view will cluster the annotations
    @IBInspectable open var clusterAnnotations = true
    
    /// Designates if the map view automatically refreshes when the map moves
    @IBInspectable open var autoRefresh = true
    
    /// Designates if the map view will zoom to a region that contains all points
    /// on the first refresh of the map annotations (presumably on viewWillAppear)
    @IBInspectable open var zoomOnFirstRefresh = true
    
    /// If enabled, annotation views will be animated when added to the map.
    ///
    /// Default is YES
    @IBInspectable open var animateAnnotations = true
    
    /// If YES, a standard callout bubble will be shown when the annotation is selected.
    /// The annotation must have a title for the callout to be shown.
    @IBInspectable open var canShowCallout = true
    
    /// Max zoom level of the map view to perform clustering on.
    ///
    /// ABFZoomLevel is inherited from MapKit's Google days:
    /// 0 is the entire 2D Earth
    /// 20 is max zoom
    ///
    /// Default is 20, which means clustering will occur at every zoom level if clusterAnnotations is YES
    open var maxZoomLevelForClustering: ZoomLevel = 20
    
    /// The limit on how many results from Realm will be added to the map.
    ///
    /// This applies whether or not clustering is enabled.
    ///
    /// Default is -1, or unlimited results.
    open var resultsLimit: ResultsLimit {
        set {
            self.fetchedResultsController.resultsLimit = newValue
        }
        get {
            return self.fetchedResultsController.resultsLimit
        }
    }
    
    /// Use this property to filter items found by the map. This predicate will be included, via AND,
    /// along with the generated predicate for the location bounding box.
    open var basePredicate: NSPredicate?
    
    // MARK: Functions
    
    /// Performs a fresh fetch for Realm objects based on the current visible map rect
    open func refreshMapView() {
        objc_sync_enter(self)
        
        self.mapQueue.cancelAllOperations()
        
        let currentRegion = self.region
        
        let rlmConfig = ObjectiveCSupport.convert(object: self.realmConfiguration)
        
        if let rlmRealm = try? RLMRealm(configuration: rlmConfig) {
            
            let fetchRequest = ABFLocationFetchRequest(entityName: self.entityName!, in: rlmRealm, latitudeKeyPath: self.latitudeKeyPath!, longitudeKeyPath: self.longitudeKeyPath!, for: currentRegion)
            fetchRequest.predicate = NSPredicateForCoordinateRegion(currentRegion, self.latitudeKeyPath!, self.longitudeKeyPath!)

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
            
            self.fetchedResultsController.update(fetchRequest, titleKeyPath: self.titleKeyPath, subtitleKeyPath: self.subtitleKeyPath)
            
            let visibleMapRect = self.visibleMapRect
            
            let currentZoomLevel = ABFZoomLevelForVisibleMapRect(visibleMapRect)
            
            let refreshOperation: BlockOperation
            if self.clusterAnnotations && currentZoomLevel <= self.maxZoomLevelForClustering {
                
                let zoomScale = MKZoomScaleForMapView(self)
                
                refreshOperation = BlockOperation { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.fetchedResultsController.performClusteringFetch(forVisibleMapRect: visibleMapRect, zoomScale: zoomScale)
                    
                    let annotations = strongSelf.fetchedResultsController.annotations
                    strongSelf.addAnnotationsToMapView(annotations)
                }
            }
            else {
                refreshOperation = BlockOperation { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.fetchedResultsController.performFetch()
                    
                    let annotations = strongSelf.fetchedResultsController.annotations
                    strongSelf.addAnnotationsToMapView(annotations)
                }
            }
            
            self.mapQueue.addOperation(refreshOperation)
        }
        
        objc_sync_exit(self)
    }
    
    // MARK: Initialization
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        super.delegate = self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        super.delegate = self
    }
    
    // MARK: Setters
    override weak open var delegate: MKMapViewDelegate? {
        get {
            return externalDelegate
        }
        set(newDelegate) {
            self.externalDelegate = newDelegate
        }
    }
    
    // MARK: Private
    fileprivate var internalConfiguration: Realm.Configuration?
    
    fileprivate let ABFAnnotationViewReuseId = "ABFAnnotationViewReuseId"
    
    fileprivate let mapQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        return queue
    }()
    
    weak fileprivate var externalDelegate: MKMapViewDelegate?
    
    fileprivate func addAnnotationsToMapView(_ annotations: Set<ABFAnnotation>) {
        let safeObjects = self.fetchedResultsController.safeObjects
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            let currentAnnotations: NSMutableSet
            if strongSelf.annotations.isEmpty {
                currentAnnotations = NSMutableSet()
            } else {
                currentAnnotations = NSMutableSet(array: strongSelf.annotations)
            }
            
            let newAnnotations = annotations
            
            let toKeep = NSMutableSet(set: currentAnnotations)
            
            toKeep.intersect(newAnnotations as Set<NSObject>)
            
            let toAdd = NSMutableSet(set: newAnnotations)
            
            toAdd.minus(toKeep as Set<NSObject>)
            
            let toRemove = NSMutableSet(set: currentAnnotations)
            
            toRemove.minus(newAnnotations)
                
            if strongSelf.zoomOnFirstRefresh && safeObjects.count > 0 {
                
                strongSelf.zoomOnFirstRefresh = false
                
                let region = strongSelf.coordinateRegion(safeObjects)
                
                strongSelf.setRegion(region, animated: true)
            }
            else {
                if let addAnnotations = toAdd.allObjects as? [MKAnnotation] {
                    
                    if let removeAnnotations = toRemove.allObjects as? [MKAnnotation] {
                        
                        strongSelf.addAnnotations(addAnnotations)
                        strongSelf.removeAnnotations(removeAnnotations)
                    }
                }
            }
        }
    }
    
    fileprivate func addAnimation(_ view: UIView) {
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
    
    fileprivate func coordinateRegion(_ safeObjects: [ABFLocationSafeRealmObject]) -> MKCoordinateRegion {
        var rect = MKMapRect.null
        
        for safeObject in safeObjects {
            let point = MKMapPoint(safeObject.coordinate)
            
            rect = rect.union(MKMapRect(x: point.x, y: point.y, width: 0, height: 0))
        }
        
        var region = MKCoordinateRegion(rect)
        
        region = self.regionThatFits(region)
        
        region.span.latitudeDelta *= 1.3
        region.span.longitudeDelta *= 1.3
        
        return region
    }
}

/**
Delegate proxy that allows the controller to trigger auto refresh and then rebroadcast to main delegate.

:nodoc:
*/
extension RealmMapView: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        self.externalDelegate?.mapView?(mapView, regionWillChangeAnimated: animated)
    }
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        if self.autoRefresh {
            self.refreshMapView()
        }
        
        self.externalDelegate?.mapView?(mapView, regionDidChangeAnimated: animated)
    }
    
    public func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        self.externalDelegate?.mapViewWillStartLoadingMap?(mapView)
    }
    
    public func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        self.externalDelegate?.mapViewDidFinishLoadingMap?(mapView)
    }
    
    public func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        self.externalDelegate?.mapViewDidFailLoadingMap?(mapView, withError: error)
    }
    
    public func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
        self.externalDelegate?.mapViewWillStartRenderingMap?(mapView)
    }
    
    public func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        self.externalDelegate?.mapViewDidFinishRenderingMap?(mapView, fullyRendered: fullyRendered)
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let delegate = self.externalDelegate, let method = delegate.mapView?(mapView, viewFor: annotation) {
            return method
        }
        else if let fetchedAnnotation = annotation as? ABFAnnotation {
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: ABFAnnotationViewReuseId) as! ABFClusterAnnotationView?
            
            if annotationView == nil {
                annotationView = ABFClusterAnnotationView(annotation: fetchedAnnotation, reuseIdentifier: ABFAnnotationViewReuseId)
                
                annotationView!.canShowCallout = self.canShowCallout
            }
            
            annotationView!.count = UInt(fetchedAnnotation.safeObjects.count)
            annotationView!.annotation = fetchedAnnotation
            
            return annotationView!
        }
        
        return nil
    }
    
    public func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        
        if self.animateAnnotations {
            for view in views {
                self.addAnimation(view)
            }
        }
        
        self.externalDelegate?.mapView?(mapView, didAdd: views)
    }
    
    public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        self.externalDelegate?.mapView?(mapView, annotationView: view, calloutAccessoryControlTapped: control)
    }
    
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.externalDelegate?.mapView?(mapView, didSelect: view)
    }
    
    public func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        self.externalDelegate?.mapView?(mapView, didDeselect: view)
    }
    
    public func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
        self.externalDelegate?.mapViewDidStopLocatingUser?(mapView)
    }
    
    public func mapViewDidStopLocatingUser(_ mapView: MKMapView) {
        self.externalDelegate?.mapViewDidStopLocatingUser?(mapView)
    }
    
    public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        self.externalDelegate?.mapView?(mapView, didUpdate: userLocation)
    }
    
    public func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        self.externalDelegate?.mapView?(mapView, didFailToLocateUserWithError: error)
    }
    
    public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        self.externalDelegate?.mapView?(mapView, annotationView: view, didChange: newState, fromOldState: oldState)
    }
    
    public func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        self.externalDelegate?.mapView?(mapView, didChange: mode, animated: animated)
    }
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return (self.externalDelegate?.mapView?(mapView, rendererFor: overlay))!
    }
    
    public func mapView(_ mapView: MKMapView, didAdd renderers: [MKOverlayRenderer]) {
        self.externalDelegate?.mapView?(mapView, didAdd: renderers)
    }
}

/// Extension to ABFLocationSafeRealmObject to convert back to original Object type
extension LocationSafeRealmObject {
    public func toObject<T>(_ type: T.Type) -> T {
        let object = self.rlmObject() as! RLMObjectBase
        return unsafeBitCast(object, to: T.self)
    }
}
