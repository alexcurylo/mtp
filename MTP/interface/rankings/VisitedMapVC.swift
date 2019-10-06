// @copyright Trollwerks Inc.

import PDFKit

/// Displays large scale visited map
final class VisitedMapVC: UIViewController {

    // verified in requireOutlets
    @IBOutlet private var closeButton: UIBarButtonItem!
    @IBOutlet private var mapView: PDFView!

    private var pdf: PDFDocument?

    /// :nodoc:
     override func viewDidLoad() {
         super.viewDidLoad()
         requireOutlets()
         requireInjection()

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
        mapView.displaysPageBreaks = false
        mapView.pageBreakMargins = .zero
        mapView.displayBox = .mediaBox
        mapView.backgroundColor = .white
        mapView.disableShadow()
        mapView.document = pdf

        if let page = pdf?.page(at: 0) {
            let pageBounds = page.bounds(for: mapView.displayBox)
            mapView.scaleFactor = mapView.bounds.height / pageBounds.height
            let rect = CGRect(origin: CGPoint(x: 1_300, y: 0),
                              size: CGSize(width: 1, height: 1))
            mapView.go(to: rect, on: page)
        }
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
        mapView.require()
    }
}

// MARK: - Injectable

extension VisitedMapVC: Injectable {

    /// Injected dependencies
    typealias Model = Data

    /// Handle dependency injection
    /// - Parameter model: Dependencies
    func inject(model: Model) {
        pdf = PDFDocument(data: model)
        mapView?.document = pdf
    }

    /// Enforce dependency injection
    func requireInjection() {
        pdf.require()
    }
}
