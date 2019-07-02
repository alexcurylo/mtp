// @copyright Trollwerks Inc.

import Anchorage
import Parchment

// swiftlint:disable file_length

class CountsPageVC: UIViewController, ServiceProvider {

    typealias CountsModel = Checklist

    let list: Checklist
    var isEditable: Bool { return false }
    var places: [PlaceInfo] { return [] }
    var visited: [Int] { return [] }

    private let infoSection = 0
    private var showsInfo: Bool { return isEditable }

    enum Layout {
        static let lineHeight = CGFloat(32)
        static let margin = CGFloat(8)
        static let collectionInsets = UIEdgeInsets(top: 0,
                                                   left: margin,
                                                   bottom: 0,
                                                   right: 0)
        static let sectionInsets = UIEdgeInsets(top: 0,
                                                left: 0,
                                                bottom: margin,
                                                right: 0)
        static let cellSpacing = CGFloat(0)
        static let cellCornerRadius = CGFloat(4)
    }

    // swiftlint:disable:next closure_body_length
    let collectionView: UICollectionView = {
        let flow = UICollectionViewFlowLayout()
        flow.minimumLineSpacing = Layout.cellSpacing
        flow.sectionInset = Layout.sectionInsets
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: flow)
        collectionView.backgroundColor = .clear
        collectionView.backgroundView = UIView { $0.backgroundColor = .clear }

        collectionView.register(
            CountCellItem.self,
            forCellWithReuseIdentifier: CountCellItem.reuseIdentifier)
        collectionView.register(
            CountCellGroup.self,
            forCellWithReuseIdentifier: CountCellGroup.reuseIdentifier)
        collectionView.register(
            CountSectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CountSectionHeader.reuseIdentifier)
        collectionView.register(
            CountInfoHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CountInfoHeader.reuseIdentifier)

        return collectionView
    }()

    typealias RegionKey = String
    typealias CountryKey = String
    typealias ParentKey = Int
    typealias CountryPlaces = [CountryKey: [PlaceInfo]]
    typealias CountryFamilies = [CountryKey: [ParentKey: [PlaceInfo]]]
    typealias CountryVisits = [CountryKey: Int]
    typealias CountryExpanded = [CountryKey: Bool]

    private var regions: [RegionKey] = []
    private var regionsPlaces: [RegionKey: [PlaceInfo]] = [:]
    private var regionsVisited: [RegionKey: Int] = [:]
    private var regionsExpanded: [RegionKey: Bool] = [:]

    private var countries: [RegionKey: [CountryKey]] = [:]
    private var countriesPlaces: [RegionKey: CountryPlaces] = [:]
    private var countriesFamilies: [RegionKey: CountryFamilies] = [:]
    private var countriesVisited: [RegionKey: CountryVisits] = [:]
    private var countriesExpanded: [RegionKey: CountryExpanded] = [:]

    init(model: CountsModel) {
        list = model
        super.init(nibName: nil, bundle: nil)

        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        collectionView.collectionViewLayout.invalidateLayout()
    }

    func configure() {
        view.addSubview(collectionView)
        collectionView.edgeAnchors == view.edgeAnchors + Layout.collectionInsets
        collectionView.dataSource = self
        collectionView.delegate = self

        update()
        observe()
    }

    func update() {
        count(places: places, visited: visited)
        collectionView.reloadData()
    }

    func observe() {
        // to be overridden
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CountsPageVC: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width,
                      height: Layout.lineHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width,
                      height: Layout.lineHeight)
    }
}

// MARK: - UICollectionViewDataSource

extension CountsPageVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch indexPath.section {
        case infoSection where showsInfo:
            return infoHeader(at: indexPath)
        default:
            let modelPath = IndexPath(row: indexPath.row,
                                      section: indexPath.section - 1)
            return countHeader(at: indexPath,
                               model: modelPath)
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return regions.count + (showsInfo ? 1 : 0)
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        switch section {
        case infoSection where showsInfo:
            return 0
        default:
            return numberOfItems(section: section - 1)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let modelPath: IndexPath
        if showsInfo {
            modelPath = IndexPath(row: indexPath.row,
                                  section: indexPath.section - 1)
        } else {
            modelPath = indexPath
        }

        return cell(at: indexPath,
                    model: modelPath)
    }
}

// MARK: - CountSectionHeaderDelegate

extension CountsPageVC: CountSectionHeaderDelegate {

    func toggle(region: String) {
        if let isExpanded = regionsExpanded[region],
           isExpanded == true {
            regionsExpanded[region] = false
            countriesExpanded[region] = nil
        } else {
            regionsExpanded[region] = true
        }
        collectionView.reloadData()
    }
}

