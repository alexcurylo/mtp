// @copyright Trollwerks Inc.

import RealmSwift

// swiftlint:disable file_length

/// Manage AddPhoto controller
protocol AddPhotoDelegate: AnyObject {

    /// Enable Location selection
    var isLocatable: Bool { get }

    /// Handle photo addition
    ///
    /// - Parameters:
    ///   - controller: Add Photo controller
    ///   - reply: Selection description
    func addPhoto(controller: AddPhotoVC,
                  didAdd reply: PhotoReply)
}

/// Handles creation and uploading of new photos to MTP
final class AddPhotoVC: UIViewController, ServiceProvider {

    private typealias Segues = R.segue.addPhotoVC

    @IBOutlet private var closeButton: UIBarButtonItem?
    @IBOutlet private var saveButton: UIBarButtonItem?

    @IBOutlet private var locationView: UIView?
    @IBOutlet private var locationStack: UIStackView?
    @IBOutlet private var locationLine: UIStackView?
    @IBOutlet private var countryLabel: UILabel?
    @IBOutlet private var locationLabel: UILabel?

    @IBOutlet private var captionTextView: TopLoadingTextView?

    @IBOutlet private var imageButton: UIButton?
    @IBOutlet private var imageView: UIImageView?
    @IBOutlet private var cameraButton: GradientButton?
    @IBOutlet private var facebookButton: GradientButton?
    @IBOutlet private var instagramButton: GradientButton?

    private let imagePicker = UIImagePickerController {
        $0.allowsEditing = true
        $0.sourceType = .photoLibrary
        $0.navigationBar.setBackgroundImage(nil, for: .default)
        $0.navigationBar.isTranslucent = true
        $0.navigationBar.backgroundColor = .dodgerBlue
        $0.navigationBar.barTintColor = .dodgerBlue
    }

    private weak var delegate: AddPhotoDelegate?

    private var countryId = 0
    private var locationId = 0
    private var suggestedLocation = false

    private var captionText: String = ""

    private var photo: UIImage? {
        didSet {
            imageView?.image = photo
            let back: UIColor = photo == nil ? .dustyGray : .clear
            imageButton?.backgroundColor = back
        }
    }

    /// Prepare for interaction
    override func viewDidLoad() {
        super.viewDidLoad()
        requireInjections()

        imagePicker.delegate = self

        configure()
        startKeyboardListening()
    }

    /// Remove observers
    deinit {
        stopKeyboardListening()
    }

    /// Prepare for reveal
    ///
    /// - Parameter animated: Whether animating
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        expose()
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
        if let target = Segues.showCountry(segue: segue)?
                              .destination
                              .topViewController as? LocationSearchVC {
            target.inject(mode: .countryOrNone,
                          styler: .standard,
                          delegate: self)
        } else if let target = Segues.showLocation(segue: segue)?
                                     .destination
                                     .topViewController as? LocationSearchVC {
            target.inject(mode: .location(country: countryId),
                          styler: .standard,
                          delegate: self)
        }
    }
}

// MARK: - Private

private extension AddPhotoVC {

    func configure() {
        configureLocation()

        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            cameraButton?.isHidden = true
        }
        facebookButton?.isHidden = true
        instagramButton?.isHidden = true

