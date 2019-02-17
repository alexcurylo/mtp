// @copyright Trollwerks Inc.

import Anchorage
import Parchment

protocol MyCountsPageVCDelegate: AnyObject {

    func didScroll(myCountsPageVC: MyCountsPageVC)
}

final class MyCountsPageVC: UIViewController, ServiceProvider {

    private enum Layout {
        static let headerHeight = CGFloat(32)
        static let margin = CGFloat(8)
        static let collectionInsets = UIEdgeInsets(top: 0,
                                                   left: margin,
                                                   bottom: 0,
                                                   right: 0)
        static let sectionInsets = UIEdgeInsets(top: 0,
                                                left: 0,
                                                bottom: margin,
                                                right: 0)
        static let cellHeight = CGFloat(51)
        static let cellSpacing = CGFloat(0)
    }

    let collectionView: UICollectionView = {
        let flow = UICollectionViewFlowLayout()
        flow.minimumLineSpacing = Layout.cellSpacing
        flow.sectionInset = Layout.sectionInsets
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: flow)
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    weak var delegate: MyCountsPageVCDelegate?

    typealias RegionKey = String
    typealias CountryKey = String
    typealias LocationKey = String

    private var list: Checklist = .locations

    private var regions: [RegionKey] = []
    private var regionsPlaces: [RegionKey: [PlaceInfo]] = [:]
    private var regionsVisited: [RegionKey: Int] = [:]
    private var regionsExpanded: [RegionKey: Bool] = [:]

    private var countries: [RegionKey: [CountryKey]] = [:]
    private var countriesPlaces: [RegionKey: [CountryKey: [PlaceInfo]]] = [:]
    private var countriesVisited: [RegionKey: [CountryKey: Int]] = [:]

    private var locations: [RegionKey: [CountryKey: [LocationKey]]] = [:]
    private var locationsPlaces: [RegionKey: [CountryKey: [LocationKey: [PlaceInfo]]]] = [:]
    private var locationsVisited: [RegionKey: [CountryKey: [LocationKey: Int]]] = [:]

    private var checklistsObserver: Observer?
    private var placesObserver: Observer?

    init(options: PagingOptions) {
        super.init(nibName: nil, bundle: nil)

        view.addSubview(collectionView)
        collectionView.edgeAnchors == view.edgeAnchors + Layout.collectionInsets

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            CountToggleCell.self,
            forCellWithReuseIdentifier: CountToggleCell.reuseIdentifier)
        collectionView.register(
            CountGroupCell.self,
            forCellWithReuseIdentifier: CountGroupCell.reuseIdentifier)
        collectionView.register(
            CountHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CountHeader.reuseIdentifier)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    func set(list: Checklist) {
        self.list = list
        count(places: list.places,
              visits: list.visits)

        collectionView.reloadData()
        observe()
    }
}

extension MyCountsPageVC: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width,
                      height: Layout.headerHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width,
                      height: Layout.cellHeight)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.didScroll(myCountsPageVC: self)
    }
}

extension MyCountsPageVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CountHeader.reuseIdentifier,
            for: indexPath)

        if let header = view as? CountHeader {
            header.delegate = self
            let key = regions[indexPath.section]
            header.set(key: key,
                       count: regionsPlaces[key]?.count ?? 0,
                       visited: regionsVisited[key, default: 0],
                       isExpanded: regionsExpanded[key, default: false])
        }

        return view
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return regions.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        let key = regions[section]
        guard let isExpanded = regionsExpanded[key],
           isExpanded == true,
           let regionPlaces = regionsPlaces[key] else {
            return 0
        }

        switch list.hierarchy {
        case .country,
             .regionSubgrouped:
            let regionCountries = countries[key]?.count ?? 0
            return regionPlaces.count + regionCountries
        default:
            return regionPlaces.count
        }
    }

    typealias GroupModel = (key: String, count: Int, visited: Int)
    typealias CellModel = (String, PlaceInfo?, GroupModel?)

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let (identifier, place, group) = model(of: indexPath)
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: identifier,
            for: indexPath)

        switch cell {
        case let counter as CountToggleCell:
            if let place = place {
                let isLast = indexPath.row == self.collectionView(
                    collectionView,
                    numberOfItemsInSection: indexPath.section) - 1
                counter.set(title: place.placeName,
                            subtitle: list.isSubtitled ? place.placeCountry : "",
                            list: list,
                            id: place.placeId,
                            isLast: isLast)
            }
        case let grouper as CountGroupCell:
            if let group = group {
                grouper.set(key: group.key,
                            count: group.count,
                            visited: group.visited)
            }
        default:
            break
        }

        return cell
    }

    func model(of indexPath: IndexPath) -> CellModel {
        let key = regions[indexPath.section]
        var countdown = indexPath.row

        switch list.hierarchy {
        case .country,
             .regionSubgrouped:
            let regionCountries = countries[key] ?? []
            for country in regionCountries {
                let countryPlaces = countriesPlaces[key]?[country] ?? []
                if countdown == 0 {
                    let visited = countriesVisited[key]?[country] ?? 0
                    let model = (country, countryPlaces.count, visited)
                    return (CountGroupCell.reuseIdentifier, nil, model)
                }
                countdown -= 1

                for place in countryPlaces {
                    if countdown == 0 {
                        return (CountToggleCell.reuseIdentifier, place, nil)
                    }
                    countdown -= 1
                }
            }
            log.error("Failed to find grouped line model!")
            return (CountGroupCell.reuseIdentifier, nil, nil)
        default:
             let regionPlaces = regionsPlaces[key] ?? []
             return (CountToggleCell.reuseIdentifier, regionPlaces[countdown], nil)
        }
    }

    func observe() {
        guard checklistsObserver == nil else { return }

        checklistsObserver = data.observer(of: .checklists) { [weak self] _ in
            guard let self = self else { return }
            self.set(list: self.list)
        }
        placesObserver = list.observer { [weak self] _ in
            guard let self = self else { return }
            self.set(list: self.list)
        }
    }
}

extension MyCountsPageVC: CountHeaderDelegate {

    func toggle(section key: String) {
        if let isExpanded = regionsExpanded[key],
           isExpanded == true {
            regionsExpanded[key] = false
        } else {
            regionsExpanded[key] = true
        }
        collectionView.reloadData()
    }
}

private extension MyCountsPageVC {

    func count(places: [PlaceInfo],
               visits: [Int]) {
        let groupCountries = list.isGrouped || list.isSubgrouped
        regionsVisited = [:]
        countries = [:]
        countriesPlaces = [:]
        countriesVisited = [:]

        regionsPlaces = Dictionary(grouping: places) { $0.placeRegion }
        regions = regionsPlaces.keys.filter { $0 != Location.all.regionName }.sorted()
        for (region, places) in regionsPlaces {
            let regionPlaces = places.sorted { $0.placeName < $1.placeName }
            regionsPlaces[region] = regionPlaces
            let regionVisited = regionPlaces.reduce(0) {
                $0 + (visits.contains($1.placeId) ? 1 : 0)
            }
            regionsVisited[region] = regionVisited

            if !groupCountries { continue }

            let countryPlaces = Dictionary(grouping: regionPlaces) { $0.placeCountry }
            countriesPlaces[region] = countryPlaces
            countries[region] = countryPlaces.keys.sorted()
            var countryVisits: [CountryKey: Int] = [:]
            for (country, subplaces) in countryPlaces {
                let countryVisited = subplaces.reduce(0) {
                    $0 + (visits.contains($1.placeId) ? 1 : 0)
                }
                countryVisits[country] = countryVisited
            }
            countriesVisited[region] = countryVisits
        }
    }
}
