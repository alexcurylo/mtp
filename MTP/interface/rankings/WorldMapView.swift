// @copyright Trollwerks Inc.

/// World map in CAShapeLayers
final class WorldMapView: UIView, ServiceProvider {

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
        layer.sublayers?.removeAll()
        data.worldMap.render(map: self,
                             visits: visits,
                             width: width)
    }
}
