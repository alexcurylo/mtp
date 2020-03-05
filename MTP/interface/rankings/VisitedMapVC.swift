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

    private var initialized = false

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
        if !initialized {
            initialized = true
            updateMinZoomScale(for: displaySize)
            zoom(toFit: false)
        }
    }

    /// :nodoc:
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        mapScroll.flashScrollIndicators()
    }

    /// :nodoc:
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        updateMinZoomScale(for: displaySize)
    }
}

// MARK: - UIScrollViewDelegate

extension VisitedMapVC: UIScrollViewDelegate {

    /// :nodoc:
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { mapView }

    /// :nodoc:
    func scrollViewDidEndZooming(_ scrollView: UIScrollView,
                                 with view: UIView?,
                                 atScale scale: CGFloat) {
        mapView.updateLayers(for: scale)
    }

    /// :nodoc:
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // pinning minimum zoom to bounds for now
        // updateConstraints(for: displaySize)
    }
}

// MARK: - Private

private extension VisitedMapVC {

    var displaySize: CGSize {
        view.safeAreaLayoutGuide.layoutFrame.size
    }

    func configure() {
        let visits = data.visited?.locations ?? []
        let size = data.worldMap.fullSize
        mapView.sizeAnchors == size
        mapView.configure()
        mapView.update(map: size.width,
                       visits: visits)

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
        let minScale = max(widthScale, heightScale)
        mapScroll.minimumZoomScale = minScale
    }

    @objc func tapped(_ sender: UITapGestureRecognizer) {
        let tapped = sender.location(in: sender.view)
        mapScroll.zoom(toPoint: tapped,
                       scale: mapScroll.zoomScale * 2,
                       animated: true)
    }

    @objc func doubleTapped(_ sender: UITapGestureRecognizer) {
        mapScroll.zoomScale = 1
        zoom(toFit: true)
    }

    func zoom(toFit animate: Bool) {
        let mapBounds = mapView.bounds
        let scale = mapScroll.bounds.height / mapBounds.height
        let center = mapBounds.center
        mapScroll.zoom(toPoint: center,
                       scale: scale,
                       animated: animate)
    }

    func updateConstraints(for size: CGSize) {
        let mapFrame = mapView.frame
        let yOffset = max(0, (size.height - mapFrame.height) / 2)
        mapViewTopConstraint.constant = yOffset
        mapViewBottomConstraint.constant = yOffset

        let xOffset = max(0, (size.width - mapFrame.width) / 2)
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

    func zoom(toPoint zoomPoint: CGPoint,
              scale: CGFloat,
              animated: Bool) {
        var scale = CGFloat.minimum(scale, maximumZoomScale)
        scale = CGFloat.maximum(scale, self.minimumZoomScale)

        let zoomFactor = 1.0 / zoomScale
        let target = CGPoint(x: zoomPoint.x * zoomFactor,
                             y: zoomPoint.y * zoomFactor)

        var targetRect: CGRect = .zero
        targetRect.size.width = frame.width / scale
        targetRect.size.height = frame.height / scale
        targetRect.origin.x = target.x - targetRect.width * 0.5
        targetRect.origin.y = target.y - targetRect.height * 0.5

        if animated {
            UIView.animate(
                withDuration: 0.55,
                delay: 0.0,
                usingSpringWithDamping: 1.0,
                initialSpringVelocity: 0.6,
                options: [.allowUserInteraction],
                animations: { [weak self] in
                    self?.zoom(to: targetRect, animated: false)
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
            zoom(to: targetRect, animated: false)
            if let delegate = self.delegate,
               let view = delegate.viewForZooming?(in: self) {
                delegate.scrollViewDidEndZooming?(self,
                                                  with: view,
                                                  atScale: scale)
            }
        }
    }
}
