// @copyright Trollwerks Inc.

import Anchorage
import MapKit

/// Annotation view for a single place
final class MappableAnnotationView: MKMarkerAnnotationView, MappingAnnotationView, ServiceProvider {

    static let twoLineCalloutHeight = CGFloat(365)

    private static var identifier = typeName

    /// Register view type
    /// - Parameter view: Map view
    static func register(view: MKMapView) {
        view.register(self, forAnnotationViewWithReuseIdentifier: identifier)
    }

    /// Factory method for view
    /// - Parameters:
    ///   - map: Map view
    ///   - annotation: Place
    /// - Returns: MappableAnnotationView
    static func view(on map: MKMapView,
                     for annotation: MappablesAnnotation) -> MKAnnotationView {
        let view = map.dequeueReusableAnnotationView(
            withIdentifier: MappableAnnotationView.identifier,
            for: annotation
        )

        view.annotation = annotation
        view.canShowCallout = true

        return view
    }

    private enum Layout {
        static let width = CGFloat(260)
        static let imageSize = CGSize(width: width, height: 150)
        static let closeOutset = CGFloat(6)
    }

    private let headerImageView = UIImageView {
        $0.contentMode = .scaleAspectFill
        $0.sizeAnchors == Layout.imageSize
        $0.clipsToBounds = true
    }

    private let categoryLabel = UILabel {
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        $0.font = Avenir.medium.of(size: 13)
        $0.textColor = .darkText
    }

    private let visitedLabel = UILabel {
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.font = Avenir.medium.of(size: 13)
        $0.textColor = .darkText
    }

    private let visitSwitch = UISwitch {
        $0.styleAsFilter()
        $0.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        UILocations.visit.expose(item: $0)
    }

    private let nameLabel = UILabel {
        $0.font = Avenir.heavy.of(size: 18)
        $0.textColor = .darkText
        $0.numberOfLines = 0
    }

    private let locationLabel = UILabel {
        $0.font = Avenir.heavy.of(size: 14)
        $0.textColor = .darkText
        $0.numberOfLines = 0
    }

    private let visitorsLabel = UILabel {
        $0.font = Avenir.medium.of(size: 13)
        $0.textColor = .darkText
    }

    private let showMoreButton = UIButton {
        $0.backgroundColor = .azureRadiance
        $0.tintColor = .white
        $0.cornerRadius = 4
        $0.setImage(R.image.buttonInfo(), for: .normal)
        UILocations.more.expose(item: $0)
    }

    private let directionsButton = UIButton {
        $0.backgroundColor = .azureRadiance
        $0.tintColor = .white
        $0.cornerRadius = 4
        $0.setImage(R.image.buttonDirections(), for: .normal)
        UILocations.directions.expose(item: $0)
    }

    private let nearbiesButton = UIButton {
        $0.backgroundColor = .azureRadiance
        $0.tintColor = .white
        $0.cornerRadius = 4
        $0.setImage(R.image.buttonNearby(), for: .normal)
        UILocations.nearbies.expose(item: $0)
    }

    private let addPhotoButton = UIButton {
        $0.backgroundColor = .azureRadiance
        $0.tintColor = .white
        $0.cornerRadius = 4
        $0.setImage(R.image.buttonCamera(), for: .normal)
        UILocations.addPhoto.expose(item: $0)
    }

    private let addPostButton = UIButton {
        $0.backgroundColor = .azureRadiance
        $0.tintColor = .white
        $0.cornerRadius = 4
        $0.setImage(R.image.pencilWhite(), for: .normal)
        UILocations.addPost.expose(item: $0)
    }

    private var visitedObserver: Observer?

    /// Construction by injection
    /// - Parameters:
    ///   - annotation: Place
    ///   - reuseIdentifier: Identifier
    override init(annotation: MKAnnotation?,
                  reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        collisionMode = .circle
        canShowCallout = true
        glyphText = nil
        subtitleVisibility = .visible
        titleVisibility = .hidden

        visitSwitch.addTarget(self,
                              action: #selector(toggleVisit),
                              for: .valueChanged)
        showMoreButton.addTarget(self,
                                 action: #selector(showMoreTapped),
                                 for: .touchUpInside)
        directionsButton.addTarget(self,
                                   action: #selector(directionsTapped),
                                   for: .touchUpInside)
        nearbiesButton.addTarget(self,
                                 action: #selector(nearbiesTapped),
                                 for: .touchUpInside)
        addPhotoButton.addTarget(self,
                                 action: #selector(addPhotoTapped),
                                 for: .touchUpInside)
        addPostButton.addTarget(self,
                                action: #selector(addPostTapped),
                                for: .touchUpInside)

        observe()
    }

    /// :nodoc:
    required init?(coder: NSCoder) {
        return nil
    }

