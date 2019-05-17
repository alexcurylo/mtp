// @copyright Trollwerks Inc.

import UIKit

final class MyAboutVC: UITableViewController, ServiceProvider {

    @IBOutlet private var rankingLabel: UILabel?
    @IBOutlet private var mapImageView: UIImageView?
    @IBOutlet private var visitedButton: GradientButton?
    @IBOutlet private var remainingButton: GradientButton?
    @IBOutlet private var bioTextView: UITextView?

    @IBOutlet private var airportLabel: UILabel?

    @IBOutlet private var linksStack: UIStackView?

    private var locationsObserver: Observer?
    private var userObserver: Observer?

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
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

// MARK: - UITableViewDelegate

extension MyAboutVC {

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

private extension MyAboutVC {

    func update() {
        guard let user = data.user else { return }

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
        userObserver = data.observer(of: .user) { [weak self] _ in
            self?.update()
        }
    }

    func update(map width: CGFloat) {
        guard width > 0,
            let image = data.worldMap.draw(with: width) else { return }

        mapWidth = image.size.width
        mapImageView?.image = image
    }

    func update(ranking user: UserJSON) {
        let list = Checklist.locations

        let rank = list.rank()
        let ranking = Localized.ranking(rank.grouped)
        rankingLabel?.text = ranking

        let status = list.status(of: user)
        let visited = Localized.visitedCount(status.visited)
        visitedButton?.setTitle(visited, for: .normal)
        let remaining = Localized.remainingCount(status.remaining)
        remainingButton?.setTitle(remaining, for: .normal)

        bioTextView?.text = user.bio
    }

    func update(airport user: UserJSON) {
        airportLabel?.text = user.airport
    }

    func update(links user: UserJSON) {
        guard let views = linksStack?.arrangedSubviews else { return }
        (2..<views.count).forEach { index in
            views[index].removeFromSuperview()
        }

        for link in user.links ?? [] {
            guard !link.text.isEmpty else { continue }

            let label = UILabel {
                $0.text = link.text.uppercased()
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

                let title = link.url
                    .replacingOccurrences(of: "http://", with: "")
                    .replacingOccurrences(of: "https://", with: "")
                $0.setTitle(title, for: .normal)
                $0.titleLabel?.font = Avenir.heavy.of(size: 13)
                $0.accessibilityIdentifier = link.url
                $0.addTarget(self, action: #selector(tapLink), for: .touchUpInside)
            }
            linksStack?.addArrangedSubview(label)
            linksStack?.addArrangedSubview(button)
        }
    }

    @IBAction func tapLink(_ sender: GradientButton) {
        if let link = sender.accessibilityIdentifier,
           let url = URL(string: link) {
            app.open(url)
        }
    }
}

extension MyAboutVC: Injectable {

    typealias Model = ()

    @discardableResult func inject(model: Model) -> Self {
        return self
    }

    func requireInjections() {
        rankingLabel.require()
        mapImageView.require()
        visitedButton.require()
        remainingButton.require()
        bioTextView.require()
        airportLabel.require()
        linksStack.require()
    }
}
