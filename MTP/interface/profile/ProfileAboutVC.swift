// @copyright Trollwerks Inc.

import UIKit

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        update()
        observe()
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

        update(map: mapWidth)
        update(ranking: user)
        update(airport: user)
        update(links: user)
    }

    func observe() {
        guard locationsObserver == nil else { return }

        locationsObserver = Checklist.locations.observer { [weak self] _ in
            self?.update()
        }
        if isSelf {
            userObserver = data.observer(of: .user) { [weak self] _ in
                self?.update()
            }
            visitedObserver = data.observer(of: .visited) { [weak self] _ in
                self?.update()
            }
        } else {
            userIdObserver = data.observer(of: .userId) { [weak self] _ in
                self?.update()
            }
        }
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
        let ranking = Localized.ranking(rank.grouped)
        rankingLabel?.text = ranking

        let status = list.status(of: user)
        let visited = Localized.visitedCount(status.visited)
        visitedButton?.setTitle(visited, for: .normal)
        let remaining = Localized.remainingCount(status.remaining)
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
        airportLabel?.text = user.airport
    }

    func update(links user: User) {
        guard let views = linksStack?.arrangedSubviews else { return }
        (2..<views.count).forEach { index in
            views[index].removeFromSuperview()
        }

        for link in zip(user.linkTexts, user.linkUrls) {
            guard !link.0.isEmpty else { continue }

            let label = UILabel {
                $0.text = link.0.uppercased()
                $0.font = Avenir.heavy.of(size: 10)
                $0.alpha = 0.7
            }
            let button = GradientButton {
                $0.orientation = GradientOrientation.horizontal.rawValue
                $0.startColor = .dodgerBlue
                $0.endColor = .azureRadiance
                $0.cornerRadius = 4
                $0.contentEdgeInsets = UIEdgeInsets(
                    top: 8,
                    left: 16,
                    bottom: 8,
                    right: 16)

                let title = link.1
                    .replacingOccurrences(of: "http://", with: "")
                    .replacingOccurrences(of: "https://", with: "")
                $0.setTitle(title, for: .normal)
                $0.titleLabel?.font = Avenir.heavy.of(size: 13)
                if link.1.hasPrefix("http") {
                    $0.accessibilityIdentifier = link.1
                } else {
                    $0.accessibilityIdentifier = "http://" + link.1
                }
                $0.addTarget(self, action: #selector(linkTapped), for: .touchUpInside)
            }
            linksStack?.addArrangedSubview(label)
            linksStack?.addArrangedSubview(button)
        }
    }

    @IBAction func linkTapped(_ sender: GradientButton) {
        if let link = sender.accessibilityIdentifier,
           let url = URL(string: link) {
            app.open(url)
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

    typealias Model = User

    @discardableResult func inject(model: Model) -> Self {
        user = model
        isSelf = model.id == data.user?.id
        if isSelf {
            visits = data.visited?.locations ?? []
        } else {
            mtp.loadUser(id: model.id) { _ in }

            if let scorecard = data.get(scorecard: .locations, user: model.id) {
                visits = Array(scorecard.visits)
            } else {
                visits = []
                mtp.loadScorecard(list: .locations,
                                  user: model.id) { [weak self] _ in
                    guard let self = self else { return }
                    if let scorecard = self.data.get(scorecard: .locations, user: model.id) {
                        self.visits = Array(scorecard.visits)
                        self.update(map: self.mapWidth)
                    }
                }
            }
       }

        return self
    }

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