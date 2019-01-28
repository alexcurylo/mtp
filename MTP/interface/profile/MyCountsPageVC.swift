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

    typealias Region = String
    typealias Country = String

    private var list: Checklist?

    private var regions: [Region] = []
    private var regionsPlaces: [Region: [PlaceInfo]] = [:]
    private var regionsVisited: [Region: Int] = [:]
    private var regionsExpanded: [Region: Bool] = [:]

    private var countries: [Region: [Country]] = [:]
    private var countriesPlaces: [Region: [Country: [PlaceInfo]]] = [:]
    private var countriesVisited: [Region: [Country: Int]] = [:]
    //private var countriesExpanded: [Region: [Country: Bool]] = [:]

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
        count(places: list.places,
              visits: list.visits)

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
            header.delegate = self
            let key = regions[indexPath.section]
            header.set(key: key,
                       count: regionsPlaces[key]?.count ?? 0,
                       visited: regionsVisited[key, default: 0],
                       isExpanded: regionsExpanded[key, default: false])
        }

        return view
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return regions.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        let key = regions[section]
        guard let isExpanded = regionsExpanded[key],
           isExpanded == true,
           let regionPlaces = regionsPlaces[key],
           let list = list else {
            return 0
        }

        switch list.hierarchy {
        case .regionSubgrouped:
            fallthrough
        case .country:
            let regionCountries = countries[key]?.count ?? 0
            return regionPlaces.count + regionCountries
        case .region,
             .regionSubtitled:
            return regionPlaces.count
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CountCell.reuseIdentifier,
            for: indexPath)

        if let count = cell as? CountCell,
           let list = list,
           let regionPlaces = regionsPlaces[regions[indexPath.section]] {
            let place = regionPlaces[indexPath.row]
            count.set(title: place.placeName,
                      subtitle: list.isSubtitled ? place.placeCountry : "",
                      list: list,
                      id: place.placeId,
                      isLast: indexPath.row == regionPlaces.count - 1)
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
        if let isExpanded = regionsExpanded[key],
           isExpanded == true {
            regionsExpanded[key] = false
        } else {
            regionsExpanded[key] = true
        }
        collectionView.reloadData()
    }
}

private extension MyCountsPageVC {

    func count(places: [PlaceInfo],
               visits: [Int]) {
        let groupCountries = list?.isGrouped ?? false
        regionsExpanded = [:]
        regionsVisited = [:]
        countries = [:]
        countriesPlaces = [:]
        countriesVisited = [:]
        //countriesExpanded = [:]

        regionsPlaces = Dictionary(grouping: places) { $0.placeRegion }
        regions = regionsPlaces.keys.sorted()
        for (region, places) in regionsPlaces {
            let regionPlaces = places.sorted { $0.placeName < $1.placeName }
            regionsPlaces[region] = regionPlaces
            let regionVisited = regionPlaces.reduce(0) {
                $0 + (visits.contains($1.placeId) ? 1 : 0)
            }
            regionsVisited[region] = regionVisited

            if !groupCountries { continue }

            //countriesExpanded[region] = [:]
            let countryPlaces = Dictionary(grouping: regionPlaces) { $0.placeCountry }
            countriesPlaces[region] = countryPlaces
            countries[region] = countryPlaces.keys.sorted()
            var countryVisits: [Country: Int] = [:]
            for (country, subplaces) in countryPlaces {
                let countryVisited = subplaces.reduce(0) {
                    $0 + (visits.contains($1.placeId) ? 1 : 0)
                }
                countryVisits[country] = countryVisited
            }
            countriesVisited[region] = countryVisits
        }
    }
}
