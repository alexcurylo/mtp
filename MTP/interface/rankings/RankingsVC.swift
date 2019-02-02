// @copyright Trollwerks Inc.

import Anchorage
import Parchment

final class RankingsVC: UIViewController, ServiceProvider {

    @IBOutlet private var pagesHolder: UIView?

    private let pagingVC = RankingsPagingVC()
    private let pages = ListPagingItem.pages

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
        case R.segue.rankingsVC.showFilter.identifier,
             R.segue.rankingsVC.showSearch.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }

    func updateFilter() {
        pagingVC.reloadData()
    }
}

private extension RankingsVC {

    @IBAction func unwindToRankings(segue: UIStoryboardSegue) {
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
        pagingVC.select(pagingItem: ListPagingItem.pages[0])
    }

    func update(menu height: CGFloat) {
        pagingVC.update(menu: height)
    }
}

extension RankingsVC: PagingViewControllerDataSource {

    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>,
                                 viewControllerForIndex index: Int) -> UIViewController {
        let viewController = RankingsPageVC(options: pagingViewController.options)
        viewController.delegate = self
        viewController.set(list: pages[index].list)

        let insets = UIEdgeInsets(top: RankingsPagingVC.Layout.menuHeight,
                                  left: 0,
                                  bottom: 0,
                                  right: 0)
        viewController.collectionView.contentInset = insets
        viewController.collectionView.scrollIndicatorInsets = insets

        return viewController
    }

    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>,
                                 pagingItemForIndex index: Int) -> T {
        guard let result = pages[index] as? T else {
            fatalError("ListPagingItem type failure")
        }
        return result
    }

    func numberOfViewControllers<T>(in: PagingViewController<T>) -> Int {
        return pages.count
    }
}

extension RankingsVC: RankingsPageVCDelegate {

    func didScroll(rankingsPageVC: RankingsPageVC) {
        let height = pagingVC.menuHeight(for: rankingsPageVC.collectionView)
        update(menu: height)
    }
}

extension RankingsVC: PagingViewControllerDelegate {

    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>,
                                 isScrollingFromItem currentPagingItem: T,
                                 toItem upcomingPagingItem: T?,
                                 startingViewController: UIViewController,
                                 destinationViewController: UIViewController?,
                                 progress: CGFloat) {
        guard let destinationViewController = destinationViewController as? RankingsPageVC else { return }
        guard let startingViewController = startingViewController as? RankingsPageVC else { return }

        let from = pagingVC.menuHeight(for: startingViewController.collectionView)
        let to = pagingVC.menuHeight(for: destinationViewController.collectionView)
        let height = ((to - from) * abs(progress)) + from
        update(menu: height)
    }
}
