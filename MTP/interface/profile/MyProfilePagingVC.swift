// @copyright Trollwerks Inc.

import Parchment

final class MyProfilePagingVC: FixedPagingViewController, ServiceProvider {

    static var profile: MyProfilePagingVC {
        let controllers = [
            R.storyboard.myAbout.myAbout(),
            R.storyboard.myCounts.myCounts(),
            R.storyboard.myPhotos.myPhotos(),
            R.storyboard.myPosts.myPosts()
        ].compactMap { $0 }

        return MyProfilePagingVC(viewControllers: controllers)
    }

    override init(viewControllers: [UIViewController]) {
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

private extension MyProfilePagingVC {

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
