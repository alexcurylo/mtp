// @copyright Trollwerks Inc.

/// World map in CAShapeLayers
final class WorldMapView: UIView, ServiceProvider {

    private lazy var shapeLayer: CALayer = {
        let shapes = CALayer()
        shapes.backgroundColor = UIColor.white.cgColor
        shapes.frame = CGRect(origin: .zero,
                              size: data.worldMap.fullSize)
        layer.addSublayer(shapes)
        return shapes
    }()

    private lazy var labelLayer: CALayer = {
        let labels = CALayer()
        labels.frame = shapeLayer.frame
        layer.addSublayer(labels)
        return labels
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

    func image(size: CGSize) -> UIImage? {
        let map = UIImage(layer: shapeLayer, size: size)
        //map?.save(desktop: "WorldMap-\(size.width)")
        return map
    }

    /// Rendering
    /// - Parameters:
    ///   - width: Width
    ///   - visits: Places visited
    func update(map width: CGFloat,
                visits: [Int],
                label: Bool = false) {
        shapeLayer.sublayers?.removeAll()
        data.worldMap.render(layer: shapeLayer,
                             visits: visits,
                             width: width)
        guard label else { return }

        labelLayer.sublayers?.removeAll()
        shapeLayer.sublayers?.forEach {
            guard let shape = $0 as? CAShapeLayer,
                  let locid = shape.style?[WorldMap.locid] as? Int,
                  let box = shape.path?.boundingBox else { return }

            let text = CenteringLayer()
            text.frame = CGRect(x: box.center.x - 150,
                                y: box.center.y - 50,
                                width: 300,
                                height: 100)
            text.needsDisplayOnBoundsChange = true
            text.rasterizationScale = UIScreen.main.scale
            text.contentsScale = UIScreen.main.scale
            text.alignmentMode = CATextLayerAlignmentMode.center
            text.fontSize = 16
            text.font = Avenir.medium.of(size: 16)
            text.foregroundColor = UIColor.black.cgColor
            text.isWrapped = true
            text.truncationMode = CATextLayerTruncationMode.end
            text.string = title(locid: locid)
            labelLayer.addSublayer(text)
        }
    }

    /// Updating
    /// - Parameter size: Zoomed size
    func updateLayers(for size: CGSize) {
        // TODO change font size and line width on zoom?
        print("view.bounds.size: \(size)")
    }
}

private extension WorldMapView {

    func title(locid: Int) -> String {
        return ""
        // TODO Get location title
    }
}

private class CenteringLayer: CATextLayer {

    override func draw(in ctx: CGContext) {
        let yDiff: CGFloat
        let height: CGFloat
        if let attributedString = string as? NSAttributedString {
            let bounding = attributedString.boundingRect(
                with: CGSize(width: bounds.width,
                             height: CGFloat.greatestFiniteMagnitude),
                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                context: nil
            )
            height = bounding.size.height
        } else if let plainString = string as? String {
            let attributes = [NSAttributedString.Key.font: Avenir.medium.of(size: 16)]
            let size = plainString.size(withAttributes: attributes)
            height = size.height
        } else {
            return
        }
        yDiff = (bounds.height - height) / 2

        ctx.saveGState()
        ctx.translateBy(x: 0.0, y: yDiff)
        super.draw(in: ctx)
        ctx.restoreGState()
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
