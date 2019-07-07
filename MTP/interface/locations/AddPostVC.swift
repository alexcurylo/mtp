// @copyright Trollwerks Inc.

import RealmSwift

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

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        configure()
        startKeyboardListening()
    }

    deinit {
        stopKeyboardListening()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        log.warning("didReceiveMemoryWarning: \(type(of: self))")
        super.didReceiveMemoryWarning()
    }

    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        view.endEditing(true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.showCountry.identifier:
            if let destination = Segues.showCountry(segue: segue)?.destination.topViewController as? LocationSearchVC {
                destination.set(list: .country,
                                styler: .standard,
                                delegate: self)
            }
        case Segues.showLocation.identifier:
            if let destination = Segues.showLocation(segue: segue)?.destination.topViewController as? LocationSearchVC,
               let countryId = country?.countryId {
                destination.set(list: .location(country: countryId),
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
        let operation = L.publishPost()
        note.modal(info: L.publishingPost())

        // swiftlint:disable:next closure_body_length
        mtp.postPublish(payload: payload) { [weak self, note] result in
            let errorMessage: String
            switch result {
            case .success:
                note.modal(success: L.success())
                DispatchQueue.main.asyncAfter(deadline: .short) { [weak self] in
                    note.dismissModal()
                    self?.performSegue(withIdentifier: Segues.pop, sender: self)
                }
                return
            case .failure(.deviceOffline):
                errorMessage = L.deviceOfflineError(operation)
            case .failure(.serverOffline):
                errorMessage = L.serverOfflineError(operation)
            case .failure(.decoding):
                errorMessage = L.decodingErrorReport(operation)
            case .failure(.status):
                errorMessage = L.statusErrorReport(operation)
            case .failure(.message(let message)):
                errorMessage = message
            case .failure(.network(let message)):
                errorMessage = L.networkError(operation, message)
            default:
                errorMessage = L.unexpectedErrorReport(operation)
            }
            note.modal(error: errorMessage)
            DispatchQueue.main.asyncAfter(deadline: .medium) {
                note.dismissModal()
            }
        }
    }
}

// MARK: - LocationSearchDelegate

extension AddPostVC: LocationSearchDelegate {

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

    func textViewDidBeginEditing(_ textView: UITextView) {
    }

    func textViewDidChange(_ textView: UITextView) {
        updateSave(showError: false)
        let remaining = max(0, minCharacters - payload.post.count)
        if remaining > 0 {
            postTitle?.text = L.postShort(remaining)
        } else {
            postTitle?.text = L.postLong()
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
    }
}

// MARK: - KeyboardListener

extension AddPostVC: KeyboardListener {

    var keyboardScrollee: UIScrollView? { return postTextView }
}

// MARK: - Injectable

extension AddPostVC: Injectable {

    typealias Model = PlaceAnnotation

    @discardableResult func inject(model: Model) -> Self {
        country = data.get(country: model.countryId)
        location = data.get(location: model.id)
        return self
    }

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
