// @copyright Trollwerks Inc.

import Anchorage
import Parchment

/// Base class for displaying visit counts
class CountsPageVC: UIViewController {

    // Overridable

    /// Whether counts are editable
    var isEditable: Bool { return false }
    /// Places to display
    var places: [PlaceInfo] { return [] }
    /// Places that have been visited
    var visited: [Int] { return [] }

    // Available to subclasses

    /// List displayed
    let checklist: Checklist

    /// Container of count items
    let collectionView: UICollectionView = {
        // swiftlint:disable:previous closure_body_length
        let flow = UICollectionViewFlowLayout()
        flow.minimumLineSpacing = Layout.cellSpacing
        flow.sectionInset = Layout.sectionInsets
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: flow)
        collectionView.backgroundColor = .clear
        collectionView.backgroundView = UIView { $0.backgroundColor = .clear }

        collectionView.register(
            CountCellItem.self,
            forCellWithReuseIdentifier: CountCellItem.reuseIdentifier)
        collectionView.register(
            CountCellGroup.self,
            forCellWithReuseIdentifier: CountCellGroup.reuseIdentifier)
        collectionView.register(
            CountSectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CountSectionHeader.reuseIdentifier)
        collectionView.register(
            CountInfoHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CountInfoHeader.reuseIdentifier)

        return collectionView
    }()

    private let infoSection = 0
    private var showsInfo: Bool { return isEditable }

    private enum Layout {
        static let headerHeight = CGFloat(25)
        static let unHeaderHeight = CGFloat(40)
        static let hotelHeaderHeight = CGFloat(52)
        static let lineHeight = CGFloat(32)
        static let margin = CGFloat(8)
        static let collectionInsets = UIEdgeInsets(top: margin,
                                                   left: margin,
                                                   bottom: 0,
                                                   right: 0)
        static let sectionInsets = UIEdgeInsets(top: 0,
                                                left: 0,
                                                bottom: margin,
                                                right: 0)
        static let cellSpacing = CGFloat(0)
    }

    // swiftlint:disable:next implicitly_unwrapped_optional
    private var viewModel: CountsViewModel!

    private var brandsObserver: Observer?

    /// Construction by injection
    /// - Parameter model: Injected model
    init(model: Checklist) {
        checklist = model
        super.init(nibName: nil, bundle: nil)

        build()
        configure()
    }

    /// :nodoc:
    required init?(coder: NSCoder) {
        return nil
    }

    /// Refresh collection view on layout
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        collectionView.collectionViewLayout.invalidateLayout()
    }

    /// Configure for display
    func configure() {
        view.addSubview(collectionView)
        collectionView.edgeAnchors == view.edgeAnchors + Layout.collectionInsets
        collectionView.dataSource = self
        collectionView.delegate = self

        update()
        observe()
    }

    /// Update UI state
    func update() {
        if viewModel.hierarchy != checklist.hierarchy {
            build()
        }
        viewModel.sort(places: places, visited: visited)
        collectionView.reloadData()
    }

    /// Set up data change observations
    func observe() {
        // to be overridden

        guard brandsObserver == nil else { return }

        brandsObserver = data.observer(of: .brands) { [weak self] _ in
            guard let self = self else { return }
            if self.viewModel.hierarchy == .brandRegionCountry {
                self.build()
                self.update()
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CountsPageVC: UICollectionViewDelegateFlowLayout {

    /// Provide header size
    /// - Parameters:
    ///   - collectionView: Collection
    ///   - collectionViewLayout: Collection layout
    ///   - section: Section index
    /// - Returns: Size
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        let height: CGFloat
        switch (section, showsInfo, checklist) {
        case (infoSection, true, .uncountries):
            height = Layout.unHeaderHeight
        case (infoSection, true, .hotels):
            height = Layout.hotelHeaderHeight
        case (infoSection, true, _):
            height = Layout.headerHeight
        default:
            height = Layout.lineHeight
        }
        return CGSize(width: collectionView.frame.width,
                      height: height)
    }

    /// Provide cell size
    /// - Parameters:
    ///   - collectionView: Collection
    ///   - collectionViewLayout: Collection layout
    ///   - indexPath: Cell path
    /// - Returns: Size
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width,
                      height: Layout.lineHeight)
    }
}

