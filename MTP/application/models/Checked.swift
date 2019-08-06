// @copyright Trollwerks Inc.

/// Excchange visit status with MTP endpoint
struct Checked: Codable, ServiceProvider {

    /// Visited beaches
    var beaches: [Int] = []
    /// Visited divesites
    var divesites: [Int] = []
    /// Visited golfcourses
    var golfcourses: [Int] = []
    /// Visited locations
    var locations: [Int] = []
    /// Visited restaurants
    var restaurants: [Int] = []
    /// Visited uncountries
    var uncountries: [Int] = []
    /// Visited whss
    var whss: [Int] = []

    /// Index by checklist
    ///
    /// - Parameter list: Checklist
    subscript(list: Checklist) -> [Int] {
        switch list {
        case .beaches:
            return beaches
        case .divesites:
            return divesites
        case .golfcourses:
            return golfcourses
        case .locations:
            return locations
        case .restaurants:
            return restaurants
        case .uncountries:
            return uncountries
        case .whss:
            return whss
        }
    }

    /// Set visited status
    ///
    /// - Parameters:
    ///   - item: Item to set
    ///   - visited: Status to set
    mutating func set(item: Checklist.Item,
                      visited: Bool) {
        set(list: item.list, id: item.id, checked: visited)
    }
}

// MARK: - Private

private extension Checked {

    mutating func set(list: Checklist,
                      id: Int,
                      checked: Bool) {
        switch list {
        case .locations:
            set(array: &locations, id: id, checked: checked)
        case .uncountries:
            set(array: &uncountries, id: id, checked: checked)
        case .whss:
            set(array: &whss, id: id, checked: checked)
        case .beaches:
            set(array: &beaches, id: id, checked: checked)
        case .golfcourses:
            set(array: &golfcourses, id: id, checked: checked)
        case .divesites:
            set(array: &divesites, id: id, checked: checked)
        case .restaurants:
            set(array: &restaurants, id: id, checked: checked)
        }
    }

    func set(array: inout [Int],
             id: Int,
             checked: Bool) {
        guard array.contains(id) != checked else { return }

        if checked {
            array.append(id)
        } else if let index = array.firstIndex(of: id) {
            array.remove(at: index)
        }
    }
}

extension Checked: CustomStringConvertible {

    public var description: String {
        return """
        \(beaches.count) beaches \
        \(divesites.count) divesites \
        \(golfcourses.count) golfcourses \
        \(locations.count) locations \
        \(restaurants.count) restaurants \
        \(uncountries.count) uncountries \
        \(whss.count) whss
        """
    }
}

extension Checked: CustomDebugStringConvertible {

    var debugDescription: String {
        return """
        < Checklists::
        beaches: \(beaches.debugDescription)
        divesites: \(divesites.debugDescription)
        golfcourses: \(golfcourses.debugDescription)
        locations: \(locations.debugDescription)
        restaurants: \(restaurants.debugDescription)
        uncountries: \(uncountries.debugDescription)
        whss: \(whss.debugDescription)
        /Checklists >
        """
    }
}

extension Hashable where Self: CaseIterable {

    /// Convenience for indexing by case
    var index: Self.AllCases.Index {
        // swiftlint:disable:next force_unwrapping
        return type(of: self).allCases.firstIndex(of: self)!
    }
}
