// @copyright Trollwerks Inc.

import UIKit

/// Miscellaneous account and app operations
final class SettingsVC: UITableViewController {

    private typealias Segues = R.segue.settingsVC

    // verified in requireOutlets
    @IBOutlet private var backgroundView: UIView!
    @IBOutlet private var aboutButton: UIButton!
    @IBOutlet private var shareButton: UIButton!
    @IBOutlet private var reviewButton: UIButton!
    @IBOutlet private var faqButton: UIButton!
    @IBOutlet private var contactButton: UIButton!
    @IBOutlet private var networkButton: UIButton!
    @IBOutlet private var logoutButton: UIButton!
    @IBOutlet private var deleteButton: UIButton!

    private var route: Route?

    /// :nodoc:
    override func viewDidLoad() {
        super.viewDidLoad()
        requireOutlets()
        requireInjection()

        tableView.backgroundView = backgroundView
    }

    /// :nodoc:
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .standard)
        expose()
    }

    /// :nodoc:
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        report(screen: "Settings")

        switch route {
        case .network?:
            performSegue(withIdentifier: Segues.showNetwork, sender: self)
        case .reportContent(let message)? where !message.isEmpty:
            report(body: message)
        default:
            break
        }
        route = nil
    }

    /// :nodoc:
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

    @IBAction func reviewTapped(_ sender: UIButton) {
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
        sendFeedback(topic: Topic.feature)
    }

    func report(body: String) {
        sendFeedback(topic: Topic.report, body: body)
    }

    func sendFeedback(topic: TopicProtocol,
                      body: String = "") {
        if net.isConnected {
            composeFeedback(topic: topic, body: body)
        } else {
            let question = L.continueOffline(L.contactMTP())
            note.ask(question: question) { [weak self] answer in
                if answer {
                    self?.composeFeedback(topic: topic, body: body)
                }
            }
        }
    }

    func composeFeedback(topic: TopicProtocol,
                         body: String) {
        let configuration = FeedbackConfiguration(
            selected: topic,
            body: body
        )
        let controller = FeedbackViewController(configuration: configuration)
        navigationController?.pushViewController(controller,
                                                 animated: true)
    }

    @IBAction func networkTapped(_ sender: UIButton) {
        // storyboard segue showNetwork
    }

    @IBAction func logoutTapped(_ sender: UIButton) {
        // storyboard segue logout
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

// MARK: - Exposing

extension SettingsVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        let items = navigationItem.leftBarButtonItems
        UISettings.close.expose(item: items?.first)

        UISettings.about.expose(item: aboutButton)
        UISettings.contact.expose(item: contactButton)
        UISettings.delete.expose(item: deleteButton)
        UISettings.faq.expose(item: faqButton)
        UISettings.logout.expose(item: logoutButton)
        UISettings.menu.expose(item: tableView)
        UISettings.network.expose(item: networkButton)
        UISettings.review.expose(item: reviewButton)
        UISettings.share.expose(item: shareButton)
    }
}

// MARK: - InterfaceBuildable

extension SettingsVC: InterfaceBuildable {

    /// Injection enforcement for viewDidLoad
    func requireOutlets() {
        aboutButton.require()
        backgroundView.require()
        contactButton.require()
        deleteButton.require()
        faqButton.require()
        logoutButton.require()
        networkButton.require()
        reviewButton.require()
        shareButton.require()
    }
}

// MARK: - Injectable

extension SettingsVC: Injectable {

    /// Injected dependencies
    typealias Model = Route

    /// Handle dependency injection
    ///
    /// - Parameter model: Dependencies
    func inject(model: Model) {
        route = model
    }

    /// Enforce dependency injection
    func requireInjection() { }
}
