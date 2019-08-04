// @copyright Trollwerks Inc.

import Parchment

final class UserCountsPagingVC: FixedPagingViewController, UserCountsPageDataSource, ServiceProvider {

    var scorecard: Scorecard?
    var contentState: ContentState = .loading

    private let model: Model

    static func profile(model: Model) -> UserCountsPagingVC {

        let controllers: [UserCountsPageVC] = [
            UserCountsPageVC(model: (model.list, model.user, .visited)),
            UserCountsPageVC(model: (model.list, model.user, .remaining))
        ]

        return UserCountsPagingVC(model: model,
                                  viewControllers: controllers)
    }

    init(model: Model,
         viewControllers: [UserCountsPageVC]) {
        self.model = model
        super.init(viewControllers: viewControllers)

        setupLayout()
        setupContent()
        viewControllers.forEach { $0.dataSource = self }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Instrument and inject navigation
    ///
    /// - Parameters:
    ///   - segue: Navigation action
    ///   - sender: Action originator
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

private extension UserCountsPagingVC {

    func setupLayout() {
        menuItemSize = .sizeToFit(minWidth: 50, height: 38)
        menuBackgroundColor = .clear

        font = Avenir.heavy.of(size: 16)
        selectedFont = Avenir.heavy.of(size: 16)
        textColor = .white
        selectedTextColor = .white
        indicatorColor = .white

        menuInteraction = .none
        indicatorOptions = .visible(
            height: 4,
            zIndex: .max,
            spacing: .zero,
            insets: .zero)
    }

    func setupContent() {
        checkScorecard(fail: .loading)
        net.loadScorecard(list: model.list,
                          user: model.user.userId) { [weak self] _ in
            self?.checkScorecard(fail: .error)
        }
    }

    func checkScorecard(fail state: ContentState) {
        scorecard = data.get(scorecard: model.list,
                             user: model.user.userId)
        contentState = scorecard != nil ? .data : state
        viewControllers.forEach {
            ($0 as? UserCountsPageVC)?.refresh()
        }
    }
}

extension UserCountsPagingVC: Injectable {

    /// Injected dependencies
    typealias Model = (list: Checklist, user: User)

    /// Handle dependency injection
    ///
    /// - Parameter model: Dependencies
    /// - Returns: Chainable self
    @discardableResult func inject(model: Model) -> Self {
        return self
    }

    /// Enforce dependency injection
    func requireInjections() {
    }
}
