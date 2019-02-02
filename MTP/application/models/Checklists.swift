// @copyright Trollwerks Inc.

struct Checklists: Codable, ServiceProvider {

    var beaches: [Int]
    var divesites: [Int]
    var golfcourses: [Int]
    var locations: [Int]
    var restaurants: [Int]
    var uncountries: [Int]
    var whss: [Int]

    mutating func set(list: Checklist,
                      id: Int,
                      visited: Bool) {
        switch list {
        case .locations:
            set(visits: &locations, id: id, visited: visited)
        case .uncountries:
            set(visits: &uncountries, id: id, visited: visited)
        case .whss:
            set(visits: &whss, id: id, visited: visited)
        case .beaches:
            set(visits: &beaches, id: id, visited: visited)
        case .golfcourses:
            set(visits: &golfcourses, id: id, visited: visited)
        case .divesites:
            set(visits: &divesites, id: id, visited: visited)
        case .restaurants:
            set(visits: &restaurants, id: id, visited: visited)
        }
        mtp.check(list: list, id: id, visited: visited) { _ in }
    }

    func set(visits: inout [Int],
             id: Int,
             visited: Bool) {
        guard visits.contains(id) != visited else { return }
        if visited {
            visits.append(id)
        } else if let index = visits.index(of: id) {
            visits.remove(at: index)
        }
    }
}

extension Checklists: CustomStringConvertible {

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

extension Checklists: CustomDebugStringConvertible {

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

    var index: Self.AllCases.Index {
        // swiftlint:disable:next force_unwrapping
        return type(of: self).allCases.firstIndex(of: self)!
    }
}
