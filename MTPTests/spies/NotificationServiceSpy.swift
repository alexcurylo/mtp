// @copyright Trollwerks Inc.

@testable import MTP

// generated by https://github.com/seanhenry/SwiftMockGeneratorForXcode
// swiftlint:disable all

final class NotificationServiceSpy: NotificationService {
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
    var invokedSetItem = false
    var invokedSetItemCount = 0
    var invokedSetItemParameters: (item: Checklist.Item, visited: Bool)?
    var invokedSetItemParametersList = [(item: Checklist.Item, visited: Bool)]()
    var stubbedSetItemThenResult: (Result<Bool, String>, Void)?
    func set(item: Checklist.Item,
    visited: Bool,
    then: @escaping Completion) {
        invokedSetItem = true
        invokedSetItemCount += 1
        invokedSetItemParameters = (item, visited)
        invokedSetItemParametersList.append((item, visited))
        if let result = stubbedSetItemThenResult {
            then(result.0)
        }
    }
    var invokedSetItems = false
    var invokedSetItemsCount = 0
    var invokedSetItemsParameters: (items: [Checklist.Item], visited: Bool)?
    var invokedSetItemsParametersList = [(items: [Checklist.Item], visited: Bool)]()
    var stubbedSetItemsThenResult: (Result<Bool, String>, Void)?
    func set(items: [Checklist.Item],
    visited: Bool,
    then: @escaping Completion) {
        invokedSetItems = true
        invokedSetItemsCount += 1
        invokedSetItemsParameters = (items, visited)
        invokedSetItemsParametersList.append((items, visited))
        if let result = stubbedSetItemsThenResult {
            then(result.0)
        }
    }
    var invokedAsk = false
    var invokedAskCount = 0
    var invokedAskParameters: (question: String, Void)?
    var invokedAskParametersList = [(question: String, Void)]()
    var stubbedAskThenResult: (Bool, Void)?
    func ask(question: String,
    then: @escaping (Bool) -> Void) {
        invokedAsk = true
        invokedAskCount += 1
        invokedAskParameters = (question, ())
        invokedAskParametersList.append((question, ()))
        if let result = stubbedAskThenResult {
            then(result.0)
        }
    }
    var invokedCheckPending = false
    var invokedCheckPendingCount = 0
    func checkPending() {
        invokedCheckPending = true
        invokedCheckPendingCount += 1
    }
    var invokedNotify = false
    var invokedNotifyCount = 0
    var invokedNotifyParameters: (mappable: Mappable, triggered: Date)?
    var invokedNotifyParametersList = [(mappable: Mappable, triggered: Date)]()
    var stubbedNotifyThenResult: (Result<Bool, String>, Void)?
    func notify(mappable: Mappable,
    triggered: Date,
    then: @escaping Completion) {
        invokedNotify = true
        invokedNotifyCount += 1
        invokedNotifyParameters = (mappable, triggered)
        invokedNotifyParametersList.append((mappable, triggered))
        if let result = stubbedNotifyThenResult {
            then(result.0)
        }
    }
    var invokedCongratulateItem = false
    var invokedCongratulateItemCount = 0
    var invokedCongratulateItemParameters: (item: Checklist.Item, Void)?
    var invokedCongratulateItemParametersList = [(item: Checklist.Item, Void)]()
    func congratulate(item: Checklist.Item) {
        invokedCongratulateItem = true
        invokedCongratulateItemCount += 1
        invokedCongratulateItemParameters = (item, ())
        invokedCongratulateItemParametersList.append((item, ()))
    }
    var invokedCongratulateMappable = false
    var invokedCongratulateMappableCount = 0
    var invokedCongratulateMappableParameters: (mappable: Mappable, Void)?
    var invokedCongratulateMappableParametersList = [(mappable: Mappable, Void)]()
    func congratulate(mappable: Mappable) {
        invokedCongratulateMappable = true
        invokedCongratulateMappableCount += 1
        invokedCongratulateMappableParameters = (mappable, ())
        invokedCongratulateMappableParametersList.append((mappable, ()))
    }
    var invokedPostInfo = false
    var invokedPostInfoCount = 0
    var invokedPostInfoParameters: (title: String?, body: String?)?
    var invokedPostInfoParametersList = [(title: String?, body: String?)]()
    func postInfo(title: String?,
    body: String?) {
        invokedPostInfo = true
        invokedPostInfoCount += 1
        invokedPostInfoParameters = (title, body)
        invokedPostInfoParametersList.append((title, body))
    }
    var invokedPostVisit = false
    var invokedPostVisitCount = 0
    var invokedPostVisitParameters: (title: String, body: String, info: Info)?
    var invokedPostVisitParametersList = [(title: String, body: String, info: Info)]()
    func postVisit(title: String,
    body: String,
    info: Info) {
        invokedPostVisit = true
        invokedPostVisitCount += 1
        invokedPostVisitParameters = (title, body, info)
        invokedPostVisitParametersList.append((title, body, info))
    }
    var invokedPost = false
    var invokedPostCount = 0
    var invokedPostParameters: (error: String, Void)?
    var invokedPostParametersList = [(error: String, Void)]()
    func post(error: String) {
        invokedPost = true
        invokedPostCount += 1
        invokedPostParameters = (error, ())
        invokedPostParametersList.append((error, ()))
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
    var invokedPostTitle = false
    var invokedPostTitleCount = 0
    var invokedPostTitleParameters: (title: String, subtitle: String, body: String, category: String, info: Info)?
    var invokedPostTitleParametersList = [(title: String, subtitle: String, body: String, category: String, info: Info)]()
    func post(title: String,
    subtitle: String,
    body: String,
    category: String,
    info: Info) {
        invokedPostTitle = true
        invokedPostTitleCount += 1
        invokedPostTitleParameters = (title, subtitle, body, category, info)
        invokedPostTitleParametersList.append((title, subtitle, body, category, info))
    }
    var invokedModalSuccess = false
    var invokedModalSuccessCount = 0
    var invokedModalSuccessParameters: (success: String, Void)?
    var invokedModalSuccessParametersList = [(success: String, Void)]()
    func modal(success: String) {
        invokedModalSuccess = true
        invokedModalSuccessCount += 1
        invokedModalSuccessParameters = (success, ())
        invokedModalSuccessParametersList.append((success, ()))
    }
    var invokedModalInfo = false
    var invokedModalInfoCount = 0
    var invokedModalInfoParameters: (info: String, Void)?
    var invokedModalInfoParametersList = [(info: String, Void)]()
    func modal(info: String) {
        invokedModalInfo = true
        invokedModalInfoCount += 1
        invokedModalInfoParameters = (info, ())
        invokedModalInfoParametersList.append((info, ()))
    }
    var invokedModalError = false
    var invokedModalErrorCount = 0
    var invokedModalErrorParameters: (error: String, Void)?
    var invokedModalErrorParametersList = [(error: String, Void)]()
    func modal(error: String) {
        invokedModalError = true
        invokedModalErrorCount += 1
        invokedModalErrorParameters = (error, ())
        invokedModalErrorParametersList.append((error, ()))
    }
    var invokedModalFailure = false
    var invokedModalFailureCount = 0
    var invokedModalFailureParameters: (failure: NetworkError, operation: String)?
    var invokedModalFailureParametersList = [(failure: NetworkError, operation: String)]()
    var stubbedModalFailureResult: String! = ""
    func modal(failure: NetworkError,
    operation: String) -> String {
        invokedModalFailure = true
        invokedModalFailureCount += 1
        invokedModalFailureParameters = (failure, operation)
        invokedModalFailureParametersList.append((failure, operation))
        return stubbedModalFailureResult
    }
    var invokedDismissModal = false
    var invokedDismissModalCount = 0
    func dismissModal() {
        invokedDismissModal = true
        invokedDismissModalCount += 1
    }
    var invokedMessage = false
    var invokedMessageCount = 0
    var invokedMessageParameters: (error: String, Void)?
    var invokedMessageParametersList = [(error: String, Void)]()
    func message(error: String) {
        invokedMessage = true
        invokedMessageCount += 1
        invokedMessageParameters = (error, ())
        invokedMessageParametersList.append((error, ()))
    }
    var invokedUnimplemented = false
    var invokedUnimplementedCount = 0
    func unimplemented() {
        invokedUnimplemented = true
        invokedUnimplementedCount += 1
    }
}
