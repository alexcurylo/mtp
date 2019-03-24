// @copyright Trollwerks Inc.

import Anchorage
import Parchment

final class MyCountsVC: UIViewController, ServiceProvider {

    @IBOutlet private var pagesHolder: UIView?

    private let pagingVC = MyCountsPagingVC()
    private let pages = ListPagingItem.pages

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        configurePagesHolder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        hide(navBar: false)
        hide(toolBar: false)
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
        pagingVC.select(pagingItem: pages[0])
    }

    func update(menu height: CGFloat) {
        pagingVC.update(menu: height)
    }
}

extension MyCountsVC: PagingViewControllerDataSource {

    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>,
                                 viewControllerForIndex index: Int) -> UIViewController {
        let pageVC = MyCountsPageVC(model: pages[index].list,
                                    delegate: self)

        let insets = UIEdgeInsets(top: MyCountsPagingVC.Layout.menuHeight,
                                  left: 0,
                                  bottom: 0,
                                  right: 0)
        pageVC.collectionView.contentInset = insets
        pageVC.collectionView.scrollIndicatorInsets = insets

        return pageVC
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

extension MyCountsVC: MyCountsPageVCDelegate {

    func didScroll(myCountsPageVC: MyCountsPageVC) {
        let height = pagingVC.menuHeight(for: myCountsPageVC.collectionView)
        update(menu: height)
    }
}

extension MyCountsVC: PagingViewControllerDelegate {

    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>,
                                 isScrollingFromItem currentPagingItem: T,
                                 toItem upcomingPagingItem: T?,
                                 startingViewController: UIViewController,
                                 destinationViewController: UIViewController?,
                                 progress: CGFloat) {
        guard let destinationViewController = destinationViewController as? MyCountsPageVC else { return }
        guard let startingViewController = startingViewController as? MyCountsPageVC else { return }

        let from = pagingVC.menuHeight(for: startingViewController.collectionView)
        let to = pagingVC.menuHeight(for: destinationViewController.collectionView)
        let height = ((to - from) * abs(progress)) + from
        update(menu: height)
    }
}

extension MyCountsVC: Injectable {

    typealias Model = ()

    func inject(model: Model) {
    }

    func requireInjections() {
        pagesHolder.require()
    }
}
