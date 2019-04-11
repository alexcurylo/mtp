// @copyright Trollwerks Inc.

import UIKit

final class SettingsVC: UITableViewController, ServiceProvider {

    private typealias Segues = R.segue.settingsVC

    @IBOutlet private var backgroundView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        tableView.backgroundView = backgroundView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .standard)
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
        case Segues.showFAQ.identifier,
             Segues.unwindFromSettings.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

private extension SettingsVC {

    @IBAction func unwindToSettings(segue: UIStoryboardSegue) {
        log.verbose(segue.name)
    }

    @IBAction func aboutTapped(_ sender: UIButton) {
        log.todo("aboutTapped")
    }

    @IBAction func shareTapped(_ sender: UIButton) {
        log.todo("shareTapped")
    }

    @IBAction func faqTapped(_ sender: UIButton) {
    }

    @IBAction func membersTapped(_ sender: UIButton) {
        log.todo("membersTapped")
    }

    @IBAction func contactTapped(_ sender: UIButton) {
        log.todo("contactTapped")
    }
}

extension SettingsVC: Injectable {

    typealias Model = ()

    @discardableResult func inject(model: Model) -> SettingsVC {
        return self
    }

    func requireInjections() {
        backgroundView.require()
    }
}
