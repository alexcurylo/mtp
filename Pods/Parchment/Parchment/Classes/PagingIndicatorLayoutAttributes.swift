import UIKit

open class PagingIndicatorLayoutAttributes: UICollectionViewLayoutAttributes {

  open var backgroundColor: UIColor?
  
  func configure(_ options: PagingOptions) {
    if case let .visible(height, index, _, _) = options.indicatorOptions {
      backgroundColor = options.indicatorColor
      frame.size.height = height
      frame.origin.y = options.menuHeight - height
      zIndex = index
    }
  }
  
  func update(from: PagingIndicatorMetric, to: PagingIndicatorMetric, progress: CGFloat) {
    frame.origin.x = tween(from: from.x, to: to.x, progress: progress)
    frame.size.width = tween(from: from.width, to: to.width, progress: progress)
  }
  
  func update(to metric: PagingIndicatorMetric) {
    frame.origin.x = metric.x
    frame.size.width = metric.width
  }
  
}
