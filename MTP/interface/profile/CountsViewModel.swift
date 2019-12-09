// @copyright Trollwerks Inc.

/// Tagging protocol for count cell models
protocol CountCellModel { }

/// Abstraction of two and three level hierarchy models
protocol CountsViewModel {

    /// Dequeue identifier and cell model group
    typealias CellInfo = (identifier: String,
                          model: CountCellModel)

    /// Hierarchy of list
    var hierarchy: Hierarchy { get }

    /// Top level of list: regions or brands
    var sectionCount: Int { get }
    /// Items in top level
    func itemCount(section index: Int) -> Int

    /// Model for section header
    func header(section index: Int) -> CountSectionModel

    /// Info for  cell
    func cell(info path: IndexPath) -> CellInfo

    /// Sort place list into model
    /// - Parameters:
    ///   - places: PlaceInfos to sort
    ///   - visited: IDs of visited places
    mutating func sort(places: [PlaceInfo],
                       visited: [Int])

    /// Toggle expanded state of section
    /// - Parameter section: Section
    mutating func toggle(section: String)

    /// Toggle expanded state of group: country or region
    /// - Parameters:
    ///   - section: Section
    ///   - group: group
    mutating func toggle(section: String,
                         group: String)

    /// Toggle expanded state of subgroup: location or country
    /// - Parameters:
    ///   - section: Section
    ///   - group: group
    mutating func toggle(section: String,
                         group: String,
                         subgroup: String)
}

/// Builder for CountsViewModel
struct CountsViewModelBuilder: ServiceProvider {

    private let checklist: Checklist
    private let isEditable: Bool

    /// Intialize with parameters
    /// - Parameters:
    ///   - checklist: Checklist
    ///   - isEditable: Is user's own counts
    init(checklist: Checklist,
         isEditable: Bool) {
        self.checklist = checklist
        self.isEditable = isEditable
    }

    /// Return appropriate view model
    func build() -> CountsViewModel {
        switch checklist.hierarchy {
        case .brandRegionCountry:
            return CountsThreeLevelViewModel(checklist: checklist,
                                             isEditable: isEditable,
                                             brands: data.brands)
        case .regionCountryLocation:
            return CountsThreeLevelViewModel(checklist: checklist,
                                             isEditable: isEditable,
                                             brands: [:])
        case .region,
             .regionCountry,
             .regionCountryCombined,
             .regionCountryWhs,
             .regionSubtitled:
            return CountsTwoLevelViewModel(checklist: checklist,
                                           isEditable: isEditable)
        }
    }
}
