// @copyright Trollwerks Inc.

import UIKit

/// Static text display of application information
final class AppAboutVC: UIViewController {

    private typealias Segues = R.segue.appAboutVC

    // verified in requireOutlets
    @IBOutlet private var aboutTextView: TopLoadingTextView!

    /// :nodoc:
    override func viewDidLoad() {
        super.viewDidLoad()

        requireOutlets()
        configure()
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

        report(screen: "App About")
    }
}

// MARK: - Private

private extension AppAboutVC {

    func configure() {
        aboutTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)

        let start = aboutTextView.beginningOfDocument
        aboutTextView.selectedTextRange = aboutTextView.textRange(from: start, to: start)
        aboutTextView.insertText("\(app.version)\n\n")
    }
}

// MARK: - Exposing

extension AppAboutVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        let items = navigationItem.leftBarButtonItems
        UIAppAbout.close.expose(item: items?.first)
    }
}

// MARK: - InterfaceBuildable

extension AppAboutVC: InterfaceBuildable {

    /// Injection enforcement for viewDidLoad
    func requireOutlets() {
        aboutTextView.require()
    }
}
