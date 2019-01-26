// @copyright Trollwerks Inc.

import Anchorage
import MapKit
import UIKit

final class LocationsVC: UIViewController {

    @IBOutlet private var mapView: MKMapView?
    @IBOutlet private var searchBar: UISearchBar?

    let locationManager = CLLocationManager()
    private var centering = true

    override func viewDidLoad() {
        super.viewDidLoad()

        start(tracking: .dontAsk)
        setupCompass()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .map)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        start(tracking: .ask)
        zoomAndCenter()
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        log.verbose("prepare for \(segue.name)")
        switch segue.identifier {
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
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
        compass.topAnchor == map.safeAreaLayoutGuide.topAnchor + Layout.margin
        compass.rightAnchor == map.rightAnchor - Layout.margin
        map.showsCompass = false
    }

    func zoomAndCenter() {
        guard !centering,
              let here = locationManager.location?.coordinate else { return }

        centering = true
        let viewRegion = MKCoordinateRegion(center: here,
                                            latitudinalMeters: 200,
                                            longitudinalMeters: 200)
        DispatchQueue.main.async { [weak self] in
            self?.mapView?.setRegion(viewRegion, animated: true)
        }
    }
}

extension LocationsVC: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, regionWillChangeAnimated: Bool) {
        log.verbose(#function)
    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated: Bool) {
        log.verbose(#function)
        centering = false
    }

    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        log.verbose(#function)
    }
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        log.verbose(#function)
    }
    func mapViewDidFailLoadingMap(_ mapView: MKMapView) {
        log.verbose(#function)
    }

    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
        log.verbose(#function)
    }
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        log.verbose(#function)
    }

    func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
        log.verbose(#function)
    }
    func mapViewDidStopLocatingUser(_ mapView: MKMapView) {
        log.verbose(#function)
    }
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        log.verbose(#function)
        zoomAndCenter()
   }
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        log.verbose(#function)
    }
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        log.verbose(#function)
    }

    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        log.verbose(#function)
        return nil
    }
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        log.verbose(#function)
    }
    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        log.verbose(#function)
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        log.verbose(#function)
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        log.verbose(#function)
    }
    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 didChange newState: MKAnnotationView.DragState,
                 fromOldState oldState: MKAnnotationView.DragState) {
        log.verbose(#function)
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        log.verbose(#function)
        return MKOverlayRenderer(overlay: overlay)
    }
    func mapView(_ mapView: MKMapView, didAdd renderers: [MKOverlayRenderer]) {
        log.verbose(#function)
    }

    func mapView(_ mapView: MKMapView,
                 clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
        log.verbose(#function)
        return MKClusterAnnotation(memberAnnotations: memberAnnotations)
    }
}

extension LocationsVC: LocationTracker {

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        log.verbose(#function)
        zoomAndCenter()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        log.verbose(#function)
    }
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        log.verbose(#function)
        return true
    }

    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        log.verbose(#function)
    }
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        log.verbose(#function)
    }

    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        log.verbose(#function)
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        log.verbose(#function)
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        log.verbose(#function)
    }
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        log.verbose(#function)
    }
    func locationManager(_ manager: CLLocationManager,
                         rangingBeaconsDidFailFor region: CLBeaconRegion,
                         withError error: Error) {
        log.verbose(#function)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        log.verbose(#function)
    }

    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        log.verbose(#function)
    }
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        log.verbose(#function)
    }

    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        log.verbose(#function)
        DispatchQueue.main.async { [weak self] in
            self?.start(tracking: .ask)
            self?.zoomAndCenter()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        log.verbose(#function)
    }

    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        log.verbose(#function)
    }
}
