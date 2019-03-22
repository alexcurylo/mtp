// @copyright Trollwerks Inc.

import UIKit

final class UserProfileVC: UIViewController, ServiceProvider {

    enum Tab {
        case visited
        case remaining
    }

    private typealias Segues = R.segue.userProfileVC

    @IBOutlet private var alertHolder: UIView?
    @IBOutlet private var bottomY: NSLayoutConstraint?
    @IBOutlet private var centerY: NSLayoutConstraint?
    @IBOutlet private var messageLabel: UILabel?

    private var user: User?
    private var selected: Tab?
    private var errorMessage: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        requireInjected()

        if let message = errorMessage, !message.isEmpty {
            messageLabel?.text = message
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        presentingViewController?.hide(navBar: animated)
        presentingViewController?.hide(toolBar: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        log.verbose("prepare for \(segue.name)")
        switch segue.identifier {
        case Segues.dismissUserProfile.identifier:
            presentingViewController?.show(navBar: true)
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

extension UserProfileVC: Injectable {

    typealias Model = (user: User, tab: Tab)

    func inject(model: Model) {
        user = model.user
        selected = model.tab
    }

    func requireInjected() {
        user.require()
        selected.require()

        alertHolder.require()
        bottomY.require()
        centerY.require()
    }
}
