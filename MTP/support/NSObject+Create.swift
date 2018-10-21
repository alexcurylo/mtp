// @copyright Trollwerks Inc.

import UIKit

/// Streamline configuration closures/functions
///
/// - Parameter configure: configuration closure/function
/// - Returns: configured object
func create<T>(then configure: ((T) -> Void)) -> T where T: NSObject {
    let object = T()
    configure(object)
    return object
}

func create<T>(then configure: ((T) -> Void)) -> T where T: UICollectionView {
    let object = T(frame: .zero,
                   collectionViewLayout: UICollectionViewFlowLayout())
    configure(object)
    return object
}
