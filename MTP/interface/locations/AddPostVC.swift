// @copyright Trollwerks Inc.

import RealmSwift

/// Handles creation and uploading of new posts to MTP
final class AddPostVC: UIViewController {

    private typealias Segues = R.segue.addPostVC

    // verified in requireOutlets
    @IBOutlet private var closeButton: UIBarButtonItem!
    @IBOutlet private var saveButton: UIBarButtonItem!
    @IBOutlet private var locationStack: UIStackView!
    @IBOutlet private var locationLine: UIStackView!
    @IBOutlet private var countryLabel: UILabel!
    @IBOutlet private var locationLabel: UILabel!
    @IBOutlet private var postTitle: UILabel!
    @IBOutlet private var postTextView: TopLoadingTextView!

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

    private var countryId: Int? {
        didSet {
            country = data.get(country: countryId)
        }
    }
    private var locationId: Int? {
        didSet {
            location = data.get(location: locationId)
        }
    }
    private var updating: PostCellModel? {
        didSet {
            countryId = updating?.location?.countryId
            locationId = updating?.location?.placeId
            payload.post = updating?.body ?? ""
        }
    }

    private let minCharacters = 140
    private var payload = PostPayload()

    /// :nodoc:
    override func viewDidLoad() {
        super.viewDidLoad()
        requireOutlets()
        requireInjection()

        configure()
        startKeyboardListening()
    }

    /// :nodoc:
    deinit {
        stopKeyboardListening()
    }

    /// Prepare for reveal
    /// - Parameter animated: Whether animating
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        show(navBar: animated, style: .standard)
        expose()
    }

    /// Actions to take after reveal
    /// - Parameter animated: Whether animating
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        report(screen: "Add Post")

        if updating != nil, !net.isConnected {
            let question = L.continueOffline(L.updatePost())
            note.ask(question: question) { [weak self] answer in
                if !answer {
                    self?.performSegue(withIdentifier: Segues.pop,
                                       sender: self)
                }
            }
        }
    }

    /// Stop editing on touch
    /// - Parameters:
    ///   - touches: User touches
    ///   - event: Touch event
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        view.endEditing(true)
    }

    /// Instrument and inject navigation
    /// - Parameters:
    ///   - segue: Navigation action
    ///   - sender: Action originator
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let target = Segues.showCountry(segue: segue)?
                              .destination
                              .topViewController as? LocationSearchVC {
            target.inject(mode: .country,
                          styler: .standard,
                          delegate: self)
        } else if let target = Segues.showLocation(segue: segue)?
                                     .destination
                                     .topViewController as? LocationSearchVC,
                  let countryId = countryId {
            target.inject(mode: .location(country: countryId),
                          styler: .standard,
                          delegate: self)
        }
    }
}

// MARK: - Private

private extension AddPostVC {

    func configure() {
        if let updating = updating {
            navigationItem.title = L.editPost()
            postTextView.text = updating.body
        } else {
            navigationItem.title = L.addPost()
        }

        configureLocation()
        updateSave(showError: false)
        updateRemaining()
    }

    func configureLocation() {
        countryLabel.text = country?.placeCountry ?? L.selectCountry()

        if let country = country, country.hasChildren {
            locationLabel.text = location?.placeTitle ?? L.selectLocation()
            locationStack.addArrangedSubview(locationLine)
        } else {
            locationLabel.text = countryLabel.text
            locationStack.removeArrangedSubview(locationLine)
            locationLine.removeFromSuperview()
        }
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

    @discardableResult func updateSave(showError: Bool) -> Bool {
        payload.post = postTextView.text ?? ""

        let errorMessage: String
        if payload.post.count < minCharacters {
            errorMessage = L.fixLength(minCharacters)
        } else if !payload.location.isValid {
            errorMessage = L.fixLocationContent()
        } else {
            errorMessage = ""
        }
        let valid = errorMessage.isEmpty

        if showError && !valid {
            note.message(error: errorMessage)
        }

        let changed: Bool
        if let updating = updating {
            changed = payload.post != updating.body ||
                      countryId != updating.location?.countryId ||
                      locationId != updating.location?.placeId
        } else {
            changed = true
        }

        saveButton.isEnabled = valid && changed
        return valid
    }

    func updateRemaining() {
        let remaining = max(0, minCharacters - payload.post.count)
        if remaining > 0 {
            postTitle.text = L.postShort(remaining)
        } else {
            postTitle.text = L.postLong()
        }
    }

    func upload() {
        net.postPublish(payload: payload) { [weak self] _ in
            self?.performSegue(withIdentifier: Segues.pop, sender: self)
        }
    }

    func update() {
        guard let updating = updating else { return }

        let update = PostUpdatePayload(from: updating,
                                       with: payload)

        note.modal(info: L.updatingPost())

        net.postUpdate(payload: update) { [weak self, note] result in
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
                           operation: L.updatePost())
            }
        }
    }

    func finishUpdate() {
        guard let updating = updating,
              let locationId = locationId,
              let post = data.get(post: updating.postId),
              let realm = try? Realm() else { return }

        let oldLocation = updating.location?.placeId
        do {
            try realm.write {
                post.locationId = locationId
                post.post = payload.post
            }
        } catch {
            log.error("Edit Post error: \(error)")
        }
        if oldLocation != locationId {
            data.notify(change: .locationPosts, object: oldLocation)
            data.notify(change: .locationPosts, object: locationId)
        }
        data.notify(change: .posts, object: locationId)

        performSegue(withIdentifier: Segues.pop, sender: self)
    }
}

// MARK: - LocationSearchDelegate

extension AddPostVC: LocationSearchDelegate {

    /// Handle a location selection
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

extension AddPostVC: UITextViewDelegate {

    /// Respond to edit beginning
    /// - Parameter textView: Active edit target
    func textViewDidBeginEditing(_ textView: UITextView) { }

    /// Update remaining count
    /// - Parameter textView: Active edit target
    func textViewDidChange(_ textView: UITextView) {
        updateSave(showError: false)
        updateRemaining()
    }

    /// Respond to edit ending
    /// - Parameter textView: Active edit target
    func textViewDidEndEditing(_ textView: UITextView) { }
}

// MARK: - KeyboardListener

extension AddPostVC: KeyboardListener {

    /// Scroll view for keyboard avoidance
    var keyboardScrollee: UIScrollView? { return postTextView }
}

// MARK: - Exposing

extension AddPostVC: Exposing {

    /// Expose controls to UI tests
    func expose() {
        UIAddPost.close.expose(item: closeButton)
        UIAddPost.save.expose(item: saveButton)

        UIAddPost.country.expose(item: countryLabel)
        UIAddPost.location.expose(item: locationLabel)
        UIAddPost.post.expose(item: postTextView)
    }
}

// MARK: - InterfaceBuildable

extension AddPostVC: InterfaceBuildable {

    /// Injection enforcement for viewDidLoad
    func requireOutlets() {
        closeButton.require()
        countryLabel.require()
        locationLabel.require()
        locationLine.require()
        locationStack.require()
        postTitle.require()
        postTextView.require()
        saveButton.require()
    }
}

// MARK: - Injectable

extension AddPostVC: Injectable {

    /// Injected dependencies
    typealias Model = (post: PostCellModel?, mappable: Mappable?)

    /// Handle dependency injection
    /// - Parameter model: Dependencies
    func inject(model: Model) {
        if let post = model.post {
            updating = post
        } else {
            countryId = model.mappable?.location?.countryId
            locationId = model.mappable?.location?.placeId
        }
    }

    /// Enforce dependency injection
    func requireInjection() { }
}
