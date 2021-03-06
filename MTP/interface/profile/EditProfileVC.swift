// @copyright Trollwerks Inc.

import Anchorage
import RealmSwift

// swiftlint:disable file_length

/// Edit logged in user info and upload to MTP
final class EditProfileVC: UITableViewController {

    private typealias Segues = R.segue.editProfileVC

    // verified in requireOutlets
    @IBOutlet private var closeButton: UIBarButtonItem!
    @IBOutlet private var saveButton: UIBarButtonItem!
    @IBOutlet private var infoStack: UIStackView!
    @IBOutlet private var avatarButton: UIButton!
    @IBOutlet private var firstNameTextField: UITextField!
    @IBOutlet private var lastNameTextField: UITextField!
    @IBOutlet private var birthdayTextField: UITextField!
    @IBOutlet private var genderTextField: UITextField!
    @IBOutlet private var countryStack: UIStackView!
    @IBOutlet private var countryTextField: UITextField!
    @IBOutlet private var locationStack: UIStackView!
    @IBOutlet private var locationTextField: UITextField!
    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var aboutTextView: UITextView!
    @IBOutlet private var airportTextField: UITextField!
    @IBOutlet private var linksStack: UIStackView!
    @IBOutlet private var addLinkButton: UIButton!
    @IBOutlet private var keyboardToolbar: UIToolbar!
    @IBOutlet private var toolbarBackButton: UIBarButtonItem!
    @IBOutlet private var toolbarNextButton: UIBarButtonItem!
    @IBOutlet private var toolbarClearButton: UIBarButtonItem!
    @IBOutlet private var toolbarDoneButton: UIBarButtonItem!

    private enum Layout {
        static let sectionCornerRadius = CGFloat(5)
        static let bottomCorners = ViewCorners.bottom(radius: sectionCornerRadius)
    }

    private var original = UserUpdatePayload()
    private var current = UserUpdatePayload()
    private var country: Country?
    private var location: Location?
    private let genders = [
        L.selectGender(),
        L.male(),
        L.female(),
        L.preferNot(),
    ]

    /// :nodoc:
    override func viewDidLoad() {
        super.viewDidLoad()

        requireOutlets()
        configure()
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

        report(screen: "Edit Profile")
        if !net.isConnected {
            let question = L.continueOffline(L.updateProfile())
            note.ask(question: question) { [weak self] answer in
                if !answer {
                    self?.performSegue(withIdentifier: Segues.cancelEdits, sender: self)
                }
            }
        }
    }

    /// Apply corner rounding on each layout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        addLinkButton.round(corners: Layout.bottomCorners)
    }

    /// :nodoc:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        view.endEditing(true)
        if let target = Segues.showCountry(segue: segue)?
                              .destination
                              .topViewController as? LocationSearchVC {
            target.inject(mode: .countryOrPreferNot,
                          styler: .standard,
                          delegate: self)
        } else if let target = Segues.showLocation(segue: segue)?
                                     .destination
                                     .topViewController as? LocationSearchVC,
                  let countryId = country?.countryId {
            target.inject(mode: .location(country: countryId),
                          styler: .standard,
                          delegate: self)
        } else if let photos = Segues.showPhotos(segue: segue)?
                                     .destination,
                  let user = data.user {
            photos.inject(model: User(from: user))
            photos.inject(mode: .picker,
                          selection: current.picture ?? "",
                          delegate: self)
        }
    }
}

// MARK: - UITableViewDelegate

extension EditProfileVC {

