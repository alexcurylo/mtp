// @copyright Trollwerks Inc.

/// View model for region>country>location and brand>region>country counts
struct CountsThreeLevelViewModel: CountsViewModel {

    /// :nodoc:
    let hierarchy: Hierarchy
    /// :nodoc:
    var sectionCount: Int { return sections.count }
    private let checklist: Checklist
    private let isEditable: Bool

    fileprivate typealias SectionKey = String
    fileprivate typealias GroupKey = String
    fileprivate typealias SubgroupKey = String
    fileprivate typealias GroupPlaces = [GroupKey: [PlaceInfo]]
    fileprivate typealias GroupVisits = [GroupKey: Int]
    fileprivate typealias GroupExpanded = [GroupKey: Bool]
    fileprivate typealias SubgroupPlaces = [SubgroupKey: [PlaceInfo]]
    fileprivate typealias SubgroupVisits = [SubgroupKey: Int]
    fileprivate typealias SubgroupExpanded = [SubgroupKey: Bool]

    private var sections: [SectionKey] = []
    private var sectionsPlaces: [SectionKey: [PlaceInfo]] = [:]
    private var sectionsVisited: [SectionKey: Int] = [:]
    private var sectionsExpanded: [SectionKey: Bool] = [:]
    private var groups: [SectionKey: [GroupKey]] = [:]
    private var groupsPlaces: [SectionKey: GroupPlaces] = [:]
    private var groupsVisited: [SectionKey: GroupVisits] = [:]
    private var groupsExpanded: [SectionKey: GroupExpanded] = [:]
    private var subgroups: [SectionKey: [GroupKey: [SubgroupKey]]] = [:]
    private var subgroupsPlaces: [SectionKey: [GroupKey: SubgroupPlaces]] = [:]
    private var subgroupsVisited: [SectionKey: [GroupKey: SubgroupVisits]] = [:]
    private var subgroupsExpanded: [SectionKey: [GroupKey: SubgroupExpanded]] = [:]

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
    func itemCount(section index: Int) -> Int {
        let section = sections[index]
        guard let isExpanded = sectionsExpanded[section],
              isExpanded == true,
              let sectionGroups = groups[section] else { return 0 }

        var total = 0
        for group in sectionGroups {
            total += 1
            guard let isExpanded = groupsExpanded[section]?[group],
                  isExpanded == true,
                  let groupSubgroups = subgroups[section]?[group] else {
                    continue
            }

            for subgroup in groupSubgroups {
                if !isCombined(section: section, group: group) {
                    total += 1
                }
                guard let isExpanded = subgroupsExpanded[section]?[group]?[subgroup],
                      isExpanded == true,
                      let subgroupPlaces = subgroupsPlaces[section]?[group]?[subgroup] else {
                        continue
                }

                total += subgroupPlaces.count
            }
        }

        return total
    }

    /// :nodoc:
    func header(section index: Int) -> CountSectionModel {
        let section = sections[index]
        let count = sectionsPlaces[section]?.count ?? 0

        let model = CountSectionModel(
            section: section,
            visited: isEditable ? sectionsVisited[section, default: 0] : nil,
            count: count,
            isExpanded: sectionsExpanded[section, default: false]
        )
        return model
    }

    /// :nodoc:
    func cell(info path: IndexPath) -> CellInfo {
        let section = sections[path.section]
        var countdown = path.row

        let sectionGroups = groups[section] ?? []
        for group in sectionGroups {
            if countdown == 0 {
                let groupPlaces = groupsPlaces[section]?[group] ?? []
                let visited = groupsVisited[section]?[group] ?? 0
                return groupInfo(path: path,
                                 section: section,
                                 group: group,
                                 subgroup: nil,
                                 count: groupPlaces.count,
                                 visited: visited)
            }
            countdown -= 1

            guard let isExpanded = groupsExpanded[section]?[group],
                  isExpanded == true else { continue }

            let groupSubgroups = subgroups[section]?[group] ?? []
            for subgroup in groupSubgroups {
                let subgroupPlaces = subgroupsPlaces[section]?[group]?[subgroup] ?? []
                if !isCombined(section: section, group: group) {
                    if countdown == 0 {
                        let visited = subgroupsVisited[section]?[group]?[subgroup] ?? 0
                        return groupInfo(path: path,
                                         section: section,
                                         group: group,
                                         subgroup: subgroup,
                                         count: subgroupPlaces.count,
                                         visited: visited)
                    }
                    countdown -= 1
                }

                guard let isExpanded = subgroupsExpanded[section]?[group]?[subgroup],
                      isExpanded == true else { continue }

                for place in subgroupPlaces {
                    if countdown == 0 {
                        return itemInfo(path: path,
                                        place: place)
                    }
                    countdown -= 1
                }
            }
        }

        fatalError("Failed to find cell info: \(path)")
    }

    /// :nodoc:
    mutating func sort(places: [PlaceInfo],
                       visited: [Int]) {
        sectionsVisited = [:]
        groups = [:]
        groupsPlaces = [:]
        groupsVisited = [:]
        subgroups = [:]
        subgroupsPlaces = [:]
        subgroupsVisited = [:]

        switch hierarchy {
        case .regionCountryLocation:
            sectionsPlaces = Dictionary(grouping: places) { $0.placeRegion }
        case .brandRegionCountry:
            sectionsPlaces = Dictionary(grouping: places) {
                ($0 as? Hotel)?.brandName ?? L.unknown()
            }
        default:
            fatalError("incorrect 3 level model: \(hierarchy)")
        }

        sections = sectionsPlaces.keys.sorted()
        for (section, places) in sectionsPlaces {
            sort(section: section,
                 places: places,
                 visited: visited)
        }
    }

