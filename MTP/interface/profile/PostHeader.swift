// @copyright Trollwerks Inc.

import Anchorage

/// Actions triggered by post cell
protocol PostHeaderDelegate: AnyObject {

    /// Add button tapped
    func addTapped()
    /// Network button tapped
    func queueTapped()
}

/// Header of post table
final class PostHeader: UITableViewHeaderFooterView, ServiceProvider {

    /// Dequeueing identifier
    static let reuseIdentifier = NSStringFromClass(PostHeader.self)

    // Model for which buttons to display
    typealias Model = (add: Bool, queue: Bool)

    private let addButton = GradientButton {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.orientation = GradientOrientation.horizontal.rawValue
        $0.startColor = .dodgerBlue
        $0.endColor = .azureRadiance
        $0.cornerRadius = 4

        let title = L.addPost()
        $0.setTitle(title, for: .normal)
        $0.titleLabel?.font = Avenir.medium.of(size: 15)
        UIPosts.add.expose(item: $0)
    }

    private let queueButton = UIButton {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.cornerRadius = 4
        $0.setImage(R.image.upload(), for: .normal)
        $0.tintColor = .white
        $0.titleLabel?.font = Avenir.mediumOblique.of(size: 15)
        $0.setInsets(gap: 8)
    }

    private weak var delegate: PostHeaderDelegate?
    private var connectionObserver: Observer?

    /// :nodoc:
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        let buttons = UIStackView(arrangedSubviews: [addButton,
                                                     queueButton
                                                     ]).with {
            $0.axis = .vertical
            $0.spacing = 8
            $0.distribution = .fillEqually
        }
        contentView.addSubview(buttons)
        buttons.edgeAnchors == edgeAnchors + EdgeInsets(top: 8,
                                                        left: 8,
                                                        bottom: 0,
                                                        right: 8)
        addButton.addTarget(self,
                            action: #selector(addTapped),
                            for: .touchUpInside)
        queueButton.addTarget(self,
                              action: #selector(queueTapped),
                              for: .touchUpInside)
}

    /// :nodoc:
    required init?(coder: NSCoder) {
        return nil
    }

    /// Empty display
    override func prepareForReuse() {
        super.prepareForReuse()

        delegate = nil
    }

    /// Handle dependency injection
    ///
    /// - Parameters:
    ///   - model: Show add button and/or queue button?
    ///   - delegate: Delegate
    func inject(model: Model,
                delegate: PostsVC) {
        self.delegate = delegate
        addButton.isHidden = !model.add
        queueButton.isHidden = !model.queue
        if model.queue {
            setQueueState()
        }
    }
}

// MARK: - Private

private extension PostHeader {

    @IBAction func addTapped(_ sender: GradientButton) {
        delegate?.addTapped()
    }

    @IBAction func queueTapped(_ sender: UIButton) {
        delegate?.queueTapped()
    }

     func setQueueState() {
        guard !queueButton.isHidden else { return }

        let title: String
        let color: UIColor
        if net.isConnected {
            title = L.queued()
            color = .visited
        } else {
            title = L.notConnected()
            color = .carnation
        }
        queueButton.backgroundColor = color
        queueButton.setTitle(title, for: .normal)
    }

    func observe() {
        guard connectionObserver == nil else { return }

        connectionObserver = net.observer(of: .connection) { [weak self] _ in
            self?.setQueueState()
        }
    }
}