    /// :nodoc:
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    /// :nodoc:
    override func tableView(_ tableView: UITableView,
                            estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: - UITextFieldDelegate

extension EditProfileVC: UITextFieldDelegate {

    /// Begin editing text field
    /// - Parameter textField: UITextField
    /// - Returns: Permission
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let linkTextFields = linksStack.linkTextFields

        var clearHidden = true
        switch textField {
        case firstNameTextField:
            toolbarBackButton.isEnabled = false
            toolbarNextButton.isEnabled = true
        case countryTextField:
            performSegue(withIdentifier: Segues.showCountry, sender: self)
            return false
        case locationTextField:
            performSegue(withIdentifier: Segues.showLocation, sender: self)
            return false
        case airportTextField:
            toolbarBackButton.isEnabled = true
            toolbarNextButton.isEnabled = !linkTextFields.isEmpty
        case linkTextFields.last:
            toolbarBackButton.isEnabled = true
            toolbarNextButton.isEnabled = false
        case birthdayTextField:
            clearHidden = false
            // swiftlint:disable:next fallthrough
            fallthrough
        case lastNameTextField,
             birthdayTextField,
             genderTextField,
             emailTextField,
             _ where linkTextFields.contains(textField):
            toolbarBackButton.isEnabled = true
            toolbarNextButton.isEnabled = true
        default:
            toolbarBackButton.isEnabled = false
            toolbarNextButton.isEnabled = false
        }
        toolbarClearButton.isHidden = clearHidden

        return true
    }

    /// Handle return key
    /// - Parameter textField: UITextField
    /// - Returns: Permission
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        updateSave(showError: false)
        return false
    }
}

// MARK: - UITextViewDelegate

extension EditProfileVC: UITextViewDelegate {

    /// Respond to edit beginning
    /// - Parameter textView: Active edit target
    func textViewDidBeginEditing(_ textView: UITextView) {
        toolbarBackButton.isEnabled = true
        toolbarNextButton.isEnabled = true
        toolbarClearButton.isHidden = true
    }

    /// Update savability
    /// - Parameter textView: Active edit target
    func textViewDidChange(_ textView: UITextView) {
        updateSave(showError: false)
    }

    /// Respond to edit ending
    /// - Parameter textView: Active edit target
    func textViewDidEndEditing(_ textView: UITextView) { }
}

// MARK: - Private

private extension EditProfileVC {

    @IBAction func unwindToEditProfile(segue: UIStoryboardSegue) { }

    // swiftlint:disable:next function_body_length
    func configure() {
        tableView.backgroundColor = .clear

        guard let user = data.user else { return }

        let update = UserUpdatePayload(from: user)
        original = update
        if update.country_id > 0 {
            country = data.get(country: update.country_id)
            location = data.get(location: update.location_id)
        } else {
            country = nil
            location = nil
        }
        current = original

        if update.imageUrl != nil {
            avatarButton.load(image: update)
        }

        firstNameTextField.inputAccessoryView = keyboardToolbar
        firstNameTextField.text = update.first_name
        firstNameTextField.addTarget(self,
                                     action: #selector(textFieldDidChange),
                                     for: .editingChanged)

        lastNameTextField.inputAccessoryView = keyboardToolbar
        lastNameTextField.text = update.last_name
        lastNameTextField.addTarget(self,
                                    action: #selector(textFieldDidChange),
                                    for: .editingChanged)

        birthdayTextField.inputAccessoryView = keyboardToolbar
        birthdayTextField.inputView = UIDatePicker {
            $0.datePickerMode = .date
            $0.timeZone = TimeZone(secondsFromGMT: 0)
            $0.minimumDate = Calendar.current.date(byAdding: .year, value: -120, to: Date())
            $0.maximumDate = Date()
            $0.addTarget(self,
                         action: #selector(birthdayChanged(_:)),
                         for: .valueChanged)
        }
       birthdayTextField.text = update.birthday

        genderTextField.inputView = UIPickerView {
            $0.dataSource = self
            $0.delegate = self
        }
        genderTextField.inputAccessoryView = keyboardToolbar
        let gender: String
        switch update.gender {
        case "M": gender = L.male()
        case "F": gender = L.female()
        case "U": gender = L.preferNot()
        default: gender = L.preferNot()
        }
        genderTextField.text = gender

        countryTextField.inputAccessoryView = keyboardToolbar
        countryTextField.text = country?.placeCountry

        locationTextField.inputAccessoryView = keyboardToolbar
        locationTextField.text = location?.placeTitle
        show(location: update.country_id != update.location_id)

        emailTextField.inputAccessoryView = keyboardToolbar
        emailTextField.text = update.email
        emailTextField.addTarget(self,
                                 action: #selector(textFieldDidChange),
                                 for: .editingChanged)

        airportTextField.inputAccessoryView = keyboardToolbar
        airportTextField.text = update.airport?.uppercased()
        airportTextField.addTarget(self,
                                   action: #selector(textFieldDidChange),
                                   for: .editingChanged)

        aboutTextView.inputAccessoryView = keyboardToolbar
        aboutTextView.text = update.bio

        configureLinks()

        updateSave(showError: false)
    }

