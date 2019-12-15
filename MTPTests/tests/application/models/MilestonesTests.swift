// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class MilestonesTests: TestCase {

    func testDecoding() throws {
        // given
        let data = try XCTUnwrap(settingsString.data(using: .utf8))

        // when
        let json = try JSONDecoder.mtp.decode(SettingsJSON.self,
                                              from: data)
        let lists = Checklist.allCases.compactMap {
            Milestones(from: json, list: $0)
        }

        // then
        XCTAssertEqual(lists.count, Checklist.allCases.count)
        let thresholds = RealmDataControllerTests.thresholds
        for (index, list) in Checklist.allCases.enumerated() {
            let milestones = lists[index]
            XCTAssertEqual(list, milestones.checklist)
            XCTAssertEqual(thresholds[index], milestones.thresholds.count)
        }
    }
}

private let settingsString = """
{
    "milestone-thresholds": {
        "locations": [
        {
        "name": "Couch Potato",
        "min": 1,
        "max": 24,
        "$$hashKey": "object:38"
        },
        {
        "name": "Tourist",
        "min": 25,
        "max": 49,
        "$$hashKey": "object:39"
        },
        {
        "name": "Backpacker",
        "min": 50,
        "max": 74,
        "$$hashKey": "object:40"
        },
        {
        "name": "Ambassador",
        "min": 75,
        "max": 99,
        "$$hashKey": "object:41"
        },
        {
        "name": "Senior Ambassador",
        "min": 100,
        "max": 199,
        "$$hashKey": "object:42"
        },
        {
        "name": "Silver",
        "min": 200,
        "max": 299,
        "$$hashKey": "object:43"
        },
        {
        "name": "Gold",
        "min": 300,
        "max": 399,
        "$$hashKey": "object:44"
        },
        {
        "name": "Platinum",
        "min": 400,
        "max": 499,
        "$$hashKey": "object:45"
        },
        {
        "name": "Hall of Fame",
        "min": 500,
        "max": 9999999999,
        "$$hashKey": "object:164"
        }
        ],
        "whss": [
        {
        "name": "Newborn",
        "min": 1,
        "max": 24,
        "$$hashKey": "object:56"
        },
        {
        "name": "Beginner",
        "min": 25,
        "max": 99,
        "$$hashKey": "object:166"
        },
        {
        "name": "Explorer",
        "min": 100,
        "max": 199,
        "$$hashKey": "object:58"
        },
        {
        "name": "Professor",
        "min": 200,
        "max": 299,
        "$$hashKey": "object:59"
        },
        {
        "name": "Indiana Jones",
        "min": 300,
        "max": 499,
        "$$hashKey": "object:60"
        },
        {
        "name": "UNESCO Hall of Fame",
        "min": 500,
        "max": 9999999999,
        "$$hashKey": "object:61"
        }
        ],
        "beaches": [
        {
        "name": "Pale as a Ghost",
        "min": 1,
        "max": 5,
        "$$hashKey": "object:433"
        },
        {
        "name": "Beach Bum",
        "min": 6,
        "max": 25,
        "$$hashKey": "object:434"
        },
        {
        "name": "Golden Bronze",
        "min": 26,
        "max": 39,
        "$$hashKey": "object:435"
        },
        {
        "name": "International Lifesaver",
        "min": 40,
        "max": 999999,
        "$$hashKey": "object:436"
        }
        ],
        "golfcourses": [
        {
        "name": "Duffer",
        "min": 1,
        "max": 10,
        "$$hashKey": "object:86"
        },
        {
        "name": "Caddy",
        "min": 11,
        "max": 24,
        "$$hashKey": "object:87"
        },
        {
        "name": "Local Pro",
        "min": 25,
        "max": 49,
        "$$hashKey": "object:88"
        },
        {
        "name": "PGA All-star",
        "min": 50,
        "max": 74,
        "$$hashKey": "object:89"
        },
        {
        "name": "World Golf Hall of Fame",
        "min": 75,
        "max": 999,
        "$$hashKey": "object:90"
        }
        ],
        "divesites": [
        {
        "name": "Landlubber",
        "min": 1,
        "max": 9,
        "$$hashKey": "object:102"
        },
        {
        "name": "Open Water",
        "min": 10,
        "max": 24,
        "$$hashKey": "object:103"
        },
        {
        "name": "Dive Master",
        "min": 25,
        "max": 49,
        "$$hashKey": "object:104"
        },
        {
        "name": "Aquaman",
        "min": 50,
        "max": 74,
        "$$hashKey": "object:105"
        },
        {
        "name": "Jacques Cousteau",
        "min": 75,
        "max": 9999,
        "$$hashKey": "object:106"
        }
        ],
        "restaurants": [
        {
        "name": "Starving",
        "min": 1,
        "max": 24,
        "$$hashKey": "object:118"
        },
        {
        "name": "Hungry",
        "min": 25,
        "max": 49,
        "$$hashKey": "object:119"
        },
        {
        "name": "Epicure",
        "min": 50,
        "max": 74,
        "$$hashKey": "object:120"
        },
        {
        "name": "Gourmand",
        "min": 75,
        "max": 99,
        "$$hashKey": "object:121"
        },
        {
        "name": "Senior Critic",
        "min": 100,
        "max": 199,
        "$$hashKey": "object:122"
        },
        {
        "name": "Master Taster",
        "min": 200,
        "max": 299,
        "$$hashKey": "object:123"
        },
        {
        "name": "Dining Hall of Fame",
        "min": 300,
        "max": 9999999999,
        "$$hashKey": "object:125"
        }
        ],
        "uncountries": [
        {
        "name": "UNCP (Couch Potato)",
        "min": 1,
        "max": 24,
        "$$hashKey": "object:116"
        },
        {
        "name": "UN Tourist",
        "min": 25,
        "max": 49,
        "$$hashKey": "object:117"
        },
        {
        "name": "UN Backpacker",
        "min": 50,
        "max": 74,
        "$$hashKey": "object:118"
        },
        {
        "name": "UN Ambassador",
        "min": 75,
        "max": 99,
        "$$hashKey": "object:119"
        },
        {
        "name": "UN Gold",
        "min": 100,
        "max": 149,
        "$$hashKey": "object:120"
        },
        {
        "name": "UN Platinum",
        "min": 150,
        "max": 174,
        "$$hashKey": "object:121"
        },
        {
        "name": "Almost There",
        "min": 175,
        "max": 192,
        "$$hashKey": "object:122"
        },
        {
        "name": "UN Hall of Fame",
        "min": 193,
        "max": 9999999999,
        "$$hashKey": "object:123"
        }
        ],
        "hotels": [
          {
            "name": "Starving",
            "min": 1,
            "max": 24,
            "$$hashKey": "object:118"
          },
          {
            "name": "Hungry",
            "min": 25,
            "max": 49,
            "$$hashKey": "object:119"
          },
          {
            "name": "Epicure",
            "min": 50,
            "max": 74,
            "$$hashKey": "object:120"
          },
          {
            "name": "Gourmand",
            "min": 75,
            "max": 99,
            "$$hashKey": "object:121"
          },
          {
            "name": "Senior Critic",
            "min": 100,
            "max": 199,
            "$$hashKey": "object:122"
          },
          {
            "name": "Master Taster",
            "min": 200,
            "max": 299,
            "$$hashKey": "object:123"
          },
          {
            "name": "Dining Hall of Fame",
            "min": 300,
            "max": 9999999999,
            "$$hashKey": "object:125"
          }
        ]
    }
}
"""
