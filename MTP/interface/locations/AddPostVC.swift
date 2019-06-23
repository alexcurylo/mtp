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
    @IBOutlet private var postTextView: UITopLoadingTextView?

    private var countryId = 0
    private var locationId = 0

    private let minCharacters = 140
    private var postText: String = ""

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
            if let destination = Segues.showLocation(segue: segue)?.destination.topViewController as? LocationSearchVC {
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
        let country = countryId > 0 ? data.get(country: countryId) : nil
        countryLabel?.text = country?.countryName ?? L.selectCountry()

        let location = locationId > 0 ? data.get(location: locationId) : nil

        guard let locationLine = locationLine else { return }
        if let country = country, country.hasChildren {
            locationLabel?.text = location?.locationName ?? L.selectLocation()

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

        upload(post: postText, location: locationId)
    }

    @discardableResult func updateSave(showError: Bool) -> Bool {
        postText = postTextView?.text ?? ""

        let errorMessage: String
        if postText.count < minCharacters {
            errorMessage = L.fixLength(minCharacters)
        } else if locationId == 0 {
            errorMessage = L.fixLocation()
        } else {
            errorMessage = ""
        }
        let valid = errorMessage.isEmpty

        if showError && !valid {
            note.message(error: errorMessage)
        }

        saveButton?.isEnabled = !postText.isEmpty
        return valid
    }

    func upload(post: String,
                location id: Int) {
        let operation = L.publishPost()
        note.modal(info: L.publishingPost())

        mtp.upload(post: post,
                   // swiftlint:disable:next closure_body_length
                   location: id) { [weak self, note] result in
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
            case .failure(.decoding),
                 .failure(.result),
                 .failure(.status):
                errorMessage = L.resultsErrorReport(operation)
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
            countryId = countryItem.countryId
            locationId = countryItem.hasChildren ? 0 : countryId
        case let locationItem as Location:
            countryId = locationItem.countryId
            locationId = locationItem.id
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
        let remaining = max(0, minCharacters - postText.count)
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
        countryId = model.countryId
        locationId = model.id
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
