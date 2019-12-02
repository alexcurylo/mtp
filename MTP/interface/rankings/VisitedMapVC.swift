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

    private var zoomed = false

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
        if !zoomed {
            zoomed = true
            zoomToFit()
        }
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
        // TODO location is off
        /*mapScroll.zoom(to: zoomRect(scale: mapScroll.zoomScale * 1.2,
                                    center: sender.location(in: sender.view)),
                        animated: true)*/
        mapScroll.zoom(toPoint: sender.location(in: sender.view),
                       scale: mapScroll.zoomScale * 1.5,
                       animated: true)
    }

    func zoomRect(scale: CGFloat, center: CGPoint) -> CGRect {
        let mapBounds = mapView.bounds
        var zoomRect = CGRect.zero
        zoomRect.size.height = mapBounds.height / scale
        zoomRect.size.width = mapBounds.width / scale
        let newCenter = mapView.convert(center, to: mapScroll)
        zoomRect.origin.x = newCenter.x - (zoomRect.width / 2)
        zoomRect.origin.y = newCenter.y - (zoomRect.height / 2)
        return zoomRect
    }

    @objc func doubleTapped(_ sender: UITapGestureRecognizer) {
        zoomToFit()
    }

    func zoomToFit() {
        // TODO doesn't zoom right unless called from didAppear
        let mapBounds = mapView.bounds
        let scale = mapScroll.bounds.height / mapBounds.height
        //mapScroll.zoomScale = scale
        /*mapScroll.zoom(to: zoomRect(scale: scale,
                                    center: mapBounds.center),
                        animated: true)*/
        mapScroll.zoom(toPoint: mapBounds.center,
                       scale: scale,
                       animated: true)
        print("zoomToFit: \(scale), \(mapScroll.zoomScale)")
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

private extension UIScrollView {

    // https://gist.github.com/TimOliver/71be0a8048af4bd86ede
    func zoom(toPoint zoomPoint: CGPoint,
              scale: CGFloat,
              animated: Bool) {
        var scale = CGFloat.minimum(scale, maximumZoomScale)
        scale = CGFloat.maximum(scale, self.minimumZoomScale)

        var translatedZoomPoint: CGPoint = .zero
        translatedZoomPoint.x = zoomPoint.x + contentOffset.x
        translatedZoomPoint.y = zoomPoint.y + contentOffset.y

        let zoomFactor = 1.0 / zoomScale

        translatedZoomPoint.x *= zoomFactor
        translatedZoomPoint.y *= zoomFactor

        var destinationRect: CGRect = .zero
        destinationRect.size.width = frame.width / scale
        destinationRect.size.height = frame.height / scale
        destinationRect.origin.x = translatedZoomPoint.x - destinationRect.width * 0.5
        destinationRect.origin.y = translatedZoomPoint.y - destinationRect.height * 0.5

        if animated {
            UIView.animate(
                withDuration: 0.55,
                delay: 0.0,
                usingSpringWithDamping: 1.0,
                initialSpringVelocity: 0.6,
                options: [.allowUserInteraction],
                animations: { [weak self] in
                    self?.zoom(to: destinationRect, animated: false)
                },
                completion: { [weak self] _ in
                    if let self = self,
                       let delegate = self.delegate,
                       let view = delegate.viewForZooming?(in: self) {
                        delegate.scrollViewDidEndZooming?(self,
                                                          with: view,
                                                          atScale: scale)
                    }
                }
            )
        } else {
            zoom(to: destinationRect, animated: false)
        }
    }
}
