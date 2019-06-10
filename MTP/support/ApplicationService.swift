// @copyright Trollwerks Inc.

import UIKit

protocol ApplicationService {

    func launch(url: URL)
}

extension UIApplication: ApplicationService {

    func launch(url: URL) {
        open(url, options: [:], completionHandler: nil)
    }
}
