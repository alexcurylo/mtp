// @copyright Trollwerks Inc.

import UIKit

/// Displays location information
final class LocationInfoVC: UITableViewController, ServiceProvider {

    @IBOutlet private var regionLabel: UILabel?
    @IBOutlet private var countryTitle: UILabel?
    @IBOutlet private var countryLabel: UILabel?
    @IBOutlet private var mtpVisitorsLabel: UILabel?
    @IBOutlet private var mtpRankingLabel: UILabel?

    @IBOutlet private var flagImageView: UIImageView?

    @IBOutlet private var airportsStack: UIStackView?
    @IBOutlet private var airportsLabel: UILabel?

    @IBOutlet private var linksStack: UIStackView?

    //swiftlint:disable:next implicitly_unwrapped_optional
    private var location: Location!

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        configure()
    }

    /// Instrument and inject navigation
    ///
    /// - Parameters:
    ///   - segue: Navigation action
    ///   - sender: Action originator
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

// MARK: - UITableViewDelegate

extension LocationInfoVC {

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

private extension LocationInfoVC {

    func configure() {
        configureInfo()
        configureAirports()
        configureLinks()
    }

    func configureInfo() {
        regionLabel?.text = location.placeRegion

        if location.isCountry {
            countryTitle?.text = L.titleUnRanking()
            countryLabel?.text = "\(location.rankUn)"
        } else {
            countryTitle?.text = L.titleCountry()
            countryLabel?.text = location.placeCountry
        }

        mtpVisitorsLabel?.text = location.placeVisitors.grouped

        mtpRankingLabel?.text = "\(location.rank)"

        flagImageView?.load(flag: location)
    }

    func configureAirports() {
        guard !location.airports.isEmpty else {
            airportsLabel?.text = L.none()
            return
        }

        airportsLabel?.text = location.airports

        guard let home = data.user?.airport,
              !home.isEmpty else {
            let button = UIButton {
                $0.setTitle(L.setHomeAirport(), for: .normal)
                $0.setTitleColor(.regalBlue, for: .normal)
                $0.titleLabel?.font = Avenir.bookOblique.of(size: 15)
                $0.addTarget(self,
                             action: #selector(setHomeTapped),
                             for: .touchUpInside)
            }
            airportsStack?.addArrangedSubview(button)
            return
        }

        let today = Date()
        let nextWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: today) ?? today
        let now = DateFormatter.mtpLocalDay.string(from: today)
        let then = DateFormatter.mtpLocalDay.string(from: nextWeek)
        let currency = Locale.current.currencyCode ?? "USD"
        for airport in location.airports.components(separatedBy: ", ") {
            if airport == home || airport.isEmpty { continue }

            let title = L.flightRoute(home, airport)
            let link = L.flightLink(home, airport, now, airport, home, then, currency)
            let button = GradientButton.urlButton(title: title, link: link)
            button.addTarget(self, action: #selector(linkTapped), for: .touchUpInside)
            airportsStack?.addArrangedSubview(button)
        }
    }

    func configureLinks() {
        let titles = [L.whenToGo(),
                      L.currentWeather(),
                      L.wikitravel(),
                      L.wikimapia(),
                      L.wikipedia()]
        let name = location.placeTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let station = location.weatherhist
        let lat = "\(location.latitude)"
        let lon = "\(location.longitude)"
        let links = [L.whenToGoLink(station),
                     L.currentWeatherLink(lat, lon),
                     L.wikitravelLink(name),
                     L.wikimapiaLink(lat, lon),
                     L.wikipediaLink(name)]
        for (title, link) in zip(titles, links) {
            let button = GradientButton.urlButton(title: title, link: link)
            button.addTarget(self, action: #selector(linkTapped), for: .touchUpInside)
            linksStack?.addArrangedSubview(button)
        }
    }

    @objc func linkTapped(_ sender: GradientButton) {
        if let link = sender.accessibilityIdentifier,
            let url = URL(string: link) {
            app.launch(url: url)
        }
    }

    @objc func setHomeTapped(_ sender: UIButton) {
        app.route(to: .editProfile)
    }
}

// MARK: - Injectable

extension LocationInfoVC: Injectable {

    /// Injected dependencies
    typealias Model = Mappable

    /// Handle dependency injection
    ///
    /// - Parameter model: Dependencies
    /// - Returns: Chainable self
    @discardableResult func inject(model: Model) -> Self {
        if model.checklist == .locations {
            location = data.get(location: model.checklistId)
        }
        return self
    }

    /// Enforce dependency injection
    func requireInjections() {
        location.require()

        regionLabel.require()
        mtpVisitorsLabel.require()
        mtpRankingLabel.require()
        countryLabel.require()
        flagImageView.require()
        airportsStack.require()
        airportsLabel.require()
        linksStack.require()
    }
}
