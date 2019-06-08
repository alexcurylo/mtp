// @copyright Trollwerks Inc.

@testable import MTP

// swiftlint:disable let_var_whitespace large_tuple
final class SpyNotificationService: NotificationService {

    var invokedDebug = false
    var invokedDebugCount = 0
    var invokedDebugParameters: (title: String?, body: String?)?
    var invokedDebugParametersList = [(title: String?, body: String?)]()
    func debug(title: String?,
               body: String?) {
        invokedDebug = true
        invokedDebugCount += 1
        invokedDebugParameters = (title, body)
        invokedDebugParametersList.append((title, body))
    }
    var invokedVisit = false
    var invokedVisitCount = 0
    var invokedVisitParameters: (title: String, body: String, info: Info)?
    var invokedVisitParametersList = [(title: String, body: String, info: Info)]()
    func visit(title: String,
               body: String,
               info: Info) {
        invokedVisit = true
        invokedVisitCount += 1
        invokedVisitParameters = (title, body, info)
        invokedVisitParametersList.append((title, body, info))
    }
    var invokedAuthorizeNotifications = false
    var invokedAuthorizeNotificationsCount = 0
    var stubbedAuthorizeNotificationsThenResult: (Bool, Void)?
    func authorizeNotifications(then: @escaping (Bool) -> Void) {
        invokedAuthorizeNotifications = true
        invokedAuthorizeNotificationsCount += 1
        if let result = stubbedAuthorizeNotificationsThenResult {
            then(result.0)
        }
    }
    var invokedBackground = false
    var invokedBackgroundCount = 0
    var shouldInvokeBackgroundThen = false
    func background(then: @escaping () -> Void) {
        invokedBackground = true
        invokedBackgroundCount += 1
        if shouldInvokeBackgroundThen {
            then()
        }
    }
    var invokedPost = false
    var invokedPostCount = 0
    var invokedPostParameters: (title: String, subtitle: String, body: String, category: String, info: Info)?
    var invokedPostParametersList = [(title: String, subtitle: String, body: String, category: String, info: Info)]()
    func post(title: String,
              subtitle: String,
              body: String,
              category: String,
              info: Info) {
        invokedPost = true
        invokedPostCount += 1
        invokedPostParameters = (title, subtitle, body, category, info)
        invokedPostParametersList.append((title, subtitle, body, category, info))
    }
}
