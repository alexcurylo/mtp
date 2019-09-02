// @copyright Trollwerks Inc.

import XCTest

extension XCTestCase {

    func show(root vc: UIViewController) -> UIWindow {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.isHidden = false
        window.rootViewController = vc
        XCTAssertNotNil(vc.view)
        // as of Xcode 10.3 calls willAppear but not didAppear
        vc.viewDidAppear(false)

        return window
    }

    func show(nav vc: UIViewController) -> UIWindow {
        let nav = UINavigationController(rootViewController: vc)
        nav.isToolbarHidden = false
        nav.isNavigationBarHidden = false
        return show(root: nav)
    }

    func hide(window: UIWindow) {
        guard let vc = window.rootViewController else { return }

        window.rootViewController = nil
        // as of Xcode 10.3 calls willDisppear but not didDisappear until teardown
        vc.viewDidDisappear(false)
    }
}
