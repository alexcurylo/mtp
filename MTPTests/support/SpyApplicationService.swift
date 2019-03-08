// @copyright Trollwerks Inc.

@testable import MTP

// swiftlint:disable let_var_whitespace
final class SpyApplicationService: ApplicationService {

    var invokedOpen = false
    var invokedOpenCount = 0
    func open(_ url: URL) {
        invokedOpen = true
        invokedOpenCount += 1
    }
}