    func configureLinks() {
        guard let originals = original.links,
              !originals.isEmpty else { return }

        let backwards = originals.enumerated().reversed()
        for (index, link) in backwards where link.isEmpty {
            current.links?.remove(at: index)
        }

        guard let links = current.links,
              !links.isEmpty else { return }

        for (index, link) in links.enumerated() {
            display(row: index, link: link)
       }
    }

    func display(row: Int, link: Link) {
        let text = InsetTextField {
            $0.styleForEditProfile()
            $0.text = link.text
            $0.inputAccessoryView = keyboardToolbar
            $0.delegate = self
            UIEditProfile.linkTitle(row).expose(item: $0)
        }

        let holder = UIView {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        let url = InsetTextFieldGradient {
            holder.addSubview($0)
            $0.edgeAnchors == holder.edgeAnchors
            $0.styleForEditProfile()
            $0.text = link.url
            $0.inputAccessoryView = keyboardToolbar
            $0.delegate = self
            UIEditProfile.linkUrl(row).expose(item: $0)
        }
        _ = UIButton {
            $0.setImage(R.image.tagDelete(), for: .normal)
            holder.addSubview($0)
            $0.heightAnchor == url.cornerRadius * 2
            $0.widthAnchor == url.cornerRadius * 2
            $0.centerYAnchor == holder.centerYAnchor
            $0.trailingAnchor == holder.trailingAnchor
            $0.addTarget(self,
                         action: #selector(deleteLinkTapped),
                         for: .touchUpInside)
            $0.tag = linksStack.arrangedSubviews.count
            UIEditProfile.linkDelete(row).expose(item: $0)
        }

        let linkStack = UIStackView(arrangedSubviews: [
            text,
            holder,
        ]).with {
            $0.axis = .vertical
            $0.spacing = 4
        }
        linksStack.addArrangedSubview(linkStack)
    }

    var isLocationVisible: Bool {
        locationStack.superview != nil
    }

    func show(location visible: Bool) {
        guard let info = infoStack,
              let location = locationStack,
              let country = countryStack,
              visible != isLocationVisible else { return }

        tableView.update {
            switch (visible, isLocationVisible) {
            case (true, false):
                let after = info.arrangedSubviews.firstIndex(of: country) ?? 0
                info.insertArrangedSubview(location, at: after + 1)
            case (false, true):
                info.removeArrangedSubview(location)
                location.removeFromSuperview()
            default:
                break
            }
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
   @IBAction func toolbarBackTapped(_ sender: UIBarButtonItem) {
        let linkTextFields = linksStack.linkTextFields

        if firstNameTextField.isEditing {
            firstNameTextField.resignFirstResponder()
            updateSave(showError: false)
        } else if lastNameTextField.isEditing {
            firstNameTextField.becomeFirstResponder()
        } else if birthdayTextField.isEditing {
            lastNameTextField.becomeFirstResponder()
        } else if genderTextField.isEditing {
            birthdayTextField.becomeFirstResponder()
        } else if countryTextField.isEditing {
            genderTextField.becomeFirstResponder()
        } else if locationTextField.isEditing {
            countryTextField.becomeFirstResponder()
        } else if emailTextField.isEditing {
            if isLocationVisible {
                locationTextField.becomeFirstResponder()
            } else {
                countryTextField.becomeFirstResponder()
            }
        } else if aboutTextView.isFirstResponder {
            emailTextField.becomeFirstResponder()
        } else if airportTextField.isEditing {
            aboutTextView.becomeFirstResponder()
        } else if linkTextFields.first?.isEditing ?? false {
            airportTextField.becomeFirstResponder()
        } else {
            for (index, field) in linkTextFields.enumerated() where field.isEditing {
                let prevIndex = index - 1
                if prevIndex >= 0 {
                    linkTextFields[prevIndex].becomeFirstResponder()
                }
            }
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    @IBAction func toolbarNextTapped(_ sender: UIBarButtonItem) {
        let linkTextFields = linksStack.linkTextFields

        if firstNameTextField.isEditing {
            lastNameTextField.becomeFirstResponder()
        } else if lastNameTextField.isEditing {
            birthdayTextField.becomeFirstResponder()
        } else if birthdayTextField.isEditing {
            genderTextField.becomeFirstResponder()
        } else if genderTextField.isEditing {
            countryTextField.becomeFirstResponder()
        } else if countryTextField.isEditing {
            if isLocationVisible {
                locationTextField.becomeFirstResponder()
            } else {
                emailTextField.becomeFirstResponder()
            }
        } else if locationTextField.isEditing {
            emailTextField.becomeFirstResponder()
        } else if emailTextField.isEditing {
            aboutTextView.becomeFirstResponder()
        } else if aboutTextView.isFirstResponder {
            airportTextField.becomeFirstResponder()
       } else if airportTextField.isEditing {
            if let next = linkTextFields.first {
                next.becomeFirstResponder()
            } else {
                view.endEditing(true)
                updateSave(showError: false)
            }
        } else {
            for (index, field) in linkTextFields.enumerated() where field.isEditing {
                let nextIndex = index + 1
                if nextIndex < linkTextFields.count {
                    linkTextFields[nextIndex].becomeFirstResponder()
                } else {
                    view.endEditing(true)
                    updateSave(showError: false)
                }
                return
            }
        }
    }

    @IBAction func toolbarClearTapped(_ sender: UIBarButtonItem) {
        if birthdayTextField.isEditing {
            birthdayTextField.text = nil
            current.birthday = nil
        }
        view.endEditing(true)
        updateSave(showError: false)
    }

    @IBAction func toolbarDoneTapped(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        updateSave(showError: false)
    }

    @IBAction func birthdayChanged(_ sender: UIDatePicker) {
        let birthday = DateFormatter.mtpDay.string(from: sender.date)
        birthdayTextField.text = birthday
        current.birthday = birthday
        updateSave(showError: false)
    }

    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        guard updateSave(showError: true) else { return }

        upload(payload: current)
    }

    @objc func textFieldDidChange() {
        updateSave(showError: false)
    }

    @discardableResult func updateSave(showError: Bool) -> Bool {
        current.first_name = firstNameTextField.text ?? ""
        current.last_name = lastNameTextField.text ?? ""
        // birthday, gender, country, location expected set here
        if let text = current.birthday, text.isEmpty {
            current.birthday = nil
        }
        current.email = emailTextField.text ?? ""
        current.bio = aboutTextView.text ?? ""
        current.airport = airportTextField.text ?? ""
        let linksValid = updateLinks()

        let errorMessage: String
        if current.first_name.isEmpty {
            errorMessage = L.fixFirstName()
        } else if current.last_name.isEmpty {
            errorMessage = L.fixLastName()
        // } else if current.birthday.isEmpty {
            // errorMessage = L.fixBirthday()
        //} else if current.gender.isEmpty {
            // errorMessage = L.fixGender()
        //} else if current.country_id == 0 {
            // errorMessage = L.fixCountry()
        //} else if current.location_id == 0 {
            // errorMessage = L.fixLocation()
        } else if !(current.email ?? "").isValidEmail {
            errorMessage = L.fixEmail()
        } else if current.bio?.isEmpty ?? true {
            errorMessage = L.fixBio()
        //} else if current.airport?.isEmpty ?? true {
            // errorMessage = L.fixAirport()
        } else if !linksValid {
            errorMessage = L.fixLinks()
        } else {
            errorMessage = ""
        }
        let valid = errorMessage.isEmpty

        if showError && !valid {
            note.message(error: errorMessage)
        }

        if original == current {
            saveButton.isEnabled = false
            return false
        } else {
            saveButton.isEnabled = true
            return valid
        }
    }

    func updateLinks() -> Bool {
        let views = linksStack.arrangedSubviews
        guard let links = current.links,
              links.count == views.count else { return false }

        var valid = true
        for (index, view) in views.enumerated() {
            let link = Link(text: view.linkDescription,
                            url: view.linkUrl)
            current.links?[index] = link
            valid = valid && !link.text.isEmpty && !link.url.isEmpty
        }

        return valid
    }

    func upload(payload: UserUpdatePayload) {
        note.modal(info: L.updatingProfile())

        net.userUpdate(payload: payload) { [weak self, note] result in
            switch result {
            case .success:
                note.modal(success: L.success())
                DispatchQueue.main.asyncAfter(deadline: .short) { [weak self] in
                    note.dismissModal()
                    self?.performSegue(withIdentifier: Segues.cancelEdits, sender: self)
                }
                return
            case .failure(let error):
                note.modal(failure: error,
                           operation: L.updateProfile())
            }
        }
    }

    @IBAction func avatarTapped(_ sender: UIButton) {
        // push segue to Profile Photos in storyboard
    }

    @IBAction func deleteLinkTapped(_ sender: UIButton) {
        view.endEditing(true)
        let remove = sender.tag
        current.links?.remove(at: remove)

        tableView.update {
            let view = linksStack.arrangedSubviews[remove]
            linksStack.removeArrangedSubview(view)
            view.removeFromSuperview()

            for (index, link) in linksStack.arrangedSubviews.enumerated() {
                link.linkDeleteButton?.tag = index
            }
        }

        updateSave(showError: false)
    }

    @IBAction func addLinkTapped(_ sender: UIButton) {
        view.endEditing(true)

        let link = Link()
        var links = current.links ?? []
        let end = links.count
        links.append(link)
        current.links = links

        tableView.update {
            display(row: end, link: link)
        }

        updateSave(showError: false)
    }
}

// MARK: - PhotoSelectionDelegate

extension EditProfileVC: PhotoSelectionDelegate {

    /// Notify of selection
    /// - Parameter picture: Selected picture
    func selected(picture: String) {
        current.picture = picture
        avatarButton.load(image: current)
        updateSave(showError: false)
    }
}

// MARK: - LocationSearchDelegate

extension EditProfileVC: LocationSearchDelegate {

    /// Handle a location selection
    /// - Parameters:
    ///   - controller: source of selection
    ///   - item: Country or Location selected
    func locationSearch(controller: RealmSearchViewController,
                        didSelect item: Object) {
        switch item {
        case let countryItem as Country:
            guard country != countryItem else { return }

            if countryItem.countryId > 0 {
                country = countryItem
                current.country_id = countryItem.countryId
                current.location_id = countryItem.countryId
                countryTextField.text = countryItem.placeCountry
            } else {
                country = nil
                current.country_id = 0
                current.location_id = 0
               countryTextField.text = L.preferNot()
            }
            location = nil
            locationTextField.text = nil
            show(location: countryItem.hasChildren)
        case let locationItem as Location:
            guard location != locationItem else { return }

            location = locationItem
            locationTextField.text = locationItem.placeTitle
            current.country_id = locationItem.countryId
            current.location_id = locationItem.placeId
        default:
            log.error("unknown item type selected")
        }
        updateSave(showError: false)
    }
}

// MARK: - UIPickerViewDataSource

extension EditProfileVC: UIPickerViewDataSource {

    /// Number of picker components
    /// - Parameter pickerView: Picker view
    /// - Returns: 1
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    /// Number of rows in picker component
    /// - Parameters:
    ///   - pickerView: Picker view
    ///   - component: Index
    /// - Returns: Value
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        genders.count
    }
}

// MARK: - UIPickerViewDelegate

extension EditProfileVC: UIPickerViewDelegate {

    /// :nodoc:
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        genders[row]
    }

    /// :nodoc:
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        guard row > 0 else { return }

        genderTextField.text = genders[row]
        let gender: String
        switch genderTextField.text?.first {
        case "M": gender = "M"
        case "F": gender = "F"
        default: gender = "U"
        }
        current.gender = gender
        genderTextField.resignFirstResponder()
        updateSave(showError: false)
    }
}

// MARK: - Exposing

extension EditProfileVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        UIEditProfile.close.expose(item: closeButton)
        UIEditProfile.save.expose(item: saveButton)