        updateSave(showError: false)
    }

    func configureLocation() {
        guard let delegate = delegate, delegate.isLocatable else {
            locationView?.isHidden = true
            return
        }

        locationView?.isHidden = false

        let country = countryId > 0 ? data.get(country: countryId) : nil
        countryLabel?.text = country?.placeCountry ?? L.selectCountryOptional()

        let location = locationId > 0 ? data.get(location: locationId) : nil

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

    func suggestLocation() {
        guard !suggestedLocation,
              locationId == 0,
              let delegate = delegate,
              delegate.isLocatable,
              let inside = loc.inside else { return }

        suggestedLocation = true
        let question = L.tagWithLocation(inside.description)
        note.ask(question: question) { [weak self] answer in
            guard answer, let self = self else { return }

            self.countryId = inside.countryId
            self.locationId = inside.placeId
            self.configure()
        }
    }

    @IBAction func photoLibraryTapped(_ sender: UIButton) {
        view.endEditing(true)
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func cameraTapped(_ sender: UIButton) {
        view.endEditing(true)
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func facebookPhotosTapped(_ sender: UIButton) {
        view.endEditing(true)
        note.unimplemented()
    }

    @IBAction func instagramPhotosTapped(_ sender: UIButton) {
        view.endEditing(true)
        note.unimplemented()
    }

    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        guard updateSave(showError: true),
            let data = photo?.jpegData(compressionQuality: 1.0) else { return }

        upload(photo: data,
               caption: captionText.isEmpty ? nil : captionText,
               location: locationId == 0 ? nil: locationId)
    }

    @discardableResult func updateSave(showError: Bool) -> Bool {
        captionText = captionTextView?.text ?? ""

        let errorMessage: String
        if countryId != 0 && locationId == 0 {
            errorMessage = L.fixLocation()
        } else if photo == nil {
            errorMessage = L.fixPhoto()
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

    func upload(photo: Data,
                caption: String?,
                location id: Int?) {
        note.modal(info: L.publishingPhoto())

        net.upload(photo: photo,
                   caption: caption,
                   location: id) { [weak self, note] result in
            switch result {
            case .success(let reply):
                note.modal(success: L.success())
                DispatchQueue.main.async { [weak self] in
                    if let self = self {
                        self.delegate?.addPhoto(controller: self,
                                                didAdd: reply)
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .short) { [weak self] in
                    note.dismissModal()
                    self?.performSegue(withIdentifier: Segues.pop, sender: self)
                }
            case .failure(let error):
                note.modal(failure: error,
                           operation: L.publishPhoto())
            }
        }
    }
}

// MARK: - LocationSearchDelegate

extension AddPhotoVC: LocationSearchDelegate {

    /// Handle a location selection
    ///
    /// - Parameters:
    ///   - controller: source of selection
    ///   - item: Country or Location selected
    func locationSearch(controller: RealmSearchViewController,
                        didSelect item: Object) {
        switch item {
        case let countryItem as Country:
            countryId = countryItem.countryId
            locationId = countryItem.hasChildren ? 0 : countryId
        case let locationItem as Location:
            countryId = locationItem.countryId
            locationId = locationItem.placeId
        default:
            log.error("unknown item type selected")
        }
        configure()
    }
}

// MARK: - UITextViewDelegate

extension AddPhotoVC: UITextViewDelegate {

    /// Respond to edit beginning
    ///
    /// - Parameter textView: Active edit target
    func textViewDidBeginEditing(_ textView: UITextView) { }

    /// Detect return key to end editing
    ///
    /// - Parameters:
    ///   - textView: Active edit target
    ///   - _: Replacement range
    ///   - text: Replacement text
    /// - Returns: Change permission
    func textView(_ textView: UITextView,
                  shouldChangeTextIn _: NSRange,
                  replacementText text: String) -> Bool {
        let resultRange = text.rangeOfCharacter(from: CharacterSet.newlines,
                                                options: .backwards)
        if text.count == 1 && resultRange != nil {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    /// Respond to text changes
    ///
    /// - Parameter textView: Active edit target
    func textViewDidChange(_ textView: UITextView) {
        updateSave(showError: false)
    }

    /// Respond to edit ending
    ///
    /// - Parameter textView: Active edit target
    func textViewDidEndEditing(_ textView: UITextView) {
        updateSave(showError: false)
    }
}

// MARK: - KeyboardListener

extension AddPhotoVC: KeyboardListener {

    /// Scroll view for keyboard avoidance
    var keyboardScrollee: UIScrollView? { return captionTextView }
}

// MARK: - UIImagePickerControllerDelegate

extension AddPhotoVC: UIImagePickerControllerDelegate {

    /// Receive system provided image
    ///
    /// - Parameters:
    ///   - picker: The system photo picker
    ///   - info: Picking results
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let edited = info[.editedImage] as? UIImage {
            photo = edited
        } else if let original = info[.originalImage] as? UIImage {
            photo = original
        }

        updateSave(showError: false)
        dismiss(animated: true) { [weak self] in
            self?.suggestLocation()
        }
    }

    /// Handle image picking cancel
    ///
    ///   - picker: The system photo picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

// MARK: - UINavigationControllerDelegate

extension AddPhotoVC: UINavigationControllerDelegate { }

// MARK: - Exposing

extension AddPhotoVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        UIAddPhoto.close.expose(item: closeButton)
        UIAddPhoto.save.expose(item: saveButton)
    }
}

// MARK: - Injectable

extension AddPhotoVC: Injectable {

    /// Injected dependencies
    typealias Model = (mappable: Mappable?, delegate: AddPhotoDelegate)

    /// Handle dependency injection
    ///
    /// - Parameter model: Dependencies
    /// - Returns: Chainable self
    @discardableResult func inject(model: Model) -> Self {
        countryId = model.mappable?.location?.countryId ?? 0
        locationId = model.mappable?.location?.placeId ?? 0
        delegate = model.delegate
        return self
    }

    /// Enforce dependency injection
    func requireInjections() {
        closeButton.require()
        saveButton.require()
        locationStack.require()
        locationLine.require()
        countryLabel.require()
        locationLabel.require()
        captionTextView.require()
        imageButton.require()
        imageView.require()
        delegate.require()
    }
}
