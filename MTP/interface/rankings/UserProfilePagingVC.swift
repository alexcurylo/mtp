// @copyright Trollwerks Inc.

import Parchment

final class UserProfilePagingVC: FixedPagingViewController, ServiceProvider {

    static func profile(model: Model) -> UserProfilePagingVC {

        let controllers: [CountsPageVC] = [
            UserProfilePageVC(model: (model.list, model.user, .visited)),
            UserProfilePageVC(model: (model.list, model.user, .remaining))
        ]

        return UserProfilePagingVC(viewControllers: controllers)
    }

    init(viewControllers: [CountsPageVC]) {
        super.init(viewControllers: viewControllers)

        configure()
    }

    required init?(coder: NSCoder) {
        super.init(viewControllers: [])
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

    func configure() {
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
}

extension UserProfilePagingVC: Injectable {

    typealias Model = (list: Checklist, user: User)

    func inject(model: Model) {
    }

    func requireInjections() {
    }
}
