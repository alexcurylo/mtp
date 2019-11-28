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
                       visits: visits)

        configureFacebookShare()
    }

    func configureFacebookShare() {
        guard let image = UIImage(layer: mapView.shapeLayer,
                                  size: data.worldMap.fullSize) else { return }

        //image.save(desktop: "WorldMap")

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
        // this is always coming out 1
        mapScroll.minimumZoomScale = minScale

        // TODO Zoom to fit at startup, handle double taps 
        print("zoomScale: \(mapScroll.zoomScale)")
        print("minimumZoomScale: \(mapScroll.minimumZoomScale)")
        print("maximumZoomScale: \(mapScroll.maximumZoomScale)")
        print("contentSize: \(mapScroll.contentSize)")
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

private extension UIImage {

    convenience init?(layer: CALayer,
                      size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, true, 1)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: size))

        layer.render(in: context)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }

    #if targetEnvironment(simulator)
    func save(desktop name: String) {
         do {
             let destination = try "\(name).png".desktopURL()
             let png = try unwrap(pngData())
             try png.write(to: destination)
         } catch {
             ConsoleLoggingService().error("saving image: \(error)")
         }
     }
    #endif
}
