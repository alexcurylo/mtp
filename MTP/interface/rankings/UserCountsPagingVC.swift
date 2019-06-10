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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

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
        mtp.loadScorecard(list: model.list,
                          user: model.user.id) { [weak self] _ in
            self?.checkScorecard(fail: .error)
        }
    }

    func checkScorecard(fail state: ContentState) {
        scorecard = data.get(scorecard: model.list, user: model.user.id)
        contentState = scorecard != nil ? .data : state
        viewControllers.forEach {
            ($0 as? UserCountsPageVC)?.refresh()
        }
    }
}

extension UserCountsPagingVC: Injectable {

    typealias Model = (list: Checklist, user: User)

    @discardableResult func inject(model: Model) -> Self {
        return self
    }

    func requireInjections() {
    }
}
