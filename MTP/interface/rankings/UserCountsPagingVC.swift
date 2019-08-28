// @copyright Trollwerks Inc.

import Parchment

/// Displays user visit tabs
final class UserCountsPagingVC: FixedPagingViewController, UserCountsPageDataSource {

    /// Injected dependencies
    typealias Model = (list: Checklist, user: User)

    fileprivate enum Page: Int {

        case visited
        case remaining
   }

    /// Scorecard to display
    var scorecard: Scorecard?
    /// Content state to display
    var contentState: ContentState = .loading

    private let model: Model

    /// Provide pages container
    ///
    /// - Parameter model: Model to populate pages
    /// - Returns: UserCountsPagingVC
    static func profile(model: Model) -> UserCountsPagingVC {

        let controllers: [UserCountsPageVC] = [
            UserCountsPageVC(model: (model.list, model.user, .visited)),
            UserCountsPageVC(model: (model.list, model.user, .remaining))
        ]

        return UserCountsPagingVC(model: model,
                                  viewControllers: controllers)
    }

    /// Construction by injection
    ///
    /// - Parameters:
    ///   - model: Injected model
    ///   - viewControllers: Controllers
    init(model: Model,
         viewControllers: [UserCountsPageVC]) {
        self.model = model
        super.init(viewControllers: viewControllers)

        setupLayout()
        setupContent()
        viewControllers.forEach { $0.dataSource = self }
    }

    /// Unsupported coding constructor
    ///
    /// - Parameter coder: An unarchiver object.
    required init?(coder: NSCoder) {
        return nil
    }

    /// Prepare for reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        expose()
    }

    /// Actions to take after reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        report(screen: "User Counts")
    }

    /// Provide cell
    ///
    /// - Parameters:
    ///   - collectionView: Collection
    ///   - indexPath: Index path
    /// - Returns: Exposed cell
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView,
                                        cellForItemAt: indexPath)
        expose(view: collectionView,
               path: indexPath,
               cell: cell)
        return cell
    }
}

// MARK: - Private

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
        net.loadScorecard(list: model.list,
                          user: model.user.userId) { [weak self] _ in
            self?.checkScorecard(fail: .error)
        }
    }

    func checkScorecard(fail state: ContentState) {
        scorecard = data.get(scorecard: model.list,
                             user: model.user.userId)
        contentState = scorecard != nil ? .data : state
        viewControllers.forEach {
            ($0 as? UserCountsPageVC)?.refresh()
        }
    }
}

// MARK: - Exposing

extension UserCountsPagingVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        UIUserCountsPaging.menu.expose(item: collectionView)
    }
}

// MARK: - CollectionCellExposing

extension UserCountsPagingVC: CollectionCellExposing {

    /// Expose cell to UI tests
    ///
    /// - Parameters:
    ///   - view: Collection
    ///   - path: Index path
    ///   - cell: Cell
    func expose(view: UICollectionView,
                path: IndexPath,
                cell: UICollectionViewCell) {
        guard let page = Page(rawValue: path.item) else { return }

        switch page {
        case .remaining:
            UIUserCountsPaging.remaining.expose(item: cell)
        case .visited:
            UIUserCountsPaging.visited.expose(item: cell)
        }
    }
}
