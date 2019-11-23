// @copyright Trollwerks Inc.

/// Tagging protocol for count cell models
protocol CountCellModel { }

protocol CountsViewModel {

    typealias CellInfo = (identifier: String,
                          model: CountCellModel)

    /// Hierarchy of list
    var hierarchy: Hierarchy { get }

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

/// Builder for CountsViewModel
struct CountsViewModelBuilder {

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
        case .brandRegionCountry,
             .regionCountryLocation:
            return CountsThreeLevelViewModel(checklist: checklist,
                                             isEditable: isEditable)
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
