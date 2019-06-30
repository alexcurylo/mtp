// @copyright Trollwerks Inc.

import UIKit

final class LocationInfoVC: UITableViewController, ServiceProvider {

    @IBOutlet private var infoStack: UIStackView?
    @IBOutlet private var regionLabel: UILabel?
    @IBOutlet private var countryLabel: UILabel?
    @IBOutlet private var mtpVisitorsLabel: UILabel?
    @IBOutlet private var mtpRankingLabel: UILabel?
    @IBOutlet private var unRankingLabel: UILabel?
    @IBOutlet private var weatherLabel: UILabel?

    @IBOutlet private var airportsLabel: UILabel?

    @IBOutlet private var linksStack: UIStackView?

    //swiftlint:disable:next implicitly_unwrapped_optional
    private var location: Location!

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        configure()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

// MARK: - UITableViewDelegate

extension LocationInfoVC {

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

private extension LocationInfoVC {

    func configure() {
        regionLabel?.text = "Region: \(location.regionName)"
        mtpVisitorsLabel?.text = "MTP Visitors: \(location.placeVisitors)"
        mtpRankingLabel?.text = "MTP Ranking: \(location.rank)"
        weatherLabel?.text = "Weather: \(location.weatherhist)"
        if location.isCountry {
            unRankingLabel?.text = "UN Ranking: \(location.rankUn)"
            if let countryLabel = countryLabel {
                infoStack?.removeArrangedSubview(countryLabel)
                countryLabel.removeFromSuperview()
            }
        } else {
           countryLabel?.text = "Country: \(location.countryName)"
            if let unRankingLabel = unRankingLabel {
                infoStack?.removeArrangedSubview(unRankingLabel)
                unRankingLabel.removeFromSuperview()
            }
        }

        if location.airports.isEmpty {
            airportsLabel?.text = L.none()
        } else {
            airportsLabel?.text = location.airports
        }

        log.todo("sort out links as on site info page")
        let linkNames = ["When To Go",
                         "Current Weather",
                         "Wikitravel",
                         "Wikimapia",
                         "Wikipedia"]
        for link in linkNames {
            let label = UILabel {
                $0.text = link
                $0.font = Avenir.heavyOblique.of(size: 15)
                $0.alpha = 0.7
            }
            linksStack?.addArrangedSubview(label)
        }
    }
}

extension LocationInfoVC: Injectable {

    typealias Model = PlaceAnnotation

    @discardableResult func inject(model: Model) -> Self {
        if model.list == .locations {
            location = data.get(location: model.id)
        }
        return self
    }

    func requireInjections() {
        location.require()
    }
}
