// @copyright Trollwerks Inc.

import Anchorage
import Parchment
import UIKit

protocol MyCountsPageVCDelegate: AnyObject {

    func didScroll(myCountsPageVC: MyCountsPageVC)
}

final class MyCountsPageVC: UIViewController {

    private enum Layout {
        static let headerHeight = CGFloat(32)
        static let margin = CGFloat(8)
        static let collectionInsets = UIEdgeInsets(top: 0,
                                                   left: margin,
                                                   bottom: 0,
                                                   right: 0)
        static let sectionInsets = UIEdgeInsets(top: 0,
                                                left: 0,
                                                bottom: margin,
                                                right: 0)
        static let cellHeight = CGFloat(51)
        static let cellSpacing = CGFloat(0)
    }

    let collectionView: UICollectionView = {
        let flow = UICollectionViewFlowLayout()
        flow.minimumLineSpacing = Layout.cellSpacing
        flow.sectionInset = Layout.sectionInsets
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: flow)
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    weak var delegate: MyCountsPageVCDelegate?

    private var list: Checklist?
    private var groups: [String: [PlaceInfo]] = [:]
    private var sections: [String] = []
    private var expanded: [String: Bool] = [:]
    private var visited: [String: Int] = [:]

    init(options: PagingOptions) {
        super.init(nibName: nil, bundle: nil)

        view.addSubview(collectionView)
        collectionView.edgeAnchors == view.edgeAnchors + Layout.collectionInsets

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            CountCell.self,
            forCellWithReuseIdentifier: CountCell.reuseIdentifier)
        collectionView.register(
            CountHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CountHeader.reuseIdentifier)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    func set(list: Checklist) {
        self.list = list
        let places = list.places
        groups = Dictionary(grouping: places) { $0.placeRegion }
        sections = groups.keys.sorted()
        expanded = [:]
        visited = [:]

        collectionView.reloadData()
        observe()
    }
}

extension MyCountsPageVC: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width,
                      height: Layout.headerHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width,
                      height: Layout.cellHeight)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.didScroll(myCountsPageVC: self)
    }
}

extension MyCountsPageVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CountHeader.reuseIdentifier,
            for: indexPath)

        if let header = view as? CountHeader {
            let key = sections[indexPath.section]
            let count: Int
            let visits: Int
            if let group = groups[key],
               let list = list {
                count = group.count
                if let visit = visited[key] {
                    visits = visit
                } else {
                    let visitList = list.visits
                    let visit = group.reduce(0) {
                        $0 + (visitList.contains($1.placeId) ? 1 : 0)
                    }
                    visits = visit
                    visited[key] = visit
                }
            } else {
                count = 0
                visits = 0
            }

            header.set(key: key,
                       count: count,
                       visited: visits,
                       isExpanded: expanded[key] ?? false)
            header.delegate = self
        }

        return view
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        let key = sections[section]
        if let isExpanded = expanded[key],
           isExpanded == true,
           let group = groups[key] {
            return group.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CountCell.reuseIdentifier,
            for: indexPath)

        if let count = cell as? CountCell,
           let list = list,
           let group = groups[sections[indexPath.section]] {
            let place = group[indexPath.row]
            count.set(name: place.placeName,
                      list: list,
                      id: place.placeId,
                      isLast: indexPath.row == group.count - 1)
        }

        return cell
    }

    func observe() {
        // checklists
        // places
    }
}

extension MyCountsPageVC: CountHeaderDelegate {

    func toggle(section key: String) {
        if let isExpanded = expanded[key],
           isExpanded == true {
            expanded[key] = false
        } else {
            expanded[key] = true
        }
        collectionView.reloadData()
    }
}
