// @copyright Trollwerks Inc.

import Parchment
import UIKit

final class MyProfileTabsVC: FixedPagingViewController {

    init() {
        let controllers = [
            R.storyboard.about.instantiateInitialViewController(),
            R.storyboard.myPhotos.instantiateInitialViewController(),
            R.storyboard.posts.instantiateInitialViewController()
        ].compactMap { $0 }
        super.init(viewControllers: controllers)

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

private extension MyProfileTabsVC {

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