// MARK: - UICollectionViewDataSource

extension CountsPageVC: UICollectionViewDataSource {

    /// Provide header
    /// - Parameters:
    ///   - collectionView: Collection
    ///   - kind: Expect header
    ///   - indexPath: Item path
    /// - Returns: CountSectionHeader
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let modelPath: IndexPath
        switch (indexPath.section, showsInfo) {
        case (infoSection, true):
            return infoHeader(at: indexPath)
        case (_, true):
            modelPath = IndexPath(row: indexPath.row,
                                  section: indexPath.section - 1)
        default:
            modelPath = IndexPath(row: indexPath.row,
                                  section: indexPath.section)
        }
        return countHeader(at: indexPath,
                           model: modelPath)
    }

    /// :nodoc:
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.sectionCount + (showsInfo ? 1 : 0)
    }

    /// Section items count
    /// - Parameters:
    ///   - collectionView: Collection
    ///   - section: Index
    /// - Returns: Item count
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        switch (section, showsInfo) {
        case (infoSection, true):
            return 0
        case (_, true):
            return viewModel.itemCount(section: section - 1)
        default:
            return viewModel.itemCount(section: section)
        }
    }

    /// Provide cell
    /// - Parameters:
    ///   - collectionView: Collection
    ///   - indexPath: Index path
    /// - Returns: CountCellGroup or CountCellItem
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let modelPath: IndexPath
        if showsInfo {
            modelPath = IndexPath(row: indexPath.row,
                                  section: indexPath.section - 1)
        } else {
            modelPath = indexPath
        }

        let itemCell = cell(at: indexPath,
                            model: modelPath)
        return itemCell
    }
}

// MARK: - CountInfoHeaderDelegate

extension CountsPageVC: CountInfoHeaderDelegate {

    /// :nodoc:
    func toggle(brand: Bool) {
        update()
    }
}

// MARK: - CountSectionHeaderDelegate

extension CountsPageVC: CountSectionHeaderDelegate {

     /// :nodoc:
    func toggle(section: String) {
        viewModel.toggle(section: section)
        collectionView.reloadData()
    }
}

// MARK: - CountCellGroupDelegate

extension CountsPageVC: CountCellGroupDelegate {

    /// :nodoc:
    func toggle(section: String,
                group: String) {
        viewModel.toggle(section: section,
                         group: group)
        collectionView.reloadData()
    }

    /// :nodoc:
    func toggle(section: String,
                group: String,
                subgroup: String) {
        viewModel.toggle(section: section,
                         group: group,
                         subgroup: subgroup)
        collectionView.reloadData()
    }
}

// MARK: - Private

private extension CountsPageVC {

    func build() {
        let builder = CountsViewModelBuilder(checklist: checklist,
                                             isEditable: isEditable)
        viewModel = builder.build()
    }

    func infoHeader(at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CountInfoHeader.reuseIdentifier,
            for: indexPath)

        if let header = view as? CountInfoHeader {
             header.delegate = self
             header.inject(list: checklist)
        }

        return view
    }

    func countHeader(at viewPath: IndexPath,
                     model modelPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CountSectionHeader.reuseIdentifier,
            for: viewPath)

        if let header = view as? CountSectionHeader {
            header.delegate = self
            let model = viewModel.header(section: modelPath.section)
            header.inject(model: model)

            UICountsPage.section(viewPath.section).expose(item: header)
        }

        return view
    }

    func cell(at viewPath: IndexPath,
              model modelPath: IndexPath) -> UICollectionViewCell {
        let info = viewModel.cell(info: modelPath)
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: info.identifier,
            for: viewPath
        )

        switch cell {
        case let grouper as CountCellGroup:
            grouper.delegate = self
            grouper.inject(model: info.model)
        case let counter as CountCellItem:
            counter.inject(model: info.model)
        default:
            break
        }

        return cell
    }
}
