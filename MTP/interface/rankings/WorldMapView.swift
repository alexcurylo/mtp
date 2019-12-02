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

    private static var titles: [Int: String] = [:]

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
                // swiftlint:disable:previous function_body_length
                visits: [Int],
                label: Bool = false) {
        shapeLayer.sublayers?.removeAll()
        data.worldMap.render(layer: shapeLayer,
                             visits: visits,
                             width: width)
        guard label else { return }

        let size = CGSize(width: 300, height: 100)
        let fontSize = CGFloat(16)

        labelLayer.sublayers?.removeAll()
        // swiftlint:disable:next closure_body_length
        shapeLayer.sublayers?.forEach {
            guard let shape = $0 as? CAShapeLayer,
                  let locid = shape.style?[WorldMap.locid] as? Int,
                  let box = shape.path?.boundingBox else { return }

            // deal with edge wrapping and clipping
            let center: CGPoint
            switch locid {
            case 84: // Alaska
                center = CGPoint(x: box.minX + 200,
                                 y: box.minY + 50)
            case 743: // Chukotka Autonomous Okrug
                center = CGPoint(x: box.maxX - 85,
                                 y: box.minY + 50)
            case 17: // Fiji Islands
                center = CGPoint(x: box.maxX - 5,
                                 y: box.minY + 15)
            case 754: // Chubut Province
                center = CGPoint(x: box.minX + 30,
                                 y: box.maxY - 15)
            case 750: // Buenos Aires (City)
                center = CGPoint(x: box.minX,
                                 y: box.maxY )
                shape.fillColor = UIColor.purple.cgColor
            case 751: // Buenos Aires Province
                center = CGPoint(x: box.minX + 30,
                                 y: box.maxY - 30)
                shape.fillColor = UIColor.orange.cgColor
            case 911: // Southern Queen Maud Land
                 center = CGPoint(x: box.center.x,
                                  y: box.center.y - 50)
            case 347: // Ross Dependency (to S. Pole)
                center = CGPoint(x: box.minX + 130,
                                 y: box.center.y - 10)
            case 333, // Australian Antarctic Territory (to S. Pole)
                 341: // Adelie Land (to S. Pole)
                center = CGPoint(x: box.center.x,
                                 y: box.center.y - 20)
            //case 229, // Greenland
                 //346: // Queen Maud Land (not to South Pole)
            default:
                center = box.center
            }

            let text = CenteringLayer()
            text.frame = CGRect(x: center.x - (size.width / 2),
                                y: center.y - (size.height / 2),
                                width: size.width,
                                height: size.height)
            text.needsDisplayOnBoundsChange = true
            text.rasterizationScale = UIScreen.main.scale
            text.contentsScale = UIScreen.main.scale
            text.alignmentMode = CATextLayerAlignmentMode.center
            text.fontSize = fontSize
            text.font = Avenir.medium.of(size: fontSize)
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
        return Self.titles[locid] ?? {
            guard let title = data.get(location: locid)?.placeTitle else { return "" }
            Self.titles[locid] = title
            return title
        }()
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
