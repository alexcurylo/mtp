// @copyright Trollwerks Inc.

import Anchorage
import MapKit
import RealmMapView

/// Common accessors for single and cluster views
protocol MappingAnnotationView {

    /// Annotation displayed
    var annotation: MKAnnotation? { get }
    /// Convenience annotation type caster
    var mapped: MappablesAnnotation? { get }

    /// Convenience accessor for uniqueness
    var isSingle: Bool { get }
    /// Convenience accessor for multiplicity
    var isMultiple: Bool { get }

    /// Convenience accessor for unique place
    var mappable: Mappable? { get }
    /// Convenience accessor for place(s) list
    var mappables: [Mappable] { get }
}

extension MappingAnnotationView {

    /// Convenience annotation type caster
    var mapped: MappablesAnnotation? {
        return annotation as? MappablesAnnotation
    }
    /// Convenience accessor for uniqueness
    var isSingle: Bool {
        return mapped?.isSingle ?? false
    }
    /// Convenience accessor for multiplicity
    var isMultiple: Bool {
        return mapped?.isMultiple ?? false
    }

    /// Convenience accessor for unique place
    var mappable: Mappable? {
        return mapped?.mappable
    }
    /// Convenience accessor for place(s) list
    var mappables: [Mappable] {
        return mapped?.mappables ?? []
    }
}

/// Annotation view for multiple places
final class MappablesAnnotationView: MKAnnotationView, MappingAnnotationView, ServiceProvider {

    private static var identifier = typeName

    /// Register view type
    ///
    /// - Parameter view: Map view
    static func register(view: MKMapView) {
        view.register(self, forAnnotationViewWithReuseIdentifier: identifier)
    }

    /// Factory method for view
    ///
    /// - Parameters:
    ///   - map: Map view
    ///   - annotation: Place
    /// - Returns: MappablesAnnotationView
    static func view(on map: MKMapView,
                     for annotation: MappablesAnnotation) -> MKAnnotationView {
        let view = map.dequeueReusableAnnotationView(
            withIdentifier: MappablesAnnotationView.identifier,
            for: annotation
        )

        view.annotation = annotation
        view.canShowCallout = false

        return view
    }

    /// Construction by injection
    ///
    /// - Parameters:
    ///   - annotation: Place
    ///   - reuseIdentifier: Identifier
    override init(annotation: MKAnnotation?,
                  reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        canShowCallout = false
        collisionMode = .circle
        centerOffset = CGPoint(x: 0, y: -10)
    }

    /// Decoding intializer
    ///
    /// - Parameter aDecoder: Decoder
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Prepare for display
    override func prepareForDisplay() {
        super.prepareForDisplay()

        image = mapped?.draw()
    }

    /// Empty display
    override func prepareForReuse() {
        super.prepareForReuse()

        image = nil
        annotation = nil
    }
}

// MARK: - Drawing

private extension MappablesAnnotation {

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
        let total = count
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
        var visits = CGFloat(0)
        let lists: [Slice] = Checklist.allCases.compactMap { list in
            let (visited, unvisited) = count(checklist: list)
            visits += CGFloat(visited)
            guard unvisited > 0 else { return nil }
            return (list.marker, CGFloat(unvisited))
        }
        if visits > 0 {
            let visited: [Slice] = [(.visited, visits)]
            return visited + lists
        } else {
            return lists
        }
    }

    func count(checklist: Checklist) -> (Int, Int) {
        var counts: (visited: Int, unvisited: Int) = (0, 0)
        mappables.filter { $0.checklist == checklist }.forEach {
            if $0.isVisited {
                counts.visited += 1
            } else {
                counts.unvisited += 1
            }
        }
        return counts
    }
}
