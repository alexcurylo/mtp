// @copyright Trollwerks Inc.

/// World map in CAShapeLayers
final class WorldMapView: UIView, ServiceProvider {

    lazy var shapeLayer: CALayer = {
        let shapes = CALayer()
        shapes.backgroundColor = UIColor.white.cgColor
        shapes.frame = CGRect(origin: .zero,
                              size: data.worldMap.fullSize)
        layer.addSublayer(shapes)
        return shapes
    }()

    /// Configuration
    func configure() {
        backgroundColor = .white
        clipsToBounds = true
    }

    /// Render height for width
    /// - Parameter width: width
    func height(for width: CGFloat) -> CGFloat {
        return data.worldMap.height(for: width)
    }

    /// Rendering
    /// - Parameters:
    ///   - width: Width
    ///   - visits: Places visited
    func update(map width: CGFloat,
                visits: [Int]) {
        shapeLayer.sublayers?.removeAll()
        data.worldMap.render(layer: shapeLayer,
                             visits: visits,
                             width: width)
    }
}
