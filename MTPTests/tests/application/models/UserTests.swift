// @copyright Trollwerks Inc.

@testable import MTP
import XCTest

final class UserTests: TestCase {

    func testDecodingComplete() throws {
        // given
        let data = try XCTUnwrap(complete.data(using: .utf8))

        // when
        do {
            let json = try JSONDecoder.mtp.decode(UserJSON.self, from: data)
            print("\(json)")
        } catch {
             XCTFail("decoding: \(error)")
        }

        // then

        // TBD - diagnostic to find login changes
    }
}

private let complete = """
{
  "id": 7853,
  "username": "test@test.com",
  "email": "atest@test.com",
  "first_name": "Alex",
  "last_name": "Curylo",
  "birthday": "1998-02-22",
  "location_id": 88,
  "country_id": 920,
  "gender": "M",
  "status": "A",
  "visibility": "public",
  "last_log_in": null,
  "score": 1248,
  "bio": "iPhone programmer and bon vivant currently kicking it at Agoda.com in electric Bangkok, Thailand.",
  "links": [
    {
      "url": "https://everywhs.com",
      "text": "Every World Heritage Site"
    },
    {
      "url": "https://alexcurylo.com",
      "text": "Trollwerks"
    }
  ],
  "favorite_places": [
    {
      "type": "",
      "id": ""
    }
  ],
  "picture": "52TMnrrd0vD3NMUFrDtYcf",
  "airport": "BKK",
  "facebook_id": 4242424224242424,
  "facebook_email": "atest@test.com",
  "facebook_user_token": null,
  "score_locations": 461,
  "score_uncountries": 110,
  "score_whss": 525,
  "score_beaches": 19,
  "score_golfcourses": 1,
  "score_divesites": 1,
  "score_restaurants": 1,
  "score_top100restaurants": 1,
  "score_hotels": 6,
  "rank_locations": 176,
  "rank_uncountries": 872,
  "rank_whss": 27,
  "rank_beaches": 156,
  "rank_golfcourses": 212,
  "rank_divesites": 11029,
  "rank_restaurants": 399,
  "rank_top100restaurants": 173,
  "rank_hotels": 10,
  "created_at": "2008-06-25 10:12:23",
  "updated_at": "2019-11-19 00:30:12",
  "token": "whatever",
  "followers": {
    "users": []
  },
  "followings": {
    "users": [],
    "locations": []
  },
  "scores": {
    "locations": {
      "user": 461,
      "max": 891
    },
    "uncountries": {
      "user": 110,
      "max": 193
    },
    "whss": {
      "user": 525,
      "max": 1120
    },
    "beaches": {
      "user": 19,
      "max": 159
    },
    "golfcourses": {
      "user": 0,
      "max": 100
    },
    "divesites": {
      "user": 0,
      "max": 99
    },
    "restaurants": {
      "user": 1,
      "max": 706
    }
  },
  "milestones": {
    "locations": {
      "name": "Platinum",
      "min": 400,
      "max": 499,
      "$$hashKey": "object:45"
    },
    "uncountries": {
      "name": "UN Gold",
      "min": 100,
      "max": 149,
      "$$hashKey": "object:120"
    },
    "whss": {
      "name": "UNESCO Hall of Fame",
      "min": 500,
      "max": 9999999999,
      "$$hashKey": "object:61"
    },
    "beaches": {
      "name": "Beach Bum",
      "min": 6,
      "max": 25,
      "$$hashKey": "object:434"
    },
    "golfcourses": {
      "name": "Duffer",
      "min": 1,
      "max": 10,
      "$$hashKey": "object:86"
    },
    "divesites": {
      "name": "Landlubber",
      "min": 1,
      "max": 9,
      "$$hashKey": "object:102"
    },
    "restaurants": {
      "name": "Starving",
      "min": 1,
      "max": 24,
      "$$hashKey": "object:118"
    },
    "top100restaurants": false,
    "hotels": {
      "name": "Homeless",
      "min": 1,
      "max": 24,
      "$$hashKey": "object:13057"
    }
  },
  "full_name": "Alex Curylo",
  "country": {
    "id": 920,
    "region_id": 990,
    "country_id": 920,
    "location_name": "Canada",
    "region_name": "North America",
    "country_name": "Canada",
    "featured_img": null
  },
  "location": {
    "id": 88,
    "region_id": 990,
    "country_id": 920,
    "location_name": "British Columbia",
    "region_name": "North America",
    "country_name": "Canada",
    "lat": 53.7266683,
    "lon": -127.6476206,
    "zoom": 5,
    "featured_img": "5svD7v2KIvIHdL2aELAisP",
    "admin_level": 4
  },
  "role": 1,
  "friends": [
    {
      "id": 1,
      "first_name": "Charles A",
      "last_name": "Veley",
      "score_locations": 857,
      "location_id": 89,
      "country_id": 977,
      "picture": "5tbIhFZN4LKREO3floTuTG",
      "full_name": "Charles A Veley",
      "country": {
        "id": 977,
        "region_id": 990,
        "country_id": 977,
        "location_name": "United States",
        "region_name": "North America",
        "country_name": "United States",
        "featured_img": null
      },
      "location": {
        "id": 89,
        "region_id": 990,
        "country_id": 977,
        "location_name": "California",
        "region_name": "North America",
        "country_name": "United States",
        "lat": 36.778261,
        "lon": -119.4179324,
        "zoom": 6,
        "featured_img": "5xvUEekjsZLgTG8RIOVYVB",
        "admin_level": 4
      },
      "role": 1,
      "pivot": {
        "user_id": 7853,
        "friend_id": 1
      }
    },
    {
      "id": 41929,
      "first_name": "Kobkaew",
      "last_name": "Patsit",
      "score_locations": 9,
      "location_id": 554,
      "country_id": 554,
      "picture": null,
      "full_name": "Kobkaew Patsit",
      "country": {
        "id": 554,
        "region_id": 983,
        "country_id": 554,
        "location_name": "Thailand",
        "region_name": "Asia",
        "country_name": "Thailand",
        "featured_img": "13UZEYS9ZaX2oSsJxMTXJd"
      },
      "location": {
        "id": 554,
        "region_id": 983,
        "country_id": 554,
        "location_name": "Thailand",
        "region_name": "Asia",
        "country_name": "Thailand",
        "lat": 15.870032,
        "lon": 100.992541,
        "zoom": 5,
        "featured_img": "13UZEYS9ZaX2oSsJxMTXJd",
        "admin_level": 2
      },
      "role": 2,
      "pivot": {
        "user_id": 7853,
        "friend_id": 41929
      }
    }
  ]
}
"""
