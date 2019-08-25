// @copyright Trollwerks Inc.

import UIKit

/// Display user details
final class ProfileAboutVC: UITableViewController, UserInjectable {

    private typealias Segues = R.segue.profileAboutVC

    // verified in requireOutlets
    @IBOutlet private var rankingLabel: UILabel!
    @IBOutlet private var mapImageView: UIImageView!
    @IBOutlet private var visitedButton: GradientButton!
    @IBOutlet private var remainingButton: GradientButton!
    @IBOutlet private var bioTextView: UITextView!
    @IBOutlet private var airportLabel: UILabel!
    @IBOutlet private var linksStack: UIStackView!

    // verified in requireInjection
    private var user: User!
    // swiftlint:disable:previous implicitly_unwrapped_optional

    private var isSelf: Bool = false
    private var visits: [Int] = []

    private var locationsObserver: Observer?
    private var userObserver: Observer?
    private var visitedObserver: Observer?
    private var userIdObserver: Observer?

    private var countsModel: UserCountsVC.Model?

    private var mapWidth: CGFloat = 0

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireOutlets()
        requireInjection()
    }

    /// Refresh map on layout
   override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        guard let inset = mapImageView.superview?.frame.origin.x else { return }
        let width = tableView.bounds.width - (inset * 2)
        if mapWidth != width {
            update(map: width)
         }
    }

    /// Prepare for reveal
    ///
    /// - Parameter animated: Whether animating
   override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        update()
        expose()
    }

    /// Actions to take after reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        report(screen: "Profile About")
    }

    /// Instrument and inject navigation
    ///
    /// - Parameters:
    ///   - segue: Navigation action
    ///   - sender: Action originator
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let profile = Segues.showUserCounts(segue: segue)?
                              .destination,
           let countsModel = countsModel {
            profile.inject(model: countsModel)
        }
    }
}

// MARK: - UITableViewDelegate

extension ProfileAboutVC {