        UIEditProfile.avatar.expose(item: avatarButton)
        UIEditProfile.first.expose(item: firstNameTextField)
        UIEditProfile.last.expose(item: lastNameTextField)
        UIEditProfile.birthday.expose(item: birthdayTextField)
        UIEditProfile.gender.expose(item: genderTextField)
        UIEditProfile.country.expose(item: countryTextField)
        UIEditProfile.location.expose(item: locationTextField)
        UIEditProfile.email.expose(item: emailTextField)
        UIEditProfile.about.expose(item: aboutTextView)
        UIEditProfile.airport.expose(item: airportTextField)
        UIEditProfile.linkAdd.expose(item: addLinkButton)

        UIKeyboard.toolbar.expose(item: keyboardToolbar)
        UIKeyboard.back.expose(item: toolbarBackButton)
        UIKeyboard.clear.expose(item: toolbarClearButton)
        UIKeyboard.done.expose(item: toolbarDoneButton)
        UIKeyboard.next.expose(item: toolbarNextButton)
    }
}

// MARK: - InterfaceBuildable

extension EditProfileVC: InterfaceBuildable {

    /// Injection enforcement for viewDidLoad
    func requireOutlets() {
        aboutTextView.require()
        addLinkButton.require()
        airportTextField.require()
        avatarButton.require()
        birthdayTextField.require()
        closeButton.require()
        countryStack.require()
        countryTextField.require()
        emailTextField.require()
        firstNameTextField.require()
        genderTextField.require()
        infoStack.require()
        keyboardToolbar.require()
        lastNameTextField.require()
        linksStack.require()
        locationStack.require()
        locationTextField.require()
        saveButton.require()
        toolbarBackButton.require()
        toolbarClearButton.require()
        toolbarDoneButton.require()
        toolbarNextButton.require()
    }
}

