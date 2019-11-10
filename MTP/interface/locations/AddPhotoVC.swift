// @copyright Trollwerks Inc.

import Photos
import RealmSwift

// swiftlint:disable file_length

/// Manage AddPhoto controller
protocol AddPhotoDelegate: AnyObject {

    /// Enable Location selection
    var isLocatable: Bool { get }
}

/// Handles creation and uploading of new photos to MTP
final class AddPhotoVC: UIViewController {

    private typealias Segues = R.segue.addPhotoVC

    // verified in requireOutlets
    @IBOutlet private var closeButton: UIBarButtonItem!
    @IBOutlet private var saveButton: UIBarButtonItem!
    @IBOutlet private var locationView: UIView!
    @IBOutlet private var locationStack: UIStackView!
    @IBOutlet private var locationLine: UIStackView!
    @IBOutlet private var countryLabel: UILabel!
    @IBOutlet private var locationLabel: UILabel!
    @IBOutlet private var captionTextView: TopLoadingTextView!
    @IBOutlet private var imageButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var libraryButton: GradientButton!
    @IBOutlet private var cameraButton: GradientButton!
    @IBOutlet private var facebookButton: GradientButton!
    @IBOutlet private var instagramButton: GradientButton!

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

    private var captionText: String = ""

    private var updating: Photo?
    private var updatingLocation: Location?

    private var photo: UIImage? {
        didSet {
            imageView.image = photo
            let back: UIColor = photo == nil ? .dustyGray : .clear
            imageButton.backgroundColor = back
        }
    }

    /// :nodoc:
    override func viewDidLoad() {
        super.viewDidLoad()
        requireOutlets()
        requireInjection()

        imagePicker.delegate = self

        configure()
        startKeyboardListening()
    }

    /// :nodoc:
    deinit {
        stopKeyboardListening()
    }

