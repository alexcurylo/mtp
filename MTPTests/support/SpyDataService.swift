// @copyright Trollwerks Inc.

@testable import MTP
import RealmSwift

// swiftlint:disable file_length line_length
// swiftlint:disable let_var_whitespace implicitly_unwrapped_optional type_body_length discouraged_optional_collection large_tuple
final class SpyDataService: DataService {

    var invokedBeachesGetter = false
    var invokedBeachesGetterCount = 0
    var stubbedBeaches: [Beach]! = []
    var beaches: [Beach] {
        invokedBeachesGetter = true
        invokedBeachesGetterCount += 1
        return stubbedBeaches
    }
    var invokedChecklistsSetter = false
    var invokedChecklistsSetterCount = 0
    var invokedChecklists: Checklists?
    var invokedChecklistsList = [Checklists?]()
    var invokedChecklistsGetter = false
    var invokedChecklistsGetterCount = 0
    var stubbedChecklists: Checklists!
    var checklists: Checklists? {
        set {
            invokedChecklistsSetter = true
            invokedChecklistsSetterCount += 1
            invokedChecklists = newValue
            invokedChecklistsList.append(newValue)
        }
        get {
            invokedChecklistsGetter = true
            invokedChecklistsGetterCount += 1
            return stubbedChecklists
        }
    }
    var invokedCountriesGetter = false
    var invokedCountriesGetterCount = 0
    var stubbedCountries: [Country]! = []
    var countries: [Country] {
        invokedCountriesGetter = true
        invokedCountriesGetterCount += 1
        return stubbedCountries
    }
    var invokedDivesitesGetter = false
    var invokedDivesitesGetterCount = 0
    var stubbedDivesites: [DiveSite]! = []
    var divesites: [DiveSite] {
        invokedDivesitesGetter = true
        invokedDivesitesGetterCount += 1
        return stubbedDivesites
    }
    var invokedEmailSetter = false
    var invokedEmailSetterCount = 0
    var invokedEmail: String?
    var invokedEmailList = [String]()
    var invokedEmailGetter = false
    var invokedEmailGetterCount = 0
    var stubbedEmail: String! = ""
    var email: String {
        set {
            invokedEmailSetter = true
            invokedEmailSetterCount += 1
            invokedEmail = newValue
            invokedEmailList.append(newValue)
        }
        get {
            invokedEmailGetter = true
            invokedEmailGetterCount += 1
            return stubbedEmail
        }
    }
    var invokedEtagsSetter = false
    var invokedEtagsSetterCount = 0
    var invokedEtags: [String: String]?
    var invokedEtagsList = [[String: String]]()
    var invokedEtagsGetter = false
    var invokedEtagsGetterCount = 0
    var stubbedEtags: [String: String]! = [:]
    var etags: [String: String] {
        set {
            invokedEtagsSetter = true
            invokedEtagsSetterCount += 1
            invokedEtags = newValue
            invokedEtagsList.append(newValue)
        }
        get {
            invokedEtagsGetter = true
            invokedEtagsGetterCount += 1
            return stubbedEtags
        }
    }
    var invokedGolfcoursesGetter = false
    var invokedGolfcoursesGetterCount = 0
    var stubbedGolfcourses: [GolfCourse]! = []
    var golfcourses: [GolfCourse] {
        invokedGolfcoursesGetter = true
        invokedGolfcoursesGetterCount += 1
        return stubbedGolfcourses
    }
    var invokedLastRankingsQuerySetter = false
    var invokedLastRankingsQuerySetterCount = 0
    var invokedLastRankingsQuery: RankingsQuery?
    var invokedLastRankingsQueryList = [RankingsQuery]()
    var invokedLastRankingsQueryGetter = false
    var invokedLastRankingsQueryGetterCount = 0
    var stubbedLastRankingsQuery: RankingsQuery!
    var lastRankingsQuery: RankingsQuery {
        set {
            invokedLastRankingsQuerySetter = true
            invokedLastRankingsQuerySetterCount += 1
            invokedLastRankingsQuery = newValue
            invokedLastRankingsQueryList.append(newValue)
        }
        get {
            invokedLastRankingsQueryGetter = true
            invokedLastRankingsQueryGetterCount += 1
            return stubbedLastRankingsQuery
        }
    }
    var invokedLocationsGetter = false
    var invokedLocationsGetterCount = 0
    var stubbedLocations: [Location]! = []
    var locations: [Location] {
        invokedLocationsGetter = true
        invokedLocationsGetterCount += 1
        return stubbedLocations
    }
    var invokedMapDisplaySetter = false
    var invokedMapDisplaySetterCount = 0
    var invokedMapDisplay: ChecklistFlags?
    var invokedMapDisplayList = [ChecklistFlags]()
    var invokedMapDisplayGetter = false
    var invokedMapDisplayGetterCount = 0
    var stubbedMapDisplay: ChecklistFlags!
    var mapDisplay: ChecklistFlags {
        set {
            invokedMapDisplaySetter = true
            invokedMapDisplaySetterCount += 1
            invokedMapDisplay = newValue
            invokedMapDisplayList.append(newValue)
        }
        get {
            invokedMapDisplayGetter = true
            invokedMapDisplayGetterCount += 1
            return stubbedMapDisplay
        }
    }
    var invokedPostsGetter = false
    var invokedPostsGetterCount = 0
    var stubbedPosts: [Post]! = []
    var posts: [Post] {
        invokedPostsGetter = true
        invokedPostsGetterCount += 1
        return stubbedPosts
    }
    var invokedRestaurantsGetter = false
    var invokedRestaurantsGetterCount = 0
    var stubbedRestaurants: [Restaurant]! = []
    var restaurants: [Restaurant] {
        invokedRestaurantsGetter = true
        invokedRestaurantsGetterCount += 1
        return stubbedRestaurants
    }
    var invokedTokenSetter = false
    var invokedTokenSetterCount = 0
    var invokedToken: String?
    var invokedTokenList = [String]()
    var invokedTokenGetter = false
    var invokedTokenGetterCount = 0
    var stubbedToken: String! = ""
    var token: String {
        set {
            invokedTokenSetter = true
            invokedTokenSetterCount += 1
            invokedToken = newValue
            invokedTokenList.append(newValue)
        }
        get {
            invokedTokenGetter = true
            invokedTokenGetterCount += 1
            return stubbedToken
        }
    }
    var invokedUncountriesGetter = false
    var invokedUncountriesGetterCount = 0
    var stubbedUncountries: [UNCountry]! = []
    var uncountries: [UNCountry] {
        invokedUncountriesGetter = true
        invokedUncountriesGetterCount += 1
        return stubbedUncountries
    }
    var invokedUserSetter = false
    var invokedUserSetterCount = 0
    var invokedUser: UserJSON?
    var invokedUserList = [UserJSON?]()
    var invokedUserGetter = false
    var invokedUserGetterCount = 0
    var stubbedUser: UserJSON!
    var user: UserJSON? {
        set {
            invokedUserSetter = true
            invokedUserSetterCount += 1
            invokedUser = newValue
            invokedUserList.append(newValue)
        }
        get {
            invokedUserGetter = true
            invokedUserGetterCount += 1
            return stubbedUser
        }
    }
    var invokedWhssGetter = false
    var invokedWhssGetterCount = 0
    var stubbedWhss: [WHS]! = []
    var whss: [WHS] {
        invokedWhssGetter = true
        invokedWhssGetterCount += 1
        return stubbedWhss
    }
    var invokedWorldMapGetter = false
    var invokedWorldMapGetterCount = 0
    var stubbedWorldMap: WorldMap!
    var worldMap: WorldMap {
        invokedWorldMapGetter = true
        invokedWorldMapGetterCount += 1
        return stubbedWorldMap
    }
    var invokedStatusKeyGetter = false
    var invokedStatusKeyGetterCount = 0
    var stubbedStatusKey: StatusKey!
    var statusKey: StatusKey {
        invokedStatusKeyGetter = true
        invokedStatusKeyGetterCount += 1
        return stubbedStatusKey
    }
    var invokedNotificationGetter = false
    var invokedNotificationGetterCount = 0
    var stubbedNotification: Notification.Name!
    var notification: Notification.Name {
        invokedNotificationGetter = true
        invokedNotificationGetterCount += 1
        return stubbedNotification
    }
    var invokedAppGetter = false
    var invokedAppGetterCount = 0
    var stubbedApp: ApplicationService!
    var app: ApplicationService {
        invokedAppGetter = true
        invokedAppGetterCount += 1
        return stubbedApp
    }
    var invokedDataGetter = false
    var invokedDataGetterCount = 0
    var stubbedData: DataService!
    var data: DataService {
        invokedDataGetter = true
        invokedDataGetterCount += 1
        return stubbedData
    }
    var invokedLogGetter = false
    var invokedLogGetterCount = 0
    var stubbedLog: LoggingService!
    var log: LoggingService {
        invokedLogGetter = true
        invokedLogGetterCount += 1
        return stubbedLog
    }
    var invokedMtpGetter = false
    var invokedMtpGetterCount = 0
    var stubbedMtp: MTPNetworkService!
    var mtp: MTPNetworkService {
        invokedMtpGetter = true
        invokedMtpGetterCount += 1
        return stubbedMtp
    }
    var invokedGetCountry = false
    var invokedGetCountryCount = 0
    var invokedGetCountryParameters: (id: Int?, Void)?
    var invokedGetCountryParametersList = [(id: Int?, Void)]()
    var stubbedGetCountryResult: Country!
    func get(country id: Int?) -> Country? {
        invokedGetCountry = true
        invokedGetCountryCount += 1
        invokedGetCountryParameters = (id, ())
        invokedGetCountryParametersList.append((id, ()))
        return stubbedGetCountryResult
    }
    var invokedGetLocation = false
    var invokedGetLocationCount = 0
    var invokedGetLocationParameters: (id: Int?, Void)?
    var invokedGetLocationParametersList = [(id: Int?, Void)]()
    var stubbedGetLocationResult: Location!
    func get(location id: Int?) -> Location? {
        invokedGetLocation = true
        invokedGetLocationCount += 1
        invokedGetLocationParameters = (id, ())
        invokedGetLocationParametersList.append((id, ()))
        return stubbedGetLocationResult
    }
    var invokedGetLocationPhotos = false
    var invokedGetLocationPhotosCount = 0
    var invokedGetLocationPhotosParameters: (id: Int, Void)?
    var invokedGetLocationPhotosParametersList = [(id: Int, Void)]()
    var stubbedGetLocationPhotosResult: [Photo]! = []
    func get(locationPhotos id: Int) -> [Photo] {
        invokedGetLocationPhotos = true
        invokedGetLocationPhotosCount += 1
        invokedGetLocationPhotosParameters = (id, ())
        invokedGetLocationPhotosParametersList.append((id, ()))
        return stubbedGetLocationPhotosResult
    }
    var invokedGetLocations = false
    var invokedGetLocationsCount = 0
    var invokedGetLocationsParameters: (filter: String, Void)?
    var invokedGetLocationsParametersList = [(filter: String, Void)]()
    var stubbedGetLocationsResult: [Location]! = []
    func get(locations filter: String) -> [Location] {
        invokedGetLocations = true
        invokedGetLocationsCount += 1
        invokedGetLocationsParameters = (filter, ())
        invokedGetLocationsParametersList.append((filter, ()))
        return stubbedGetLocationsResult
    }
    var invokedGetPhotosPages = false
    var invokedGetPhotosPagesCount = 0
    var invokedGetPhotosPagesParameters: (id: Int?, Void)?
    var invokedGetPhotosPagesParametersList = [(id: Int?, Void)]()
    var stubbedGetPhotosPagesResult: Results<PhotosPageInfo>!
    func getPhotosPages(user id: Int?) -> Results<PhotosPageInfo> {
        invokedGetPhotosPages = true
        invokedGetPhotosPagesCount += 1
        invokedGetPhotosPagesParameters = (id, ())
        invokedGetPhotosPagesParametersList.append((id, ()))
        return stubbedGetPhotosPagesResult
    }
    var invokedGetPhoto = false
    var invokedGetPhotoCount = 0
    var invokedGetPhotoParameters: (photo: Int, Void)?
    var invokedGetPhotoParametersList = [(photo: Int, Void)]()
    var stubbedGetPhotoResult: Photo!
    func get(photo: Int) -> Photo {
        invokedGetPhoto = true
        invokedGetPhotoCount += 1
        invokedGetPhotoParameters = (photo, ())
        invokedGetPhotoParametersList.append((photo, ()))
        return stubbedGetPhotoResult
    }
    var invokedGetUserPhotos = false
    var invokedGetUserPhotosCount = 0
    var invokedGetUserPhotosParameters: (id: Int?, location: Int?)?
    var invokedGetUserPhotosParametersList = [(id: Int?, location: Int?)]()
    var stubbedGetUserPhotosResult: [Photo]! = []
    func get(user id: Int?,
             photos location: Int?) -> [Photo] {
        invokedGetUserPhotos = true
        invokedGetUserPhotosCount += 1
        invokedGetUserPhotosParameters = (id, location)
        invokedGetUserPhotosParametersList.append((id, location))
        return stubbedGetUserPhotosResult
    }
    var invokedGetRankings = false
    var invokedGetRankingsCount = 0
    var invokedGetRankingsParameters: (query: RankingsQuery, Void)?
    var invokedGetRankingsParametersList = [(query: RankingsQuery, Void)]()
    var stubbedGetRankingsResult: Results<RankingsPageInfo>!
    func get(rankings query: RankingsQuery) -> Results<RankingsPageInfo> {
        invokedGetRankings = true
        invokedGetRankingsCount += 1
        invokedGetRankingsParameters = (query, ())
        invokedGetRankingsParametersList.append((query, ()))
        return stubbedGetRankingsResult
    }
    var invokedGetScorecard = false
    var invokedGetScorecardCount = 0
    var invokedGetScorecardParameters: (list: Checklist, id: Int?)?
    var invokedGetScorecardParametersList = [(list: Checklist, id: Int?)]()
    var stubbedGetScorecardResult: Scorecard!
    func get(scorecard list: Checklist, user id: Int?) -> Scorecard? {
        invokedGetScorecard = true
        invokedGetScorecardCount += 1
        invokedGetScorecardParameters = (list, id)
        invokedGetScorecardParametersList.append((list, id))
        return stubbedGetScorecardResult
    }
    var invokedGetUser = false
    var invokedGetUserCount = 0
    var invokedGetUserParameters: (id: Int, Void)?
    var invokedGetUserParametersList = [(id: Int, Void)]()
    var stubbedGetUserResult: User!
    func get(user id: Int) -> User {
        invokedGetUser = true
        invokedGetUserCount += 1
        invokedGetUserParameters = (id, ())
        invokedGetUserParametersList.append((id, ()))
        return stubbedGetUserResult
    }
    var invokedGetWhs = false
    var invokedGetWhsCount = 0
    var invokedGetWhsParameters: (id: Int, Void)?
    var invokedGetWhsParametersList = [(id: Int, Void)]()
    var stubbedGetWhsResult: WHS!
    func get(whs id: Int) -> WHS? {
        invokedGetWhs = true
        invokedGetWhsCount += 1
        invokedGetWhsParameters = (id, ())
        invokedGetWhsParametersList.append((id, ()))
        return stubbedGetWhsResult
    }
    var invokedHasChildren = false
    var invokedHasChildrenCount = 0
    var invokedHasChildrenParameters: (id: Int, Void)?
    var invokedHasChildrenParametersList = [(id: Int, Void)]()
    var stubbedHasChildrenResult: Bool! = false
    func hasChildren(whs id: Int) -> Bool {
        invokedHasChildren = true
        invokedHasChildrenCount += 1
        invokedHasChildrenParameters = (id, ())
        invokedHasChildrenParametersList.append((id, ()))
        return stubbedHasChildrenResult
    }
    var invokedHasVisitedChildren = false
    var invokedHasVisitedChildrenCount = 0
    var invokedHasVisitedChildrenParameters: (id: Int, Void)?
    var invokedHasVisitedChildrenParametersList = [(id: Int, Void)]()
    var stubbedHasVisitedChildrenResult: Bool! = false
    func hasVisitedChildren(whs id: Int) -> Bool {
        invokedHasVisitedChildren = true
        invokedHasVisitedChildrenCount += 1
        invokedHasVisitedChildrenParameters = (id, ())
        invokedHasVisitedChildrenParametersList.append((id, ()))
        return stubbedHasVisitedChildrenResult
    }
    var invokedSetBeaches = false
    var invokedSetBeachesCount = 0
    var invokedSetBeachesParameters: (beaches: [PlaceJSON], Void)?
    var invokedSetBeachesParametersList = [(beaches: [PlaceJSON], Void)]()
    func set(beaches: [PlaceJSON]) {
        invokedSetBeaches = true
        invokedSetBeachesCount += 1
        invokedSetBeachesParameters = (beaches, ())
        invokedSetBeachesParametersList.append((beaches, ()))
    }
    var invokedSetCountries = false
    var invokedSetCountriesCount = 0
    var invokedSetCountriesParameters: (countries: [CountryJSON], Void)?
    var invokedSetCountriesParametersList = [(countries: [CountryJSON], Void)]()
    func set(countries: [CountryJSON]) {
        invokedSetCountries = true
        invokedSetCountriesCount += 1
        invokedSetCountriesParameters = (countries, ())
        invokedSetCountriesParametersList.append((countries, ()))
    }
    var invokedSetDivesites = false
    var invokedSetDivesitesCount = 0
    var invokedSetDivesitesParameters: (divesites: [PlaceJSON], Void)?
    var invokedSetDivesitesParametersList = [(divesites: [PlaceJSON], Void)]()
    func set(divesites: [PlaceJSON]) {
        invokedSetDivesites = true
        invokedSetDivesitesCount += 1
        invokedSetDivesitesParameters = (divesites, ())
        invokedSetDivesitesParametersList.append((divesites, ()))
    }
    var invokedSetGolfcourses = false
    var invokedSetGolfcoursesCount = 0
    var invokedSetGolfcoursesParameters: (golfcourses: [PlaceJSON], Void)?
    var invokedSetGolfcoursesParametersList = [(golfcourses: [PlaceJSON], Void)]()
    func set(golfcourses: [PlaceJSON]) {
        invokedSetGolfcourses = true
        invokedSetGolfcoursesCount += 1
        invokedSetGolfcoursesParameters = (golfcourses, ())
        invokedSetGolfcoursesParametersList.append((golfcourses, ()))
    }
    var invokedSetLocations = false
    var invokedSetLocationsCount = 0
    var invokedSetLocationsParameters: (locations: [LocationJSON], Void)?
    var invokedSetLocationsParametersList = [(locations: [LocationJSON], Void)]()
    func set(locations: [LocationJSON]) {
        invokedSetLocations = true
        invokedSetLocationsCount += 1
        invokedSetLocationsParameters = (locations, ())
        invokedSetLocationsParametersList.append((locations, ()))
    }
    var invokedSetLocationPhotos = false
    var invokedSetLocationPhotosCount = 0
    var invokedSetLocationPhotosParameters: (id: Int, info: PhotosInfoJSON)?
    var invokedSetLocationPhotosParametersList = [(id: Int, info: PhotosInfoJSON)]()
    func set(locationPhotos id: Int,
             info: PhotosInfoJSON) {
        invokedSetLocationPhotos = true
        invokedSetLocationPhotosCount += 1
        invokedSetLocationPhotosParameters = (id, info)
        invokedSetLocationPhotosParametersList.append((id, info))
    }
    var invokedSetPhotos = false
    var invokedSetPhotosCount = 0
    var invokedSetPhotosParameters: (page: Int, id: Int?, info: PhotosPageInfoJSON)?
    var invokedSetPhotosParametersList = [(page: Int, id: Int?, info: PhotosPageInfoJSON)]()
    func set(photos page: Int,
             user id: Int?,
             info: PhotosPageInfoJSON) {
        invokedSetPhotos = true
        invokedSetPhotosCount += 1
        invokedSetPhotosParameters = (page, id, info)
        invokedSetPhotosParametersList.append((page, id, info))
    }
    var invokedSetPosts = false
    var invokedSetPostsCount = 0
    var invokedSetPostsParameters: (posts: [PostJSON], Void)?
    var invokedSetPostsParametersList = [(posts: [PostJSON], Void)]()
    func set(posts: [PostJSON]) {
        invokedSetPosts = true
        invokedSetPostsCount += 1
        invokedSetPostsParameters = (posts, ())
        invokedSetPostsParametersList.append((posts, ()))
    }
    var invokedSetRestaurants = false
    var invokedSetRestaurantsCount = 0
    var invokedSetRestaurantsParameters: (restaurants: [RestaurantJSON], Void)?
    var invokedSetRestaurantsParametersList = [(restaurants: [RestaurantJSON], Void)]()
    func set(restaurants: [RestaurantJSON]) {
        invokedSetRestaurants = true
        invokedSetRestaurantsCount += 1
        invokedSetRestaurantsParameters = (restaurants, ())
        invokedSetRestaurantsParametersList.append((restaurants, ()))
    }
    var invokedSetRankings = false
    var invokedSetRankingsCount = 0
    var invokedSetRankingsParameters: (query: RankingsQuery, info: RankingsPageInfoJSON)?
    var invokedSetRankingsParametersList = [(query: RankingsQuery, info: RankingsPageInfoJSON)]()
    func set(rankings query: RankingsQuery,
             info: RankingsPageInfoJSON) {
        invokedSetRankings = true
        invokedSetRankingsCount += 1
        invokedSetRankingsParameters = (query, info)
        invokedSetRankingsParametersList.append((query, info))
    }
    var invokedSetScorecard = false
    var invokedSetScorecardCount = 0
    var invokedSetScorecardParameters: (scorecard: ScorecardWrapperJSON, Void)?
    var invokedSetScorecardParametersList = [(scorecard: ScorecardWrapperJSON, Void)]()
    func set(scorecard: ScorecardWrapperJSON) {
        invokedSetScorecard = true
        invokedSetScorecardCount += 1
        invokedSetScorecardParameters = (scorecard, ())
        invokedSetScorecardParametersList.append((scorecard, ()))
    }
    var invokedSetUncountries = false
    var invokedSetUncountriesCount = 0
    var invokedSetUncountriesParameters: (uncountries: [LocationJSON], Void)?
    var invokedSetUncountriesParametersList = [(uncountries: [LocationJSON], Void)]()
    func set(uncountries: [LocationJSON]) {
        invokedSetUncountries = true
        invokedSetUncountriesCount += 1
        invokedSetUncountriesParameters = (uncountries, ())
        invokedSetUncountriesParametersList.append((uncountries, ()))
    }
    var invokedSetUser = false
    var invokedSetUserCount = 0
    var invokedSetUserParameters: (user: UserJSON, Void)?
    var invokedSetUserParametersList = [(user: UserJSON, Void)]()
    func set(user data: UserJSON) {
        invokedSetUser = true
        invokedSetUserCount += 1
        invokedSetUserParameters = (data, ())
        invokedSetUserParametersList.append((data, ()))
    }
    var invokedSetWhss = false
    var invokedSetWhssCount = 0
    var invokedSetWhssParameters: (whss: [WHSJSON], Void)?
    var invokedSetWhssParametersList = [(whss: [WHSJSON], Void)]()
    func set(whss: [WHSJSON]) {
        invokedSetWhss = true
        invokedSetWhssCount += 1
        invokedSetWhssParameters = (whss, ())
        invokedSetWhssParametersList.append((whss, ()))
    }
    var invokedDeleteUserPhotos = false
    var invokedDeleteUserPhotosCount = 0
    func deleteUserPhotos() {
        invokedDeleteUserPhotos = true
        invokedDeleteUserPhotosCount += 1
    }
    var invokedNotify = false
    var invokedNotifyCount = 0
    var invokedNotifyParameters: (changed: String, info: [AnyHashable: Any])?
    var invokedNotifyParametersList = [(changed: String, info: [AnyHashable: Any])]()
    func notify(observers changed: String,
                info: [AnyHashable: Any]) {
        invokedNotify = true
        invokedNotifyCount += 1
        invokedNotifyParameters = (changed, info)
        invokedNotifyParametersList.append((changed, info))
    }
}
