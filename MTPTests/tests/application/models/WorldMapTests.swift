// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class WorldMapTests: MTPTestCase {

    // swiftlint:disable:next implicitly_unwrapped_optional
    private var sut: WorldMap!

    override func setUp() {
        super.setUp()
        sut = WorldMap()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testPerformanceContains() throws {
        let venezuela = 1_004 // highest ID 19.11.25
        // GeoJSON.Feature implementation:
        // 2.9 GHz 15": 5.925 - 6.287 seconds
        // 2.7 GHz 13": 6.465 - 7.600 seconds
        measure {
            (1...venezuela).forEach {
                _ = sut.contains(coordinate: .zero,
                                 location: $0)
            }
        }
    }

    func testPerformanceDrawFullSize() throws {
        // GeoJSON.Feature implementation, uncached:
        // 2.9 GHz 15": 2.080 - 2.206 seconds
        // GeoJSON.Feature implementation, cached:
        // 2.7 GHz 13": 1.982 - 2.003 seconds
        measure {
            _ = sut.full(map: [])
        }
    }

    func testPerformanceDrawProfile() throws {
        // GeoJSON.Feature implementation:
        // 2.9 GHz 15": 1.399 - 1.482 seconds
        // 2.7 GHz 13": 1.480 - 1.554 seconds
        // GeoJSON.Feature implementation, cached:
        // 2.7 GHz 13": 1.300 - 1.357 seconds
        // UIBezierPath implementation:
        // 2.7 GHz 13": 0.663 - 0.675 seconds
        measure {
            let view = UIView()
            _ = sut.profile(map: view,
                            visits: [],
                            width: 375)
        }
    }
}