    /// :nodoc:
    mutating func toggle(section: String) {
        if let isExpanded = sectionsExpanded[section],
           isExpanded == true {
            sectionsExpanded[section] = false
            groupsExpanded[section] = nil
            subgroupsExpanded[section] = nil
        } else {
            sectionsExpanded[section] = true
        }
    }

    /// :nodoc:
    mutating func toggle(section: String,
                         group: String) {
        var expanded = groupsExpanded[section] ?? [:]
        if let isExpanded = expanded[group],
           isExpanded == true {
            expanded[group] = nil
            subgroupsExpanded[section]?[group] = nil
        } else {
            expanded[group] = true
            if isCombined(section: section, group: group) {
                if subgroupsExpanded[section] == nil {
                    subgroupsExpanded[section] = [:]
                }
                subgroupsExpanded[section]?[group] = [group: true]
            }
        }
        groupsExpanded[section] = expanded
    }

    /// :nodoc:
    mutating func toggle(section: String,
                         group: String,
                         subgroup: String) {
        if subgroupsExpanded[section] == nil {
            subgroupsExpanded[section] = [:]
        }
        var expanded = subgroupsExpanded[section]?[group] ?? [:]
        if let isExpanded = expanded[subgroup],
           isExpanded == true {
            expanded[subgroup] = nil
        } else {
            expanded[subgroup] = true
        }
        subgroupsExpanded[section]?[group] = expanded
    }
}

// MARK: - Private

private extension CountsThreeLevelViewModel {

    func isCombined(section: SectionKey,
                    group: GroupKey) -> Bool {
        guard let groupSubgroups = subgroups[section]?[group],
              groupSubgroups.count == 1 else { return false }
        return group == groupSubgroups.first
    }

    func isLast(path: IndexPath) -> Bool {
        let count = itemCount(section: path.section)
        return path.row == count - 1
    }

    func groupInfo(path: IndexPath,
                   section: SectionKey,
                   group: GroupKey,
                   subgroup: SubgroupKey?,
                   count: Int,
                   visited: Int) -> CellInfo {
        let expanded: Bool
        if let subgroup = subgroup {
            expanded = subgroupsExpanded[section]?[group]?[subgroup] ?? false
        } else {
            expanded = groupsExpanded[section]?[group] ?? false
        }
        let model = CountGroupModel(
            section: section,
            group: group,
            subgroup: subgroup,
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
                  place: PlaceInfo) -> CellInfo {
        let model = CountItemModel(
            title: place.placeTitle,
            subtitle: "",
            list: checklist,
            id: place.placeId,
            depth: 2,
            isVisitable: isEditable,
            isLast: isLast(path: path),
            isCombined: false,
            path: path
        )
        return (identifier: CountCellItem.reuseIdentifier,
                model: model)
    }

    mutating func sort(section: SectionKey,
                       places: [PlaceInfo],
                       visited: [Int]) {
        let sortedPlaces = places.sorted { $0.placeTitle < $1.placeTitle }
        sectionsPlaces[section] = sortedPlaces
        var sectionVisited = 0

        subgroups[section] = [:]
        subgroupsPlaces[section] = [:]
        subgroupsVisited[section] = [:]

        let groupPlaces: GroupPlaces
        switch hierarchy {
        case .regionCountryLocation:
            groupPlaces = Dictionary(grouping: sortedPlaces) { $0.placeCountry }
        case .brandRegionCountry:
            groupPlaces = Dictionary(grouping: sortedPlaces) { $0.placeRegion }
        default:
            fatalError("incorrect 3 level model: \(hierarchy)")
        }
        groupsPlaces[section] = groupPlaces
        groups[section] = groupPlaces.keys.sorted()
        var groupVisits: GroupVisits = [:]
        for (group, places) in groupPlaces {
            let visits = sort(section: section,
                              group: group,
                              places: places,
                              visited: visited)
            groupVisits[group] = visits
            sectionVisited += visits
        }
        groupsVisited[section] = groupVisits
        sectionsVisited[section] = sectionVisited
    }

    mutating func sort(section: SectionKey,
                       group: GroupKey,
                       places: [PlaceInfo],
                       visited: [Int]) -> Int {
        let sortedPlaces = places.sorted { $0.placeTitle < $1.placeTitle }
        var groupVisited = 0

        if subgroups[section] == nil {
            subgroups[section] = [:]
        }
        if subgroupsPlaces[section] == nil {
            subgroupsPlaces[section] = [:]
        }
        if subgroupsVisited[section] == nil {
            subgroupsVisited[section] = [:]
        }

        let subgroupPlaces: SubgroupPlaces
        switch hierarchy {
        case .regionCountryLocation:
            subgroupPlaces = Dictionary(grouping: sortedPlaces) {
                $0.placeLocation?.placeTitle ?? L.unknown()
            }
        case .brandRegionCountry:
            subgroupPlaces = Dictionary(grouping: sortedPlaces) { $0.placeCountry }
        default:
            fatalError("incorrect 3 level model: \(hierarchy)")
        }
        subgroupsPlaces[section]?[group] = subgroupPlaces
        subgroups[section]?[group] = subgroupPlaces.keys.sorted()
        var subgroupVisits: SubgroupVisits = [:]
        for (subgroup, places) in subgroupPlaces {
            let visits = places.reduce(0) {
                $0 + (visited.contains($1.placeId) ? 1 : 0)
            }
            subgroupVisits[subgroup] = visits
            groupVisited += visits
        }
        subgroupsVisited[section]?[group] = subgroupVisits

        return groupVisited
    }
}
