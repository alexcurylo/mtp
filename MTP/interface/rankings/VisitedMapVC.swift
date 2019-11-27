// @copyright Trollwerks Inc.

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

        // TODO: Finish resizable shapes view
        mapScroll.isHidden = true

        configure()
   }

    /// :nodoc:
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .visited)
        expose()
    }
}

// MARK: - Private

private extension VisitedMapVC {

    func configure() {
        let visits = data.visited?.locations ?? []
        let mapData = data.worldMap.full(map: visits)
        pdf = PDFDocument(data: mapData)
        mapViewPDF.document = pdf
        mapViewPDF.configure()

        if let page = pdf?.page(at: 0) {
            let pageBounds = page.bounds(for: mapViewPDF.displayBox)
            mapViewPDF.scaleFactor = mapViewPDF.bounds.height / pageBounds.height
            let rect = CGRect(origin: CGPoint(x: 1_300, y: 0),
                              size: CGSize(width: 1, height: 1))
            mapViewPDF.go(to: rect, on: page)
        }

        configureFacebookShare()
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