private extension InsetTextField {

    func styleForEditProfile() {
        hInset = 8
        vInset = 4
        borderStyle = .none
        returnKeyType = .done

        if self is InsetTextFieldGradient {
            cornerRadius = 15
            textColor = .white
            font = Avenir.medium.of(size: 16)
            placeholder = L.linkUrl()
            keyboardType = .URL
            textContentType = .URL
            autocapitalizationType = .none
            autocorrectionType = .no
            spellCheckingType = .no
        } else {
            cornerRadius = 3
            borderWidth = 1
            borderColor = .alto
            font = Avenir.book.of(size: 16)
            placeholder = L.linkTitle()
        }
    }
}

private extension UIStackView {

    var linkTextFields: [UITextField] {
        arrangedSubviews.flatMap {
            [ $0.linkDescriptionField,
              $0.linkUrlField, ].compactMap { $0 }
        }
    }
}

private extension UIView {

    var linkViews: [UIView] {
        (self as? UIStackView)?.arrangedSubviews ?? []
    }

    var linkDescriptionField: UITextField? {
        linkViews.first as? UITextField
    }

    var linkUrlView: UIView? {
        linkViews.last
    }

    var linkDescription: String {
        linkDescriptionField?.text ?? ""
    }

    var linkUrlField: UITextField? {
        linkUrlView?.subviews.first { $0 is UITextField } as? UITextField
    }

    var linkUrl: String {
        linkUrlField?.text ?? ""
    }

    var linkDeleteButton: UIButton? {
        let button = linkUrlView?.subviews.first { $0 is UIButton }
        return button as? UIButton
    }
}

extension UIBarButtonItem {

    /// Control visibility by drawing clear
    var isHidden: Bool {
        get { tintColor == .clear }
        set {
            tintColor = newValue ? .clear : nil
            isEnabled = !newValue
            isAccessibilityElement = !newValue
        }
    }
}