    /// :nodoc:
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .standard)
        expose()
    }

    /// :nodoc:
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        report(screen: "Add Photo")

        if updating == nil {
            if PHPhotoLibrary.authorizationStatus() == .notDetermined,
               !UIApplication.isTesting {
                PHPhotoLibrary.requestAuthorization { _ in }
            }
        } else if !net.isConnected {
            let question = L.continueOffline(L.updatePhoto())
            note.ask(question: question) { [weak self] answer in
                if !answer {
                    self?.performSegue(withIdentifier: Segues.pop,
                                       sender: self)
                }
            }
        }
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

    /// :nodoc:
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

        if let updating = updating {
            navigationItem.title = L.editPhoto()
            captionTextView.text = updating.desc
            imageView?.load(image: updating)
            imageButton.isHidden = true
            libraryButton.isHidden = true
            cameraButton.isHidden = true
        } else {
            navigationItem.title = L.addPhoto()
            if !UIImagePickerController.isSourceTypeAvailable(.camera) {
                cameraButton.isHidden = true
            }
        }
        facebookButton.isHidden = true
        instagramButton.isHidden = true

        updateSave(showError: false)
    }

    func configureLocation() {
        guard let delegate = delegate, delegate.isLocatable else {
            locationView.isHidden = true
            return
        }

        locationView.isHidden = false

        let country = countryId > 0 ? data.get(country: countryId) : nil
        countryLabel.text = country?.placeCountry ?? L.selectCountryOptional()

        let location = locationId > 0 ? data.get(location: locationId) : nil

        if let country = country, country.hasChildren {
            locationLabel.text = location?.placeTitle ?? L.selectLocation()

            locationStack.addArrangedSubview(locationLine)
        } else {
            locationLabel.text = countryLabel.text

            locationStack.removeArrangedSubview(locationLine)
            locationLine.removeFromSuperview()
        }
    }

    func suggest(location: CLLocation?) {
        guard let delegate = delegate,
              delegate.isLocatable else { return }

        let inside: Location?
        if let location = location {
            inside = data.worldMap.location(of: location.coordinate)
        } else {
            inside = loc.inside
        }
        guard let located = inside,
              located.placeId != locationId else { return }

        let question: String
        if location != nil {
            question = L.tagWithPhotoLocation(located.description)
        } else {
            question = L.tagWithCurrentLocation(located.description)
        }
        note.ask(question: question) { [weak self] answer in
            guard answer, let self = self else { return }

            self.countryId = located.countryId
            self.locationId = located.placeId
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
        guard updateSave(showError: true) else { return }

        if updating == nil {
            upload()
        } else {
            update()
        }
    }

    func upload() {
        guard let data = photo?.jpegData(compressionQuality: 0.9) else { return }

        let caption = captionText.isEmpty ? nil : captionText
        let location = locationId == 0 ? nil: locationId
        net.upload(photo: data,
                   caption: caption,
                   location: location) { [weak self] _ in
            self?.performSegue(withIdentifier: Segues.pop, sender: self)
        }
    }

    func update() {
        guard let updating = updating else { return }

        let payload = PhotoUpdatePayload(from: updating,
                                         locationId: locationId,
                                         caption: captionText)

        note.modal(info: L.updatingPhoto())

        net.photoUpdate(payload: payload) { [weak self, note] result in
            switch result {
            case .success:
                note.modal(success: L.success())
                DispatchQueue.main.asyncAfter(deadline: .short) { [weak self] in
                    note.dismissModal()
                    self?.finishUpdate()
                }
                return
            case .failure(let error):
                note.modal(failure: error,
                           operation: L.updatePhoto())
            }
        }
    }

    func finishUpdate() {
        guard let updating = updating,
              let realm = try? Realm() else { return }

        let oldLocation = updating.locationId
        do {
            try realm.write {
                updating.locationId = locationId
                updating.desc = captionText
            }
        } catch {
            log.error("Edit Photo error: \(error)")
        }
        if oldLocation != locationId {
            data.notify(change: .locationPhotos, object: oldLocation)
            data.notify(change: .locationPhotos, object: locationId)
        }

        performSegue(withIdentifier: Segues.pop, sender: self)
    }

    @discardableResult func updateSave(showError: Bool) -> Bool {
        captionText = captionTextView.text ?? ""

        let errorMessage: String
        if countryId != 0 && locationId == 0 {
            errorMessage = L.fixLocationProfile()
        } else if updating == nil && photo == nil {
            errorMessage = L.fixPhoto()
        } else {
            errorMessage = ""
        }
        let valid = errorMessage.isEmpty

        if showError && !valid {
            note.message(error: errorMessage)
        }

        let changed: Bool
        if let updating = updating {
            changed = captionText != updating.desc ||
                      countryId != updatingLocation?.countryId ||
                      locationId != updating.locationId
        } else {
            changed = true
        }

        saveButton.isEnabled = valid && changed
        return valid
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
        let location = (info[.phAsset] as? PHAsset)?.location
        if let edited = info[.editedImage] as? UIImage {
            photo = edited
        } else if let original = info[.originalImage] as? UIImage {
            photo = original
        }

        updateSave(showError: false)
        dismiss(animated: true) { [weak self] in
            self?.suggest(location: location)
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
        UIAddPhoto.camera.expose(item: cameraButton)
        UIAddPhoto.close.expose(item: closeButton)
        UIAddPhoto.image.expose(item: imageButton)
        UIAddPhoto.save.expose(item: saveButton)
    }
}

// MARK: - InterfaceBuildable

extension AddPhotoVC: InterfaceBuildable {

    /// Injection enforcement for viewDidLoad
    func requireOutlets() {
        cameraButton.require()
        captionTextView.require()
        closeButton.require()
        countryLabel.require()
        facebookButton.require()
        imageButton.require()
        imageView.require()
        instagramButton.require()
        libraryButton.require()
        locationLabel.require()
        locationLine.require()
        locationStack.require()
        locationView.require()
        saveButton.require()
    }
}

// MARK: - Injectable

extension AddPhotoVC: Injectable {

    /// Injected dependencies
    typealias Model = (photo: Photo?,
                       mappable: Mappable?,
                       delegate: AddPhotoDelegate)

    /// Handle dependency injection
    ///
    /// - Parameter model: Dependencies
    func inject(model: Model) {
        updating = model.photo
        if let photo = model.photo {
            updatingLocation = data.get(location: photo.locationId)
            countryId = updatingLocation?.countryId ?? 0
            locationId = photo.locationId
        } else if let location = model.mappable?.location {
            countryId = location.countryId
            locationId = location.placeId
        }
        delegate = model.delegate
    }

    /// Enforce dependency injection
    func requireInjection() {
        delegate.require()
    }
}
