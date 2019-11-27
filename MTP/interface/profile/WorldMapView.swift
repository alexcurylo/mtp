// @copyright Trollwerks Inc.

import PDFKit

final class WorldMapViewPDF: PDFView, ServiceProvider {

    func configure() {
        displaysPageBreaks = false
        pageBreakMargins = .zero
        displayBox = .mediaBox
        backgroundColor = .white
        disableShadow()
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
