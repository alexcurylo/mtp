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
        log.verbose("prepare for \(segue.name)")
        switch segue.identifier {
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
        log.verbose(segue.name)
    }

    var productUrl: URL? {
        //let posesLink = "https://itunes.apple.com/app/id357099619"
        let mtpLink = "https://itunes.apple.com/app/id1463245184"
        return URL(string: mtpLink)
    }

    @IBAction func aboutTapped(_ sender: UIButton) {
        // storyboard segue showAbout
    }

    @IBAction func shareTapped(_ sender: UIButton) {
        guard let url = productUrl else { return }

        let activityViewController = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil)
        present(activityViewController, animated: true)
    }

    @IBAction func rateTapped(_ sender: UIButton) {
        //SKStoreReviewController.requestReview()
        guard let url = productUrl else { return }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [ URLQueryItem(name: "action", value: "write-review") ]
        guard let writeReviewURL = components?.url else { return }
        app.open(writeReviewURL)
    }

    @IBAction func faqTapped(_ sender: UIButton) {
        // storyboard segue showFAQ
    }

    @IBAction func contactTapped(_ sender: UIButton) {
        guard MFMailComposeViewController.canSendMail() else { return }

        let composeVC = MFMailComposeViewController {
            $0.mailComposeDelegate = self
            $0.setToRecipients([Localized.contactAddress()])
            $0.setSubject(Localized.contactSubject())
        }
        present(composeVC, animated: true, completion: nil)
    }
}

extension SettingsVC: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
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
