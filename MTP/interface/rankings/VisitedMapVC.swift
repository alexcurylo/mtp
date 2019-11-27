// @copyright Trollwerks Inc.

import Anchorage
import FacebookShare
import PDFKit

/// Displays large scale visited map
final class VisitedMapVC: UIViewController {

    // verified in requireOutlets
    @IBOutlet private var closeButton: UIBarButtonItem!
    @IBOutlet private var mapViewPDF: WorldMapViewPDF!
    @IBOutlet private var mapScroll: UIScrollView!
    @IBOutlet private var mapView: WorldMapView!

    private var pdf: PDFDocument?

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
        configureScrollView(visits: visits)
        configurePDFView(visits: visits)

        configureFacebookShare()
    }

    func configureScrollView(visits: [Int]) {
        // TODO: Finish resizable shapes view
        mapScroll.isHidden = true

        mapView.sizeAnchors == data.worldMap.fullSize
        mapView.configure()
    }

    func configurePDFView(visits: [Int]) {
        mapViewPDF.isHidden = false

        let mapData = data.worldMap.full(map: visits)
        if let document = PDFDocument(data: mapData) {
            pdf = document
            mapViewPDF.configure(pdf: document)
        }
    }

    func configureFacebookShare() {
        guard let ref = pdf?.documentRef,
              let image = UIImage(pdf: ref) else { return }

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
      mapScroll.zoomScale = minScale
    }

    func updateConstraints(for size: CGSize) {
        /* for centering
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset

        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset

        view.layoutIfNeeded()
         */
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
        mapViewPDF.require()
        mapScroll.require()
        mapView.require()
    }
}

private extension UIImage {

    convenience init?(pdf: CGPDFDocument,
                      pageNumber: Int = 1) {
        guard let page = pdf.page(at: pageNumber) else { return nil }
        let size = page.getBoxRect(.mediaBox).size

        UIGraphicsBeginImageContextWithOptions(size, true, 1)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.saveGState()

        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: size))

        context.translateBy(x: 0.0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.concatenate(page.getDrawingTransform(.mediaBox,
                                                     rect: CGRect(origin: .zero,
                                                                  size: size),
                                                     rotate: 0,
                                                     preserveAspectRatio: true))
        context.drawPDFPage(page)
        context.restoreGState()
        let pdfImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = pdfImage?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
