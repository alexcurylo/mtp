// @copyright Trollwerks Inc.

import UIKit

/// Display user details
final class ProfileAboutVC: UITableViewController, UserInjectable, ServiceProvider {

    private typealias Segues = R.segue.profileAboutVC

    @IBOutlet private var rankingLabel: UILabel?
    @IBOutlet private var mapImageView: UIImageView?
    @IBOutlet private var visitedButton: GradientButton?
    @IBOutlet private var remainingButton: GradientButton?
    @IBOutlet private var bioTextView: UITextView?

    @IBOutlet private var airportLabel: UILabel?

    @IBOutlet private var linksStack: UIStackView?

    private var user: User?
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
        requireInjections()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        guard let inset = mapImageView?.superview?.frame.origin.x else { return }
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
    }

    /// Instrument and inject navigation
    ///
    /// - Parameters:
    ///   - segue: Navigation action
    ///   - sender: Action originator
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.showUserCounts.identifier:
            if let profile = Segues.showUserCounts(segue: segue)?.destination,
                let countsModel = countsModel {
                profile.inject(model: countsModel)
            }
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

// MARK: - UITableViewDelegate

extension ProfileAboutVC {

    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView,
                            estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Private

private extension ProfileAboutVC {

    func update() {
        guard let user = user else { return }

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
                self?.refreshUser()
            }
            visitedObserver = data.observer(of: .visited) { [weak self] _ in
                self?.refreshVisits()
            }
        } else {
            userIdObserver = data.observer(of: .userId) { [weak self] _ in
                guard let self = self,
                      let userId = self.user?.userId,
                      let new = self.data.get(user: userId) else { return }

                self.user = new
                self.update()
            }
        }
    }

    func refreshUser() {
        if let new = data.user {
            user = User(from: new)
            update()
        }
    }

    func refreshVisits() {
        visits = data.visited?.locations ?? []
        update()
    }

    func update(map width: CGFloat) {
        guard width > 0 else { return }

        let image = data.worldMap.draw(visits: visits,
                                       width: width)
        mapWidth = image?.size.width ?? 0
        mapImageView?.image = image
    }

    func update(ranking user: User) {
        let list = Checklist.locations

        let rank = list.rank(of: user)
        let ranking = L.ranking(rank.grouped)
        rankingLabel?.text = ranking

        let status = list.visitStatus(of: user)
        let visited = L.visitedCount(status.visited)
        visitedButton?.setTitle(visited, for: .normal)
        let remaining = L.remainingCount(status.remaining)
        remainingButton?.setTitle(remaining, for: .normal)

        if let attributed = user.bio.html2Attributed(
            font: Avenir.medium.of(size: 18),
            color: .darkGray
            )?.trimmed {
            bioTextView?.attributedText = attributed
        } else {
            bioTextView?.text = user.bio
        }
    }

    func update(airport user: User) {
        guard let label = airportLabel else { return }

        if user.airport.isEmpty {
            label.text = L.unknown()
            label.font = Avenir.bookOblique.of(size: 12)
            label.alpha = 0.7
        } else {
            label.text = user.airport.uppercased()
            label.font = Avenir.book.of(size: 16)
            label.alpha = 1
        }
    }

    func update(links user: User) {
        guard let stack = linksStack else { return }

        let headerViewCount = 2
        let views = stack.arrangedSubviews
        (headerViewCount..<views.count).forEach { index in
            stack.removeArrangedSubview(views[index])
            views[index].removeFromSuperview()
        }

        for (linkText, linkUrl) in zip(user.linkTexts, user.linkUrls) {
            guard !linkText.isEmpty else { continue }

            let label = UILabel {
                $0.text = linkText.uppercased()
                $0.font = Avenir.heavy.of(size: 10)
                $0.alpha = 0.7
            }
            stack.addArrangedSubview(label)

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
            stack.addArrangedSubview(button)
        }

        if stack.arrangedSubviews.count <= headerViewCount {
            let label = UILabel {
                $0.text = L.emptyState()
                $0.font = Avenir.bookOblique.of(size: 12)
                $0.alpha = 0.7
            }
            stack.addArrangedSubview(label)
        }
    }

    @IBAction func linkTapped(_ sender: GradientButton) {
        if let link = sender.accessibilityIdentifier,
           let url = URL(string: link) {
            app.launch(url: url)
        }
    }

    @IBAction func visitedTapped(_ sender: GradientButton) {
        guard let user = user else { return }

        countsModel = (.locations, user, .visited)
        performSegue(withIdentifier: Segues.showUserCounts, sender: self)
    }

    @IBAction func remainingTapped(_ sender: GradientButton) {
        guard let user = user else { return }

        countsModel = (.locations, user, .remaining)
        performSegue(withIdentifier: Segues.showUserCounts, sender: self)
    }
}

extension ProfileAboutVC: Injectable {

    /// Injected dependencies
    typealias Model = User

    /// Handle dependency injection
    ///
    /// - Parameter model: Dependencies
    /// - Returns: Chainable self
    @discardableResult func inject(model: Model) -> Self {
        user = model
        isSelf = model.isSelf
        observe()

        if isSelf {
            refreshVisits()
        } else {
            fetch(id: model.userId)
       }

        return self
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

    /// Enforce dependency injection
    func requireInjections() {
        user.require()

        rankingLabel.require()
        mapImageView.require()
        visitedButton.require()
        remainingButton.require()
        bioTextView.require()
        airportLabel.require()
        linksStack.require()
    }
}
