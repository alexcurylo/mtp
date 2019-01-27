// @copyright Trollwerks Inc.

import Anchorage
import Parchment
import UIKit

final class MyCountsVC: UIViewController {

    @IBOutlet private var pagesHolder: UIView?

    private let pagingVC = RankingPagingVC()

    override func viewDidLoad() {
        super.viewDidLoad()

        gestalt.rankingsFilter = nil

        configurePagesHolder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .standard)
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

    func updateFilter() {
        pagingVC.reloadData()
    }
}

private extension MyCountsVC {

    @IBAction func unwindToCounts(segue: UIStoryboardSegue) {
        log.verbose(segue.name)
    }

    func configurePagesHolder() {
        guard let holder = pagesHolder else { return }

        pagingVC.configure()

        addChild(pagingVC)
        holder.addSubview(pagingVC.view)
        pagingVC.view.edgeAnchors == holder.edgeAnchors
        pagingVC.didMove(toParent: self)

        pagingVC.dataSource = self
        pagingVC.delegate = self
        pagingVC.select(pagingItem: RankingPagingItem.pages[0])
    }

    func update(menu height: CGFloat) {
        pagingVC.update(menu: height)
    }
}

extension MyCountsVC: PagingViewControllerDataSource {

    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>,
                                 viewControllerForIndex index: Int) -> UIViewController {
        let viewController = RankingVC(options: pagingViewController.options)
        viewController.delegate = self
        viewController.set(
            members: RankingPagingItem.pages[index].members,
            filter: gestalt.rankingsFilter)

        let insets = UIEdgeInsets(top: RankingPagingVC.Layout.menuHeight,
                                  left: 0,
                                  bottom: 0,
                                  right: 0)
        viewController.collectionView.contentInset = insets
        viewController.collectionView.scrollIndicatorInsets = insets

        return viewController
    }

    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>,
                                 pagingItemForIndex index: Int) -> T {
        guard let result = RankingPagingItem.pages[index] as? T else {
            fatalError("RankingPagingItem type failure")
        }
        return result
    }

    func numberOfViewControllers<T>(in: PagingViewController<T>) -> Int {
        return RankingPagingItem.pages.count
    }
}

extension MyCountsVC: RankingVCDelegate {

    func didScroll(rankingVC: RankingVC) {
        let height = pagingVC.menuHeight(for: rankingVC.collectionView)
        update(menu: height)
    }
}

extension MyCountsVC: PagingViewControllerDelegate {

    // swiftlint:disable:next function_parameter_count
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>,
                                 isScrollingFromItem currentPagingItem: T,
                                 toItem upcomingPagingItem: T?,
                                 startingViewController: UIViewController,
                                 destinationViewController: UIViewController?,
                                 progress: CGFloat) {
        guard let destinationViewController = destinationViewController as? RankingVC else { return }
        guard let startingViewController = startingViewController as? RankingVC else { return }

        let from = pagingVC.menuHeight(for: startingViewController.collectionView)
        let to = pagingVC.menuHeight(for: destinationViewController.collectionView)
        let height = ((to - from) * abs(progress)) + from
        update(menu: height)
    }
}
