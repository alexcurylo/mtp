// @copyright Trollwerks Inc.

import RealmSwift

/// Handles creation and uploading of new posts to MTP
final class AddPostVC: UIViewController, ServiceProvider {

    private typealias Segues = R.segue.addPostVC

    @IBOutlet private var saveButton: UIBarButtonItem?

    @IBOutlet private var locationStack: UIStackView?
    @IBOutlet private var locationLine: UIStackView?
    @IBOutlet private var countryLabel: UILabel?
    @IBOutlet private var locationLabel: UILabel?

    @IBOutlet private var postTitle: UILabel?
    @IBOutlet private var postTextView: TopLoadingTextView?

    private var country: Country? {
        didSet {
            if country?.hasChildren ?? true {
                location = nil
            } else {
                payload.set(country: country)
            }
        }
    }
    private var location: Location? {
        didSet {
            payload.set(location: location)
        }
    }

    private let minCharacters = 140
    private var payload = PostPayload()

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        configure()
        startKeyboardListening()
    }

    /// Remove observers
    deinit {
        stopKeyboardListening()
    }

    /// Stop editing on touch
    ///
    /// - Parameters:
    ///   - touches: User touches
    ///   - event: Touch event
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        view.endEditing(true)
    }

    /// Instrument and inject navigation
    ///
    /// - Parameters:
    ///   - segue: Navigation action
    ///   - sender: Action originator
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.showCountry.identifier:
            if let destination = Segues.showCountry(segue: segue)?.destination.topViewController as? LocationSearchVC {
                destination.inject(mode: .country,
                                   styler: .standard,
                                   delegate: self)
            }
        case Segues.showLocation.identifier:
            if let destination = Segues.showLocation(segue: segue)?.destination.topViewController as? LocationSearchVC,
               let countryId = country?.countryId {
                destination.inject(mode: .location(country: countryId),
                                   styler: .standard,
                                   delegate: self)
            }
        case Segues.pop.identifier:
            break
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

// MARK: - Private

private extension AddPostVC {

    func configure() {
        configureLocation()
        updateSave(showError: false)
    }

    func configureLocation() {
        countryLabel?.text = country?.placeCountry ?? L.selectCountry()

        guard let locationLine = locationLine else { return }
        if let country = country, country.hasChildren {
            locationLabel?.text = location?.placeTitle ?? L.selectLocation()
            locationStack?.addArrangedSubview(locationLine)
        } else {
            locationLabel?.text = countryLabel?.text
            locationStack?.removeArrangedSubview(locationLine)
            locationLine.removeFromSuperview()
        }
    }

    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        guard updateSave(showError: true) else { return }

        upload(payload: payload)
    }

    @discardableResult func updateSave(showError: Bool) -> Bool {
        payload.post = postTextView?.text ?? ""

        let errorMessage: String
        if payload.post.count < minCharacters {
            errorMessage = L.fixLength(minCharacters)
        } else if !payload.location.isValid {
            errorMessage = L.fixLocation()
        } else {
            errorMessage = ""
        }
        let valid = errorMessage.isEmpty

        if showError && !valid {
            note.message(error: errorMessage)
        }

        saveButton?.isEnabled = !payload.post.isEmpty
        return valid
    }

    func upload(payload: PostPayload) {
        note.modal(info: L.publishingPost())

        net.postPublish(payload: payload) { [weak self, note] result in
            switch result {
            case .success:
                note.modal(success: L.success())
                DispatchQueue.main.asyncAfter(deadline: .short) { [weak self] in
                    note.dismissModal()
                    self?.performSegue(withIdentifier: Segues.pop, sender: self)
                }
                return
            case .failure(let error):
                note.modal(failure: error,
                           operation: L.publishPost())
            }
        }
    }
}

// MARK: - LocationSearchDelegate

extension AddPostVC: LocationSearchDelegate {

    /// Handle a location selection
    ///
    /// - Parameters:
    ///   - controller: source of selection
    ///   - item: Country or Location selected
    func locationSearch(controller: RealmSearchViewController,
                        didSelect item: Object) {
        switch item {
        case let countryItem as Country:
            country = countryItem
        case let locationItem as Location:
            location = locationItem
        default:
            log.error("unknown item type selected")
        }
        configure()
    }
}

// MARK: - UITextViewDelegate

extension AddPostVC: UITextViewDelegate {

    /// Respond to edit beginning
    ///
    /// - Parameter textView: Active edit target
    func textViewDidBeginEditing(_ textView: UITextView) { }

    /// Update remaining count
    ///
    /// - Parameter textView: Active edit target
    func textViewDidChange(_ textView: UITextView) {
        updateSave(showError: false)
        let remaining = max(0, minCharacters - payload.post.count)
        if remaining > 0 {
            postTitle?.text = L.postShort(remaining)
        } else {
            postTitle?.text = L.postLong()
        }
    }

    /// Respond to edit ending
    ///
    /// - Parameter textView: Active edit target
    func textViewDidEndEditing(_ textView: UITextView) { }
}

// MARK: - KeyboardListener

extension AddPostVC: KeyboardListener {

    /// Scroll view for keyboard avoidance
    var keyboardScrollee: UIScrollView? { return postTextView }
}

// MARK: - Injectable

extension AddPostVC: Injectable {

    /// Injected dependencies
    typealias Model = Mappable

    /// Handle dependency injection
    ///
    /// - Parameter model: Dependencies
    /// - Returns: Chainable self
    @discardableResult func inject(model: Model) -> Self {
        if let countryId = model.location?.countryId {
            country = data.get(country: countryId)
        }
        if let locationId = model.location?.placeId {
            location = data.get(location: locationId)
        }
        return self
    }

    /// Enforce dependency injection
    func requireInjections() {
        saveButton.require()
        locationStack.require()
        locationLine.require()
        countryLabel.require()
        locationLabel.require()
        postTitle.require()
        postTextView.require()
    }
}