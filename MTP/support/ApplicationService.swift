// @copyright Trollwerks Inc.

import UIKit

protocol ApplicationService {

    func open(_ url: URL)
}

extension UIApplication: ApplicationService {

    func open(_ url: URL) {
        open(url, options: [:], completionHandler: nil)
    }
}
