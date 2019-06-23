// @copyright Trollwerks Inc.

import RealmSwift

final class AddPhotoVC: UIViewController, ServiceProvider {

    private typealias Segues = R.segue.addPhotoVC

    @IBOutlet private var saveButton: UIBarButtonItem?

    @IBOutlet private var locationStack: UIStackView?
    @IBOutlet private var locationLine: UIStackView?
    @IBOutlet private var countryLabel: UILabel?
    @IBOutlet private var locationLabel: UILabel?

    @IBOutlet private var captionTextView: UITopLoadingTextView?

    @IBOutlet private var imageButton: UIButton?
    @IBOutlet private var imageView: UIImageView?

    private let imagePicker = UIImagePickerController {
        $0.allowsEditing = true
        $0.sourceType = .photoLibrary
        $0.navigationBar.setBackgroundImage(nil, for: .default)
        $0.navigationBar.isTranslucent = true
        $0.navigationBar.backgroundColor = .dodgerBlue
        $0.navigationBar.barTintColor = .dodgerBlue
    }

    private var countryId = 0
    private var locationId = 0

    private var captionText: String = ""

    private var image: UIImage? {
        didSet {
            imageView?.image = image
            let back: UIColor = image == nil ? .dustyGray : .clear
            imageButton?.backgroundColor = back
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        imagePicker.delegate = self

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
                destination.set(list: .countryOrNot,
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

private extension AddPhotoVC {

    func configure() {
        configureLocation()
        updateSave(showError: false)
    }

    func configureLocation() {
        let country = countryId > 0 ? data.get(country: countryId) : nil
        countryLabel?.text = country?.countryName ?? Localized.selectCountryOptional()

        let location = locationId > 0 ? data.get(location: locationId) : nil

        guard let locationLine = locationLine else { return }
        if let country = country, country.hasChildren {
            locationLabel?.text = location?.locationName ?? Localized.selectLocation()

            locationStack?.addArrangedSubview(locationLine)
        } else {
            locationLabel?.text = countryLabel?.text

            locationStack?.removeArrangedSubview(locationLine)
            locationLine.removeFromSuperview()
        }
    }

    @IBAction func importTapped(_ sender: UIButton) {
        view.endEditing(true)

        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        guard updateSave(showError: true),
              let image = image else { return }

        upload(image: image,
               caption: captionText,
               location: locationId)
    }

    @discardableResult func updateSave(showError: Bool) -> Bool {
        captionText = captionTextView?.text ?? ""

        let errorMessage: String
        if countryId != 0 && locationId == 0 {
            errorMessage = Localized.fixLocation()
        } else if image == nil {
            errorMessage = Localized.fixPhoto()
        } else {
            errorMessage = ""
        }
        let valid = errorMessage.isEmpty

        if showError && !valid {
            note.message(error: errorMessage)
        }

        saveButton?.isEnabled = valid
        return valid
    }

    func upload(image: UIImage,
                caption: String,
                location id: Int) {
        let operation = Localized.publishPost()
        note.modal(info: Localized.publishingPost())

        mtp.upload(image: image,
                   caption: caption,
                   // swiftlint:disable:next closure_body_length
                   location: id) { [weak self, note] result in
            let errorMessage: String
            switch result {
            case .success:
                note.modal(success: Localized.success())
                DispatchQueue.main.asyncAfter(deadline: .short) { [weak self] in
                    note.dismissModal()
                    self?.performSegue(withIdentifier: Segues.pop, sender: self)
                }
                return
            case .failure(.deviceOffline):
                errorMessage = Localized.deviceOfflineError(operation)
            case .failure(.serverOffline):
                errorMessage = Localized.serverOfflineError(operation)
            case .failure(.decoding),
                 .failure(.result),
                 .failure(.status):
                errorMessage = Localized.resultsErrorReport(operation)
            case .failure(.message(let message)):
                errorMessage = message
            case .failure(.network(let message)):
                errorMessage = Localized.networkError(operation, message)
            default:
                errorMessage = Localized.unexpectedErrorReport(operation)
            }
            note.modal(error: errorMessage)
            DispatchQueue.main.asyncAfter(deadline: .medium) {
                note.dismissModal()
            }
        }
    }
}

// MARK: - LocationSearchDelegate

extension AddPhotoVC: LocationSearchDelegate {

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

extension AddPhotoVC: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
    }

    func textViewDidChange(_ textView: UITextView) {
        updateSave(showError: false)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
    }
}

// MARK: - KeyboardListener

extension AddPhotoVC: KeyboardListener {

    var keyboardScrollee: UIScrollView? { return captionTextView }
}

// MARK: - UIImagePickerControllerDelegate

extension AddPhotoVC: UIImagePickerControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let possibleImage = info[.editedImage] as? UIImage {
            image = possibleImage
        } else if let possibleImage = info[.originalImage] as? UIImage {
            image = possibleImage
        }

        updateSave(showError: false)
        dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

// MARK: - UINavigationControllerDelegate

extension AddPhotoVC: UINavigationControllerDelegate {
}

// MARK: - Injectable

extension AddPhotoVC: Injectable {

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
        captionTextView.require()
        imageButton.require()
        imageView.require()
    }
}
