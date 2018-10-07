// @copyright Trollwerks Inc.

import UIKit

final class MyAboutVC: UITableViewController {

    @IBOutlet private var rankingLabel: UILabel?
    @IBOutlet private var mapImageView: UIImageView?
    @IBOutlet private var visitedButton: GradientButton?
    @IBOutlet private var remainingButton: GradientButton?
    @IBOutlet private var bioTextView: UITextView?

    @IBOutlet private var airportLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configure()
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

private extension MyAboutVC {

    func configure() {
        guard let user = gestalt.user else { return }

        log.debug("TO DO: configure about")

        configure(ranking: user)
        configure(airport: user)
        configure(favorite: user)
        configure(links: user)

        tableView.setNeedsLayout()
    }

    func configure(ranking user: User) {
        let rank = 9_999
        let ranking = Localized.ranking(rank.grouped)
        rankingLabel?.text = ranking

        let visited = Localized.visited(user.visited)
        visitedButton?.setTitle(visited, for: .normal)

        let remaining = Localized.remaining(user.remaining)
        remainingButton?.setTitle(remaining, for: .normal)

        bioTextView?.text = user.bio
    }

    func configure(airport user: User) {
        airportLabel?.text = user.airport
    }

    func configure(favorite user: User) {
    }

    func configure(links user: User) {
    }
}