// MARK: - CountCellGroupDelegate

extension CountsPageVC: CountCellGroupDelegate {

    func toggle(region: String,
                country: String) {
        var expanded = countriesExpanded[region] ?? [:]
        if let isExpanded = expanded[country],
           isExpanded == true {
            expanded[country] = nil
        } else {
            expanded[country] = true
        }
        countriesExpanded[region] = expanded
        collectionView.reloadData()
    }
}

// MARK: - Private

private extension CountsPageVC {

    typealias GroupModel = (region: String, country: String, count: Int, visited: Int)
    typealias CellModel = (identifier: String, place: PlaceInfo?, group: GroupModel?)

    func infoHeader(at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CountInfoHeader.reuseIdentifier,
            for: indexPath)

        if let header = view as? CountInfoHeader {
             header.set(list: list)
        }

        return view
    }

    func countHeader(at viewPath: IndexPath,
                     model modelPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CountSectionHeader.reuseIdentifier,
            for: viewPath)

        if let header = view as? CountSectionHeader {
            header.delegate = self
            let region = regions[modelPath.section]

            let count: Int
            switch list {
            case .whss:
                let parents = countriesPlaces[region]?.values.flatMap { $0 }.map { $0.placeId }
                count = Set<Int>(parents ?? []).count
            default:
                count = regionsPlaces[region]?.count ?? 0
            }

            let model = CountSectionModel(
                region: region,
                visited: isEditable ? regionsVisited[region, default: 0] : nil,
                count: count,
                isExpanded: regionsExpanded[region, default: false]
            )
            header.set(model: model)
        }

        return view
    }

    func cell(at viewPath: IndexPath,
              model modelPath: IndexPath) -> UICollectionViewCell {
        let cellModel = model(of: modelPath)
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: cellModel.identifier,
            for: viewPath)
        let itemCount = numberOfItems(section: modelPath.section)
        let isLast = modelPath.row == itemCount - 1

        switch cell {
        case let counter as CountCellItem:
            guard let place = cellModel.place else { break }
            let model = CountItemModel(
                title: place.placeTitle,
                subtitle: list.isSubtitled ? place.placeCountry : "",
                list: list,
                id: place.placeId,
                parentId: place.placeParent?.placeId,
                isVisitable: isEditable,
                isLast: isLast,
                isCombined: list == .locations && place.placeIsCountry
            )
            counter.set(model: model)
        case let grouper as CountCellGroup:
            guard let group = cellModel.group else { break }
            grouper.delegate = self
            let expanded = countriesExpanded[group.region]?[group.country] ?? false
            let model = CountGroupModel(
                region: group.region,
                country: group.country,
                visited: isEditable ? group.visited : nil,
                count: group.count,
                disclose: expanded ? .close : .expand,
                isLast: isLast
            )
            grouper.set(model: model)
        default:
            break
        }

        return cell
    }

    func numberOfItems(section: Int) -> Int {
        let region = regions[section]
        guard let isExpanded = regionsExpanded[region],
            isExpanded == true,
            let regionPlaces = regionsPlaces[region] else {
                return 0
        }

        switch list {
        case .whss:
            let regionCountries = countries[region] ?? []
            var regionParents = 0
            var regionChildren = 0
            for country in regionCountries {
                guard let isExpanded = countriesExpanded[region]?[country],
                    isExpanded == true,
                    let parents = countriesPlaces[region]?[country] else {
                        continue
                }
                regionParents += parents.count
                let families = countriesFamilies[region]?[country] ?? [:]
                regionChildren += families.count
            }
            return regionCountries.count + regionParents + regionChildren
        case .locations:
            let regionCountries = countries[region] ?? []
            var regionChildren = 0
            for country in regionCountries {
                guard let isExpanded = countriesExpanded[region]?[country],
                    isExpanded == true,
                    let countryPlaces = countriesPlaces[region]?[country] else {
                        continue
                }
                if let place = countryPlaces.first, place.placeIsCountry {
                    continue
                }
                regionChildren += countryPlaces.count
            }
            return regionCountries.count + regionChildren
        default:
            return regionPlaces.count
        }
    }

    func model(of indexPath: IndexPath) -> CellModel {
        switch list {
        case .whss:
            return childrenModel(of: indexPath)
        case .locations:
            return countryModel(of: indexPath)
        default:
            let regionPlaces = regionsPlaces[regions[indexPath.section]] ?? []
            return (CountCellItem.reuseIdentifier, regionPlaces[indexPath.row], nil)
        }
    }

    func childrenModel(of indexPath: IndexPath) -> CellModel {
        let region = regions[indexPath.section]
        var countdown = indexPath.row

        let regionCountries = countries[region] ?? []
        for country in regionCountries {
            let countryParents = countriesPlaces[region]?[country] ?? []
            let countryChildren = countriesFamilies[region]?[country] ?? [:]
            if countdown == 0 {
                let visited = countriesVisited[region]?[country] ?? 0
                let model = (region, country, countryParents.count, visited)
                return (CountCellGroup.reuseIdentifier, nil, model)
            }
            countdown -= 1

            guard let isExpanded = countriesExpanded[region]?[country],
                isExpanded == true else {
                    continue
            }

            for place in countryParents {
                if countdown == 0 {
                    return (CountCellItem.reuseIdentifier, place, nil)
                }
                countdown -= 1

                let placeChildren = countryChildren[place.placeId] ?? []
                for child in placeChildren {
                    if countdown == 0 {
                        return (CountCellItem.reuseIdentifier, child, nil)
                    }
                    countdown -= 1
                }
            }
        }
        log.error("Failed to find childrenModel \(indexPath)")
        return (CountCellGroup.reuseIdentifier, nil, nil)
    }

    func countryModel(of indexPath: IndexPath) -> CellModel {
        let region = regions[indexPath.section]
        var countdown = indexPath.row

        let regionCountries = countries[region] ?? []
        for country in regionCountries {
            let countryPlaces = countriesPlaces[region]?[country] ?? []
            if countdown == 0 {
                if let place = countryPlaces.first, place.placeIsCountry {
                    return (CountCellItem.reuseIdentifier, place, nil)
                }

                let visited = countriesVisited[region]?[country] ?? 0
                let model = (region, country, countryPlaces.count, visited)
                return (CountCellGroup.reuseIdentifier, nil, model)
            }
            countdown -= 1

            guard let isExpanded = countriesExpanded[region]?[country],
                isExpanded == true else {
                    continue
            }

            for place in countryPlaces {
                if countdown == 0 {
                    return (CountCellItem.reuseIdentifier, place, nil)
                }
                countdown -= 1
            }
        }
        log.error("Failed to find countryModel \(indexPath)")
        return (CountCellGroup.reuseIdentifier, nil, nil)
    }

    func count(places: [PlaceInfo],
               visited: [Int]) {
        regionsVisited = [:]
        countries = [:]
        countriesPlaces = [:]
        countriesFamilies = [:]
        countriesVisited = [:]

        regionsPlaces = Dictionary(grouping: places) { $0.placeRegion }
        regions = regionsPlaces.keys.filter { $0 != Location.all.regionName }.sorted()
        for (region, places) in regionsPlaces {
            count(region: region,
                  places: places,
                  visited: visited)
        }
    }

    func count(region: String,
               places: [PlaceInfo],
               visited: [Int]) {
        let groupCountries = !list.isSubtitled

        let regionPlaces = places.sorted {
            $0.placeTitle.uppercased() < $1.placeTitle.uppercased()
        }
        regionsPlaces[region] = regionPlaces

        let regionVisited = regionPlaces.reduce(0) {
            let parentVisit = $1.placeParent == nil && visited.contains($1.placeId)
            return $0 + (parentVisit ? 1 : 0)
        }
        regionsVisited[region] = regionVisited

        guard groupCountries else { return }

        let childPlaces = Dictionary(grouping: regionPlaces) { $0.placeCountry }
        let (parentPlaces, parentFamilies) = groupChildren(countries: childPlaces)
        countriesPlaces[region] = parentPlaces
        countriesFamilies[region] = parentFamilies
        countries[region] = parentPlaces.keys.sorted {
            $0.uppercased() < $1.uppercased()
        }

        var countryVisits: [CountryKey: Int] = [:]
        for (country, subplaces) in parentPlaces {
            let countryVisited = subplaces.reduce(0) {
                $0 + (visited.contains($1.placeId) ? 1 : 0)
            }
            countryVisits[country] = countryVisited
        }
        countriesVisited[region] = countryVisits
    }

    func groupChildren(countries: CountryPlaces) -> (CountryPlaces, CountryFamilies?) {
        guard list == .whss else { return (countries, nil) }

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
                    families[parent.placeId] = family.sorted { $0.placeTitle < $1.placeTitle }
                } else if !parents.contains { $0 == place } {
                    parents.append(place)
                }
            }
            parentPlaces[country] = parents.sorted { $0.placeTitle < $1.placeTitle }
            parentFamilies[country] = families.isEmpty ? nil: families
        }

        return (parentPlaces, parentFamilies.isEmpty ? nil: parentFamilies)
    }
}
