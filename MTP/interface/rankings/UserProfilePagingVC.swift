// @copyright Trollwerks Inc.

import Parchment

final class UserProfilePagingVC: FixedPagingViewController, UserProfilePageDataSource, ServiceProvider {

    var scorecard: Scorecard?
    var contentState: ContentState = .loading

    private let model: Model

    static func profile(model: Model) -> UserProfilePagingVC {

        let controllers: [UserProfilePageVC] = [
            UserProfilePageVC(model: (model.list, model.user, .visited)),
            UserProfilePageVC(model: (model.list, model.user, .remaining))
        ]

        return UserProfilePagingVC(model: model,
                                   viewControllers: controllers)
    }

    init(model: Model,
         viewControllers: [UserProfilePageVC]) {
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
        log.verbose("prepare for \(segue.name)")
        switch segue.identifier {
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

private extension UserProfilePagingVC {

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
            ($0 as? UserProfilePageVC)?.update()
        }
    }
}

extension UserProfilePagingVC: Injectable {

    typealias Model = (list: Checklist, user: User)

    func inject(model: Model) {
    }

    func requireInjections() {
    }
}
