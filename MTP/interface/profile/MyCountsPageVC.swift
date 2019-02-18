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

    private var list: Checklist = .locations

    typealias RegionKey = String
    typealias CountryKey = String
    typealias ParentKey = Int
    typealias CountryPlaces = [CountryKey: [PlaceInfo]]
    typealias CountryFamilies = [CountryKey: [ParentKey: [PlaceInfo]]]

    private var regions: [RegionKey] = []
    private var regionsPlaces: [RegionKey: [PlaceInfo]] = [:]
    private var regionsVisited: [RegionKey: Int] = [:]
    private var regionsExpanded: [RegionKey: Bool] = [:]

    private var countries: [RegionKey: [CountryKey]] = [:]
    private var countriesPlaces: [RegionKey: CountryPlaces] = [:]
    private var countriesFamilies: [RegionKey: CountryFamilies] = [:]
    private var countriesVisited: [RegionKey: [CountryKey: Int]] = [:]

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

            let count: Int
            if list.isShowingChildren {
                let parents = countriesPlaces[key]?.values.flatMap { $0 }.map { $0.placeId }
                count = Set<Int>(parents ?? []).count
            } else {
                count = regionsPlaces[key]?.count ?? 0
            }
            header.set(key: key,
                       count: count,
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

        if list.isShowingChildren {
            let regionCountries = countries[key]?.count ?? 0
            let parents = countriesPlaces[key] ?? [:]
            let regionParents = parents.reduce(0) { $0 + $1.value.count }
            let families = countriesFamilies[key] ?? [:]
            let regionChildren = families.reduce(0) { $0 + $1.value.values.flatMap { $0 }.count }
            let items = regionCountries + regionParents + regionChildren
            return items
        } else if list.isShowingCountries {
            let regionCountries = countries[key]?.count ?? 0
            return regionPlaces.count + regionCountries
        } else {
            return regionPlaces.count
        }
    }

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

    typealias GroupModel = (key: String, count: Int, visited: Int)
    typealias CellModel = (String, PlaceInfo?, GroupModel?)

    func model(of indexPath: IndexPath) -> CellModel {
        if list.isShowingChildren {
            return childrenModel(of: indexPath)
        } else if list.isShowingCountries {
            return countryModel(of: indexPath)
        } else {
            let regionPlaces = regionsPlaces[regions[indexPath.section]] ?? []
            return (CountToggleCell.reuseIdentifier, regionPlaces[indexPath.row], nil)
        }
    }

    func childrenModel(of indexPath: IndexPath) -> CellModel {
        let key = regions[indexPath.section]
        var countdown = indexPath.row

        let regionCountries = countries[key] ?? []
        for country in regionCountries {
            let countryParents = countriesPlaces[key]?[country] ?? []
            let countryChildren = countriesFamilies[key]?[country] ?? [:]
            if countdown == 0 {
                let visited = countriesVisited[key]?[country] ?? 0
                let model = (country, countryParents.count, visited)
                return (CountGroupCell.reuseIdentifier, nil, model)
            }
            countdown -= 1

            for place in countryParents {
                if countdown == 0 {
                    return (CountToggleCell.reuseIdentifier, place, nil)
                }
                countdown -= 1

                let placeChildren = countryChildren[place.placeId] ?? []
                for child in placeChildren {
                    if countdown == 0 {
                        return (CountToggleCell.reuseIdentifier, child, nil)
                    }
                    countdown -= 1
                }
            }
        }
        log.error("Failed to find childrenModel \(indexPath)")
        return (CountGroupCell.reuseIdentifier, nil, nil)
    }

    func countryModel(of indexPath: IndexPath) -> CellModel {
        let key = regions[indexPath.section]
        var countdown = indexPath.row

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
        log.error("Failed to find countryModel \(indexPath)")
        return (CountGroupCell.reuseIdentifier, nil, nil)
    }

    func count(places: [PlaceInfo],
               visits: [Int]) {
        let groupCountries = !list.isSubtitled
        regionsVisited = [:]
        countries = [:]
        countriesPlaces = [:]
        countriesFamilies = [:]
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

            let childPlaces = Dictionary(grouping: regionPlaces) { $0.placeCountry }
            let (parentPlaces, parentFamilies) = groupChildren(countries: childPlaces)
            countriesPlaces[region] = parentPlaces
            countriesFamilies[region] = parentFamilies
            countries[region] = parentPlaces.keys.sorted()

            var countryVisits: [CountryKey: Int] = [:]
            for (country, subplaces) in parentPlaces {
                let countryVisited = subplaces.reduce(0) {
                    $0 + (visits.contains($1.placeId) ? 1 : 0)
                }
                countryVisits[country] = countryVisited
            }
            countriesVisited[region] = countryVisits
        }
    }

    func groupChildren(countries: CountryPlaces) -> (CountryPlaces, CountryFamilies?) {
        guard list.isShowingChildren else { return (countries, nil) }

        var parentPlaces: CountryPlaces = [:]
        var parentFamilies: CountryFamilies = [:]
        for (country, places) in countries {
            var parents: [PlaceInfo] = []
            var families: [ParentKey: [PlaceInfo]] = [:]
            for place in places {
                if let parent = place.placeParent {
                    if !parents.contains { $0 == parent } {
                        parents.append(parent)
                    }
                    var family = families[parent.placeId] ?? []
                    family.append(place)
                    families[parent.placeId] = family.sorted { $0.placeName < $1.placeName }
                } else if !parents.contains { $0 == place } {
                    parents.append(place)
                }
            }
            parentPlaces[country] = parents.sorted { $0.placeName < $1.placeName }
            parentFamilies[country] = families.isEmpty ? nil: families
        }

        return (parentPlaces, parentFamilies.isEmpty ? nil: parentFamilies)
    }
}
