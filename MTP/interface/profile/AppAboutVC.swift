// @copyright Trollwerks Inc.

import UIKit

final class AppAboutVC: UIViewController, ServiceProvider {

    private typealias Segues = R.segue.appAboutVC

    @IBOutlet private var aboutTextView: UITopLoadingTextView?

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        aboutTextView?.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .standard)
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        log.verbose("prepare for \(segue.name)")
        switch segue.identifier {
        case Segues.unwindFromAbout.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

// MARK: - Injectable

extension AppAboutVC: Injectable {

    typealias Model = ()

    @discardableResult func inject(model: Model) -> Self {
        return self
    }

    func requireInjections() {
        aboutTextView.require()
    }
}