    /// Provide row height
    ///
    /// - Parameters:
    ///   - tableView: Table
    ///   - indexPath: Index path
    /// - Returns: Height
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    /// Provide estimated row height
    ///
    /// - Parameters:
    ///   - tableView: Table
    ///   - indexPath: Index path
    /// - Returns: Height
    override func tableView(_ tableView: UITableView,
                            estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Private

private extension ProfileAboutVC {

    func update() {
        tableView.update {
            update(map: mapWidth)
            update(ranking: user)
            update(airport: user)
            update(links: user)
        }
    }

    func observe() {
        guard locationsObserver == nil else { return }

        locationsObserver = Checklist.locations.observer { [weak self] _ in
            self?.update()
        }
        if isSelf {
            userObserver = data.observer(of: .user) { [weak self] _ in
                self?.reloadUser()
            }
            visitedObserver = data.observer(of: .visited) { [weak self] _ in
                self?.reloadVisits()
            }
        } else {
            userIdObserver = data.observer(of: .userId) { [weak self] _ in
                guard let self = self,
                      let new = self.data.get(user: self.user.userId) else { return }

                self.user = new
                self.update()
            }
        }
    }

    func reloadUser() {
        if let new = data.user {
            user = User(from: new)
            update()
        }
    }

    func reloadVisits() {
        visits = data.visited?.locations ?? []
        update()
    }

    func update(map width: CGFloat) {
        guard width > 0 else { return }

        let image = data.worldMap.draw(visits: visits,
                                       width: width)
        mapWidth = image?.size.width ?? 0
        mapImageView.image = image
    }

    func update(ranking user: User) {
        let list = Checklist.locations

        let rank = list.rank(of: user)
        let ranking = L.ranking(rank.grouped)
        rankingLabel.text = ranking

        let status = list.visitStatus(of: user)
        let visited = L.visitedCount(status.visited)
        visitedButton.setTitle(visited, for: .normal)
        let remaining = L.remainingCount(status.remaining)
        remainingButton.setTitle(remaining, for: .normal)

        if let attributed = user.bio.html2Attributed(
            font: Avenir.medium.of(size: 18),
            color: .darkGray
            )?.trimmed {
            bioTextView.attributedText = attributed
        } else {
            bioTextView.text = user.bio
        }
    }

    func update(airport user: User) {
        if user.airport.isEmpty {
            airportLabel.text = L.unknown()
            airportLabel.font = Avenir.bookOblique.of(size: 12)
            airportLabel.alpha = 0.7
        } else {
            airportLabel.text = user.airport.uppercased()
            airportLabel.font = Avenir.book.of(size: 16)
            airportLabel.alpha = 1
        }
    }

    func update(links user: User) {
        let headerViewCount = 2
        let views = linksStack.arrangedSubviews
        (headerViewCount..<views.count).forEach { index in
            linksStack.removeArrangedSubview(views[index])
            views[index].removeFromSuperview()
        }

        for (linkText, linkUrl) in zip(user.linkTexts, user.linkUrls) {
            guard !linkText.isEmpty else { continue }

            let label = UILabel {
                $0.text = linkText.uppercased()
                $0.font = Avenir.heavy.of(size: 10)
                $0.alpha = 0.7
            }
            linksStack.addArrangedSubview(label)

            let title = linkUrl
                .replacingOccurrences(of: "http://", with: "")
                .replacingOccurrences(of: "https://", with: "")
            let link: String
            if linkUrl.hasPrefix("http") {
                link = linkUrl
            } else {
                link = "http://" + linkUrl
            }
            let button = GradientButton.urlButton(title: title, link: link)
            button.addTarget(self, action: #selector(linkTapped), for: .touchUpInside)
            linksStack.addArrangedSubview(button)
        }

        if linksStack.arrangedSubviews.count <= headerViewCount {
            let label = UILabel {
                $0.text = L.emptyState()
                $0.font = Avenir.bookOblique.of(size: 12)
                $0.alpha = 0.7
            }
            linksStack.addArrangedSubview(label)
        }
    }

    @IBAction func linkTapped(_ sender: GradientButton) {
        if let link = sender.accessibilityIdentifier,
           let url = URL(string: link) {
            app.launch(url: url)
        }
    }

    @IBAction func visitedTapped(_ sender: GradientButton) {
        countsModel = (.locations, user, .visited)
        performSegue(withIdentifier: Segues.showUserCounts, sender: self)
    }

    @IBAction func remainingTapped(_ sender: GradientButton) {
        countsModel = (.locations, user, .remaining)
        performSegue(withIdentifier: Segues.showUserCounts, sender: self)
    }

    func fetch(id: Int) {
        net.loadUser(id: id) { _ in }

        if let scorecard = data.get(scorecard: .locations, user: id) {
            visits = Array(scorecard.visits)
        } else {
            visits = []
            net.loadScorecard(list: .locations,
                              user: id) { [weak self] _ in
                                guard let self = self else { return }
                                if let scorecard = self.data.get(scorecard: .locations, user: id) {
                                    self.visits = Array(scorecard.visits)
                                    self.update(map: self.mapWidth)
                                }
            }
        }
    }
}

// MARK: - Exposing

extension ProfileAboutVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        UIProfileAbout.remaining.expose(item: remainingButton)
        UIProfileAbout.visited.expose(item: visitedButton)
    }
}

// MARK: - InterfaceBuildable

extension ProfileAboutVC: InterfaceBuildable {

    /// Injection enforcement for viewDidLoad
    func requireOutlets() {
        airportLabel.require()
        bioTextView.require()
        linksStack.require()
        mapImageView.require()
        rankingLabel.require()
        remainingButton.require()
        visitedButton.require()
    }
}

// MARK: - Injectable

extension ProfileAboutVC: Injectable {

    /// Injected dependencies
    typealias Model = User

    /// Handle dependency injection
    ///
    /// - Parameter model: Dependencies
    func inject(model: Model) {
        user = model
        isSelf = model.isSelf
        observe()

        if isSelf {
            reloadVisits()
        } else {
            fetch(id: model.userId)
       }
    }

    /// Enforce dependency injection
    func requireInjection() {
        user.require()
    }
}
