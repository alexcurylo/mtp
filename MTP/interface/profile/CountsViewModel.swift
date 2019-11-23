// @copyright Trollwerks Inc.

import Foundation

// swiftlint:disable file_length

/// Tagging protocol for count cell models
protocol CountCellModel { }

private struct CountCellModelFailure: CountCellModel { }

protocol CountsViewModel {

    typealias CellInfo = (identifier: String,
                          model: CountCellModel)

    /// Current hierarchy of list
    var hierarchy: Hierarchy { get set }

    /// Top level of list: regions or brands
    var sectionCount: Int { get }
    /// Items in top level
    func itemCount(section: Int) -> Int

    /// Model for section header
    func header(model section: Int) -> CountSectionModel

    /// Info for  cell
    func cell(info path: IndexPath) -> CellInfo

    /// Sort place list into model
    /// - Parameters:
    ///   - places: PlaceInfos to sort
    ///   - visited: IDs of visited places
    mutating func sort(places: [PlaceInfo],
                       visited: [Int])

    /// Toggle expanded state of region
    /// - Parameter region: Region
    mutating func toggle(region: String)

    /// Toggle expanded state of country
    /// - Parameters:
    ///   - region: Region
    ///   - country: Country
    mutating func toggle(region: String,
                         country: String)
}

/// View model for region>country counts
struct RegionCountryViewModel: CountsViewModel, ServiceProvider {

    /// :nodoc:
    var hierarchy: Hierarchy

    /// :nodoc:
    var sectionCount: Int { return regions.count }

    private let checklist: Checklist
    private let isEditable: Bool

    private typealias RegionKey = String
    private typealias CountryKey = String
    private typealias CountryPlaces = [CountryKey: [PlaceInfo]]
    private typealias CountryVisits = [CountryKey: Int]
    private typealias CountryExpanded = [CountryKey: Bool]

    private typealias ParentKey = Int
    private typealias CountryFamilies = [CountryKey: [ParentKey: [PlaceInfo]]]

    private var regions: [RegionKey] = []
    private var regionsPlaces: [RegionKey: [PlaceInfo]] = [:]
    private var regionsVisited: [RegionKey: Int] = [:]
    private var regionsExpanded: [RegionKey: Bool] = [:]

    private var countries: [RegionKey: [CountryKey]] = [:]
    private var countriesPlaces: [RegionKey: CountryPlaces] = [:]
    private var countriesVisited: [RegionKey: CountryVisits] = [:]
    private var countriesExpanded: [RegionKey: CountryExpanded] = [:]

    private var countriesFamilies: [RegionKey: CountryFamilies] = [:]

    /// Intialize with parameters
    /// - Parameters:
    ///   - hierarchy: Current hierarchy
    ///   - isEditable: Is user's own counts
    init(checklist: Checklist,
         isEditable: Bool) {
        self.checklist = checklist
        hierarchy = checklist.hierarchy
        self.isEditable = isEditable
    }

    /// :nodoc:
    func itemCount(section: Int) -> Int {
        let region = regions[section]
        guard let isExpanded = regionsExpanded[region],
            isExpanded == true,
            let regionPlaces = regionsPlaces[region] else {
                return 0
        }

        switch hierarchy {
        case .brandRegionCountry,
             .regionCountryLocation:
            log.error("fix section expansion \(hierarchy)")
            fallthrough
        case .region,
             .regionSubtitled:
            return regionPlaces.count
        case .regionCountryWhs:
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
                regionChildren += families.values.reduce(0) { $0 + $1.count }
            }
            return regionCountries.count + regionParents + regionChildren
        case .regionCountry,
             .regionCountryCombined:
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
        }
    }

    /// :nodoc:
    func header(model section: Int) -> CountSectionModel {
        let region = regions[section]

        let count: Int
        switch hierarchy {
        case .regionCountryWhs:
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

        return model
    }

    /// :nodoc:
    func cell(info path: IndexPath) -> CellInfo {
        switch hierarchy {
        case .regionCountryWhs:
            return childrenInfo(path: path)
        case .regionCountry,
             .regionCountryCombined:
            return countryInfo(path: path)
        case .brandRegionCountry,
             .regionCountryLocation:
            log.error("fix cell creation \(hierarchy)")
            fallthrough
        case .region,
             .regionSubtitled:
            return regionInfo(path: path)
        }
    }

    /// :nodoc:
    mutating func sort(places: [PlaceInfo],
                       visited: [Int]) {
        regionsVisited = [:]
        countries = [:]
        countriesPlaces = [:]
        countriesFamilies = [:]
        countriesVisited = [:]

        regionsPlaces = Dictionary(grouping: places) { $0.placeRegion }
        regions = regionsPlaces.keys.filter { $0 != Location.all.placeRegion }.sorted()
        for (region, places) in regionsPlaces {
            sort(region: region,
                 places: places,
                 visited: visited)
        }
    }

    /// :nodoc:
    mutating func toggle(region: String) {
        if let isExpanded = regionsExpanded[region],
           isExpanded == true {
            regionsExpanded[region] = false
            countriesExpanded[region] = nil
        } else {
            regionsExpanded[region] = true
        }
    }

    /// :nodoc:
    mutating func toggle(region: String,
                         country: String) {
        var expanded = countriesExpanded[region] ?? [:]
        if let isExpanded = expanded[country],
           isExpanded == true {
            expanded[country] = nil
        } else {
            expanded[country] = true
        }
        countriesExpanded[region] = expanded
    }
}

