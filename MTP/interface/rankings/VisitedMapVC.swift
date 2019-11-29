// @copyright Trollwerks Inc.

import Anchorage
import FacebookShare

/// Displays large scale visited map
final class VisitedMapVC: UIViewController {

    // verified in requireOutlets
    @IBOutlet private var closeButton: UIBarButtonItem!
    @IBOutlet private var mapScroll: UIScrollView!
    @IBOutlet private var mapViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private var mapViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private var mapViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private var mapViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var mapView: WorldMapView!

    /// :nodoc:
     override func viewDidLoad() {
        super.viewDidLoad()
        requireOutlets()

        configure()
   }

    /// :nodoc:
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .visited)
        expose()
        zoomToFit()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapScroll.flashScrollIndicators()
    }

    /// :nodoc:
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateMinZoomScale(for: view.bounds.size)
    }
}

// MARK: - UIScrollViewDelegate

extension VisitedMapVC: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        mapView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        mapView.updateLayers(for: view.bounds.size)
        updateConstraints(for: view.bounds.size)
    }
}

// MARK: - Private

private extension VisitedMapVC {

    func configure() {
        let visits = data.visited?.locations ?? []
        let size = data.worldMap.fullSize
        mapView.sizeAnchors == size
        mapView.configure()
        mapView.update(map: size.width,
                       visits: visits,
                       label: true)

        let doubleTap = UITapGestureRecognizer(target: self,
                                               action: #selector(doubleTapped))
        doubleTap.numberOfTapsRequired = 2
        mapScroll.addGestureRecognizer(doubleTap)
        let singletap = UITapGestureRecognizer(target: self,
                                               action: #selector(tapped))
        mapScroll.addGestureRecognizer(singletap)
        singletap.require(toFail: doubleTap)

        configureFacebookShare()
    }

    func configureFacebookShare() {
        guard let image = mapView.image(size: data.worldMap.fullSize) else { return }

        let photo = SharePhoto(image: image, userGenerated: true)
        let content = SharePhotoContent()
        content.photos = [photo]

        let button = FBShareButton()
        button.shareContent = content

        let item = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItems = [item]
    }

    func updateMinZoomScale(for size: CGSize) {
        let widthScale = size.width / mapView.bounds.width
        let heightScale = size.height / mapView.bounds.height
        let minScale = min(widthScale, heightScale)
        mapScroll.minimumZoomScale = minScale

        // handle double taps
        print("zoomScale: \(mapScroll.zoomScale)")
        print("minimumZoomScale: \(mapScroll.minimumZoomScale)")
        print("maximumZoomScale: \(mapScroll.maximumZoomScale)")
        print("contentSize: \(mapScroll.contentSize)")
    }

    @objc func tapped(_ sender: UITapGestureRecognizer) {
        mapScroll.zoom(to: zoomRect(scale: mapScroll.zoomScale + 1,
                                    center: sender.location(in: sender.view)),
                        animated: true)
    }

    func zoomRect(scale: CGFloat, center: CGPoint) -> CGRect {
        // TODO zooms way out instead of centering on tap
        var zoomRect = CGRect.zero
        zoomRect.size.height = mapView.frame.size.height / scale
        zoomRect.size.width = mapView.frame.size.width / scale
        let newCenter = mapView.convert(center, to: mapScroll)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }

    @objc func doubleTapped(_ sender: UITapGestureRecognizer) {
        zoomToFit()
    }

    func zoomToFit() {
        // TODO Zoom to fit at startup, double-tap
    }

    func updateConstraints(for size: CGSize) {
        let yOffset = max(0, (size.height - mapView.frame.height) / 2)
        mapViewTopConstraint.constant = yOffset
        mapViewBottomConstraint.constant = yOffset

        let xOffset = max(0, (size.width - mapView.frame.width) / 2)
        mapViewLeadingConstraint.constant = xOffset
        mapViewTrailingConstraint.constant = xOffset

        view.layoutIfNeeded()
    }
}

// MARK: - Exposing

extension VisitedMapVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        UIUserProfile.close.expose(item: closeButton)
    }
}

// MARK: - InterfaceBuildable

extension VisitedMapVC: InterfaceBuildable {

    /// Injection enforcement for viewDidLoad
    func requireOutlets() {
        closeButton.require()
        mapScroll.require()
        mapViewTopConstraint.require()
        mapViewLeadingConstraint.require()
        mapViewTrailingConstraint.require()
        mapViewBottomConstraint.require()
        mapView.require()
    }
}
