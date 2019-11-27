// @copyright Trollwerks Inc.

import PDFKit

final class WorldMapViewPDF: PDFView, ServiceProvider {

    func configure(pdf: PDFDocument) {
        document = pdf
        displaysPageBreaks = false
        pageBreakMargins = .zero
        displayBox = .mediaBox
        backgroundColor = .white
        disableShadow()

        if let page = pdf.page(at: 0) {
            let pageBounds = page.bounds(for: displayBox)
            scaleFactor = bounds.height / pageBounds.height
            let rect = CGRect(origin: CGPoint(x: 1_300, y: 0),
                              size: CGSize(width: 1, height: 1))
            go(to: rect, on: page)
        }
    }
}

final class WorldMapView: UIView, ServiceProvider {

    func configure() {
        backgroundColor = .white
        clipsToBounds = true
    }

    func update(map width: CGFloat,
                visits: [Int]) -> CGFloat {
        layer.sublayers?.removeAll()
        let height = data.worldMap.profile(map: self,
                                           visits: visits,
                                           width: width)
        return height
    }
}
