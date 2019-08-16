// @copyright Trollwerks Inc.

import Anchorage
import Parchment

/// Displays logged in user visit counts
final class MyCountsVC: UIViewController, ServiceProvider {

    @IBOutlet private var pagesHolder: UIView?

    private let pagingVC = MyCountsPagingVC()
    private let pages = ListPagingItem.pages

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        configurePagesHolder()
    }
}

// MARK: - Private

private extension MyCountsVC {

    @IBAction func unwindToCounts(segue: UIStoryboardSegue) { }

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

// MARK: - PagingViewControllerDataSource

extension MyCountsVC: PagingViewControllerDataSource {

    /// Create page by index
    ///
    /// - Parameters:
    ///   - pagingViewController: Page holder
    ///   - index: Index
    /// - Returns: View controller
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>,
                                 viewControllerForIndex index: Int) -> UIViewController {
        let pageVC = MyCountsPageVC(model: (pages[index].list, self))

        let insets = UIEdgeInsets(top: MyCountsPagingVC.Layout.menuHeight,
                                  left: 0,
                                  bottom: 0,
                                  right: 0)
        pageVC.collectionView.contentInset = insets
        pageVC.collectionView.scrollIndicatorInsets = insets

        return pageVC
    }

    /// Provide Parchment with typed page
    ///
    /// - Parameters:
    ///   - pagingViewController: Page holder
    ///   - index: Index
    /// - Returns: Typed view controller
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>,
                                 pagingItemForIndex index: Int) -> T {
        guard let result = pages[index] as? T else {
            fatalError("ListPagingItem type failure")
        }
        return result
    }

    /// Provide Parchment with page count
    ///
    /// - Parameter in: Page holder
    /// - Returns: Page count
    func numberOfViewControllers<T>(in: PagingViewController<T>) -> Int {
        return pages.count
    }
}

extension MyCountsVC: MyCountsPageVCDelegate {

    /// Scroll notification
    ///
    /// - Parameter rankingsPageVC: Scrollee
    func didScroll(myCountsPageVC: MyCountsPageVC) {
        let height = pagingVC.menuHeight(for: myCountsPageVC.collectionView)
        update(menu: height)
    }
}

extension MyCountsVC: PagingViewControllerDelegate {

    /// Handle page change progress
    ///
    /// - Parameters:
    ///   - pagingViewController: Page holder
    ///   - currentPagingItem: Current typed page item
    ///   - upcomingPagingItem: Next typed page item
    ///   - startingViewController: Start view controller
    ///   - destinationViewController: Finish view controller
    ///   - progress: Float
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

// MARK: - Injectable

extension MyCountsVC: Injectable {

    /// Injected dependencies
    typealias Model = ()

    /// Handle dependency injection
    ///
    /// - Parameter model: Dependencies
    /// - Returns: Chainable self
    @discardableResult func inject(model: Model) -> Self {
        return self
    }

    /// Enforce dependency injection
    func requireInjections() {
        pagesHolder.require()
    }
}
