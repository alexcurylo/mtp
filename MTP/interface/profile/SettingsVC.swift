// @copyright Trollwerks Inc.

import MessageUI
//import StoreKit

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
        switch segue.identifier {
        case Segues.logout.identifier:
            data.logOut()
        case Segues.showAbout.identifier,
             Segues.showFAQ.identifier,
             Segues.unwindFromSettings.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

private extension SettingsVC {

    @IBAction func unwindToSettings(segue: UIStoryboardSegue) {
    }

    var productUrl: URL? {
        //let posesLink = "https://apps.apple.com/app/id357099619"
        let mtpLink = "https://apps.apple.com/app/id1463245184"
        return URL(string: mtpLink)
    }

    @IBAction func aboutTapped(_ sender: UIButton) {
        // storyboard segue showAbout
    }

    @IBAction func shareTapped(_ sender: UIButton) {
        guard let url = productUrl else { return }

        let share = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil)
        share.popoverPresentationController?.sourceView = sender
        share.popoverPresentationController?.sourceRect = sender.bounds
        present(share, animated: true)
    }

    @IBAction func rateTapped(_ sender: UIButton) {
        guard let url = productUrl else { return }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [ URLQueryItem(name: "action", value: "write-review") ]
        guard let writeReviewURL = components?.url else { return }
        app.launch(url: writeReviewURL)
    }

    @IBAction func faqTapped(_ sender: UIButton) {
        // storyboard segue showFAQ
    }

    @IBAction func contactTapped(_ sender: UIButton) {
        guard MFMailComposeViewController.canSendMail() else { return }

        style.system.styleAppearanceNavBar()
        let composeVC = MFMailComposeViewController {
            $0.mailComposeDelegate = self
            $0.setToRecipients([L.contactAddress()])
            $0.setSubject(L.contactSubject())
        }
        composeVC.navigationBar.set(style: .system)

        present(composeVC, animated: true, completion: nil)
    }

    @IBAction func deleteAccount(segue: UIStoryboardSegue) {
        note.modal(info: L.deletingAccount())

        net.userDeleteAccount { [weak self, note] result in
            switch result {
            case .success:
                note.modal(success: L.success())
                DispatchQueue.main.asyncAfter(deadline: .short) { [weak self] in
                    note.dismissModal()
                    self?.performSegue(withIdentifier: Segues.unwindFromSettings, sender: self)
                }
                return
            case .failure(let error):
                note.modal(failure: error,
                           operation: L.deleteAccount())
            }
        }
    }
}

extension SettingsVC: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        style.standard.styleAppearanceNavBar()
        controller.dismiss(animated: true, completion: nil)
    }
}

extension SettingsVC: Injectable {

    typealias Model = ()

    @discardableResult func inject(model: Model) -> Self {
        return self
    }

    func requireInjections() {
        backgroundView.require()
    }
}

extension MFMailComposeViewController {

    // swiftlint:disable:next override_in_extension
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .system)
    }
}
