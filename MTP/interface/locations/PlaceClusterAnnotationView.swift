// @copyright Trollwerks Inc.

import MapKit

final class PlaceClusterAnnotationView: MKAnnotationView {

    static let identifier = NSStringFromClass(PlaceClusterAnnotationView.self)

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        collisionMode = .circle
        centerOffset = CGPoint(x: 0, y: -10)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()

        guard let cluster = annotation as? MKClusterAnnotation  else {
            return
        }

        image = cluster.draw()
    }

    override func prepareForReuse() {
        image = nil
        annotation = nil
        super.prepareForReuse()
    }
}

private extension MKClusterAnnotation {

    typealias Slice = (color: UIColor, count: CGFloat)

    enum Layout {
        static let axis = 40
        static let center = CGPoint(x: axis / 2, y: axis / 2)
        static let area = Double(axis * axis)
        static let size = CGSize(width: axis, height: axis)
        static let outer = CGRect(origin: .zero, size: size)
        static let inset = 8
        static let inner = CGRect(x: inset,
                                  y: inset,
                                  width: axis - inset * 2,
                                  height: axis - inset * 2)
        static let fontSize: [CGFloat] = [20, 20, 16, 13, 11, 9]
    }

    func draw() -> UIImage {
        let total = memberAnnotations.count
        let slices = slice()

        let renderer = UIGraphicsImageRenderer(size: Layout.size)
        return renderer.image { _ in
            draw(outer: slices[0].color)
            draw(pie: slices, total: CGFloat(total))
            draw(inner: .white)
            draw(total: total)
        }
    }

    func draw(outer: UIColor) {
        outer.setFill()
        UIBezierPath(ovalIn: Layout.outer).fill()
    }

    func draw(pie: [Slice],
              total: CGFloat) {
        var start = CGFloat(0)
        for slice in pie.dropFirst() {
            let end = draw(slice: slice,
                           start: start,
                           total: total)
            start = end
        }
    }

    func draw(slice: Slice,
              start: CGFloat,
              total: CGFloat) -> CGFloat {
        let angle = (CGFloat.pi * 2 * slice.count) / total
        let end = start + angle

        slice.color.setFill()
        let piePath = UIBezierPath()
        piePath.addArc(
            withCenter: Layout.center,
            radius: Layout.center.x,
            startAngle: start,
            endAngle: end,
            clockwise: true
        )
        piePath.addLine(to: Layout.center)
        piePath.close()
        piePath.fill()

        return end
    }

    func draw(inner: UIColor) {
        inner.setFill()
        UIBezierPath(ovalIn: Layout.inner).fill()
    }

    func draw(total: Int) {
        let text = "\(total)"
        let fontSize = Layout.fontSize[text.count]
        let attributes = NSAttributedString.attributes(
            color: .black,
            font: Avenir.medium.of(size: fontSize)
        )

        let size = text.size(withAttributes: attributes)
        let rect = CGRect(x: Layout.center.x - size.width / 2,
                          y: Layout.center.y - size.height / 2,
                          width: size.width,
                          height: size.height)
        text.draw(in: rect, withAttributes: attributes)
    }

    func slice() -> [Slice] {
        return Checklist.allCases.compactMap { list in
            let places = count(places: list)
            guard places > 0 else { return nil }
            return (list.background, CGFloat(places))
        }
    }

    func count(places: Checklist) -> Int {
        return memberAnnotations.filter { member -> Bool in
            guard let place = member as? PlaceAnnotation else { return false }
            return place.type == places
        }.count
    }
}