// MARK: - Private

private extension RegionCountryViewModel {

    func isLast(path: IndexPath) -> Bool {
        let count = itemCount(section: path.section)
        let isLast = path.row == count - 1
        return isLast
    }

    func groupInfo(path: IndexPath,
                   region: String,
                   country: String,
                   count: Int,
                   visited: Int) -> CellInfo {
        let expanded = countriesExpanded[region]?[country] ?? false
        let model = CountGroupModel(
            region: region,
            country: country,
            visited: isEditable ? visited : nil,
            count: count,
            disclose: expanded ? .close : .expand,
            isLast: isLast(path: path),
            path: path
        )
        return (identifier: CountCellGroup.reuseIdentifier,
                model: model)
    }

    func itemInfo(path: IndexPath,
                  place: PlaceInfo,
                  isChild: Bool) -> CellInfo {
        let subtitle = hierarchy.isSubtitled ? place.placeCountry : ""
        let combined = hierarchy.isCombined &&
                       place.placeIsCountry &&
                       !isChild
        let model = CountItemModel(
            title: place.placeTitle,
            subtitle: subtitle,
            list: checklist,
            id: place.placeId,
            parentId: place.placeParent?.placeId,
            isVisitable: isEditable,
            isLast: isLast(path: path),
            isCombined: combined,
            path: path
        )
        return (identifier: CountCellItem.reuseIdentifier,
                model: model)
    }

    func regionInfo(path: IndexPath) -> CellInfo {
        let regionPlaces = regionsPlaces[regions[path.section]] ?? []
        return itemInfo(path: path,
                        place: regionPlaces[path.row],
                        isChild: false)
    }

    func childrenInfo(path: IndexPath) -> CellInfo {
        let region = regions[path.section]
        var countdown = path.row

        let regionCountries = countries[region] ?? []
        for country in regionCountries {
            let countryParents = countriesPlaces[region]?[country] ?? []
            let countryChildren = countriesFamilies[region]?[country] ?? [:]
            if countdown == 0 {
                let visited = countriesVisited[region]?[country] ?? 0
                return groupInfo(path: path,
                                 region: region,
                                 country: country,
                                 count: countryParents.count,
                                 visited: visited)
            }
            countdown -= 1

            guard let isExpanded = countriesExpanded[region]?[country],
                isExpanded == true else {
                    continue
            }

            for place in countryParents {
                if countdown == 0 {
                    return itemInfo(path: path,
                                    place: place,
                                    isChild: false)
                }
                countdown -= 1

                let placeChildren = countryChildren[place.placeId] ?? []
                for child in placeChildren {
                    if countdown == 0 {
                        return itemInfo(path: path,
                                        place: child,
                                        isChild: true)
                    }
                    countdown -= 1
                }
            }
        }
        log.error("Failed to find childrenInfo \(path)")
        return (identifier: CountCellGroup.reuseIdentifier,
                model: CountCellModelFailure())
    }

    func countryInfo(path: IndexPath) -> CellInfo {
        let region = regions[path.section]
        var countdown = path.row

        let regionCountries = countries[region] ?? []
        for country in regionCountries {
            let regionPlaces = countriesPlaces[region] ?? [:]
            let countryPlaces = regionPlaces[country] ?? []
            if countdown == 0 {
                if countryPlaces.count == 1,
                   let place = countryPlaces.first,
                   place.placeIsCountry {
                    return itemInfo(path: path,
                                    place: place,
                                    isChild: false)
                }

                let visited = countriesVisited[region]?[country] ?? 0
                return groupInfo(path: path,
                                 region: region,
                                 country: country,
                                 count: countryPlaces.count,
                                 visited: visited)
            }
            countdown -= 1

            guard let isExpanded = countriesExpanded[region]?[country],
                isExpanded == true else {
                    continue
            }

            for place in countryPlaces {
                if countdown == 0 {
                    return itemInfo(path: path,
                                    place: place,
                                    isChild: true)
                }
                countdown -= 1
            }
        }
        log.error("Failed to find countryInfo \(path)")
        return (identifier: CountCellGroup.reuseIdentifier,
                model: CountCellModelFailure())
    }

    mutating func sort(region: String,
                       places: [PlaceInfo],
                       visited: [Int]) {
        let regionPlaces = places.sorted {
            $0.placeTitle.uppercased() < $1.placeTitle.uppercased()
        }
        regionsPlaces[region] = regionPlaces

        let regionVisited = regionPlaces.reduce(0) {
            let parentVisit = $1.placeParent == nil && visited.contains($1.placeId)
            return $0 + (parentVisit ? 1 : 0)
        }
        regionsVisited[region] = regionVisited

        guard hierarchy.isGroupingByCountry else { return }

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

    private func groupChildren(countries: CountryPlaces) -> (CountryPlaces, CountryFamilies?) {
        switch hierarchy {
        case .regionCountry,
             .regionCountryWhs:
            break
        case .brandRegionCountry,
             .regionCountryLocation:
            log.error("fix model creation \(hierarchy)")
            fallthrough
        case .region,
             .regionCountryCombined,
             .regionSubtitled:
            return (countries, nil)
        }

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