    /// Prepare for display
    override func prepareForDisplay() {
        super.prepareForDisplay()
        guard let mappable = mappable else { return }

        markerTintColor = mappable.marker
        glyphImage = mappable.listImage

        // called at creation, don't load image here
        categoryLabel.text = mappable.checklist.category(full: false).uppercased()
        show(visited: mappable.isVisited)
        nameLabel.text = mappable.title
        locationLabel.text = mappable.subtitle
        visitorsLabel.text = L.visitors(mappable.visitors.grouped)

        detailCalloutAccessoryView = detailView
   }

    /// Prepare for callout display
    func prepareForCallout() {
        guard let mappable = mappable,
            headerImageView.image == nil else { return }

        headerImageView.load(image: mappable)
    }

    /// Empty display
    override func prepareForReuse() {
        super.prepareForReuse()

        headerImageView.prepareForReuse()
        markerTintColor = nil
        glyphText = nil
        glyphImage = nil
        leftCalloutAccessoryView = nil
        rightCalloutAccessoryView = nil
        detailCalloutAccessoryView = nil
        annotation = nil
        image = nil
    }
}

// MARK: - Private

private extension MappableAnnotationView {

    func observe() {
        visitedObserver = data.observer(of: .visited) { [weak self] _ in
            self?.show(visited: self?.mappable?.isVisited ?? false)
        }
    }

    @objc func toggleVisit(_ sender: UISwitch) {
        guard let mappable = mappable else { return }

        let visited = sender.isOn
        note.set(item: mappable.item,
                 visited: visited) { [weak sender] result in
            if case .failure = result {
                sender?.isOn = !visited
            }
        }
    }

    var mapItem: MKMapItem? {
        guard let coordinate = annotation?.coordinate else { return nil }

        let placemark = MKPlacemark(coordinate: coordinate)
        let item = MKMapItem(placemark: placemark)
        item.name = nameLabel.text
        return item
    }

    @objc func closeTapped(_ sender: UIButton) {
        guard let mappable = mappable else { return }
        loc.close(mappable: mappable)
    }

    @objc func directionsTapped(_ sender: GradientButton) {
        guard let mappable = mappable else { return }
        loc.show(directions: mappable)
    }

    @objc func showMoreTapped(_ sender: GradientButton) {
        guard let mappable = mappable else { return }
        loc.show(more: mappable)
    }

    @objc func nearbiesTapped(_ sender: GradientButton) {
        guard let mappable = mappable else { return }
        loc.show(nearby: mappable)
    }

    @objc func addPhotoTapped(_ sender: GradientButton) {
        guard let mappable = mappable else { return }
        loc.add(photo: mappable)
    }

    @objc func addPostTapped(_ sender: GradientButton) {
        guard let mappable = mappable else { return }
        loc.add(post: mappable)
    }

    func show(visited: Bool) {
        visitedLabel.text = (visited ? L.visited() : L.notVisited()).uppercased()
        visitSwitch.isOn = visited
    }

    var detailView: UIView {

        let bottomSpacer = UIView {
                $0.heightAnchor == 2
        }

        let buttons = UIStackView(arrangedSubviews: [showMoreButton,
                                                     directionsButton,
                                                     nearbiesButton,
                                                     addPhotoButton,
                                                     addPostButton
                                                     ]).with {
            $0.spacing = 8
            $0.distribution = .fillEqually
            $0.heightAnchor == 40
        }

        let stack = UIStackView(arrangedSubviews: [topView,
                                                   categoryStack,
                                                   detailStack,
                                                   buttons,
                                                   bottomSpacer
                                                   ]).with {
            $0.axis = .vertical
            $0.spacing = 4
            $0.widthAnchor == Layout.width
        }

        return stack
    }

    var topView: UIView {
        let holder = UIView {
            $0.addSubview(headerImageView)
            $0.heightAnchor == Layout.imageSize.height + Layout.closeOutset
            $0.widthAnchor == Layout.imageSize.width
            headerImageView.centerXAnchor == $0.centerXAnchor
            headerImageView.bottomAnchor == $0.bottomAnchor
        }

        _ = UIButton {
            $0.setImage(R.image.buttonCloseOutlined(), for: .normal)
            holder.addSubview($0)
            $0.topAnchor == holder.topAnchor
            $0.trailingAnchor == holder.trailingAnchor + Layout.closeOutset
            $0.addTarget(self,
                         action: #selector(closeTapped),
                         for: .touchUpInside)
            UILocations.close.expose(item: $0)
        }

        return holder
    }

    var categoryStack: UIStackView {
        let stack = UIStackView(arrangedSubviews: [categoryLabel,
                                                   visitedLabel,
                                                   visitSwitch]).with {
            $0.alignment = .center
        }

        return stack
    }

    var detailStack: UIStackView {
        let stack = UIStackView(arrangedSubviews: [nameLabel,
                                                   locationLabel,
                                                   visitorsLabel]).with {
            $0.axis = .vertical
            $0.spacing = 0
        }

        return stack
    }
}
