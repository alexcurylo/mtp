// @copyright Trollwerks Inc.

import MessageUI

/// Miscellaneous account and app operations
final class SettingsVC: UITableViewController, ServiceProvider {

    private typealias Segues = R.segue.settingsVC

    @IBOutlet private var backgroundView: UIView?

    @IBOutlet private var aboutButton: UIButton?
    @IBOutlet private var faqButton: UIButton?

    private var reportMessage = ""

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        tableView.backgroundView = backgroundView
    }

    /// Prepare for reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .standard)
        expose()
    }

    /// Actions to take after reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !reportMessage.isEmpty {
            email(title: L.reportSubject(), body: reportMessage)
            reportMessage = ""
        }
    }

    /// Instrument and inject navigation
    ///
    /// - Parameters:
    ///   - segue: Navigation action
    ///   - sender: Action originator
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.logout.identifier {
            data.logOut()
        }
    }
}

// MARK: - Private

private extension SettingsVC {

    @IBAction func unwindToSettings(segue: UIStoryboardSegue) { }

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
        email(title: L.contactSubject())
    }

    func report(body: String? = nil) {
        email(title: L.reportSubject(), body: body)
    }

    func email(title: String,
               body: String? = nil) {
        guard MFMailComposeViewController.canSendMail() else {
            note.message(error: L.setupEmail())
            return
        }

        style.styler.system.styleAppearanceNavBar()
        let composeVC = MFMailComposeViewController {
            $0.mailComposeDelegate = self
            $0.setToRecipients([L.contactAddress()])
            $0.setSubject(title)
            if let body = body {
                $0.setMessageBody(body, isHTML: false)
            }
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
                    self?.performSegue(withIdentifier: Segues.logout, sender: self)
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

    /// Handle mail compose result
    ///
    /// - Parameters:
    ///   - controller: Mail editor
    ///   - result: Result
    ///   - error: Error if any
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        style.styler.standard.styleAppearanceNavBar()
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Exposing

extension SettingsVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        let items = navigationItem.leftBarButtonItems
        UISettings.close.expose(item: items?.first)

        UISettings.about.expose(item: aboutButton)
        UISettings.faq.expose(item: faqButton)
    }
}

// MARK: - Injectable

extension SettingsVC: Injectable {

    /// Injected dependencies
    typealias Model = String

    /// Handle dependency injection
    ///
    /// - Parameter model: Dependencies
    /// - Returns: Chainable self
    @discardableResult func inject(model: Model) -> Self {
        reportMessage = model
        return self
    }

    /// Enforce dependency injection
    func requireInjections() {
        aboutButton.require()
        backgroundView.require()
        faqButton.require()
    }
}

extension MFMailComposeViewController {

    /// Fix nav bar for mail controller
    ///
    /// - Parameter animated: Animated appearance?
    override open func viewWillAppear(_ animated: Bool) {
        // swiftlint:disable:previous override_in_extension
        super.viewWillAppear(animated)

        show(navBar: animated, style: .system)
    }
}
