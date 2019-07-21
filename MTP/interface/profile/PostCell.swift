// @copyright Trollwerks Inc.

import Anchorage

protocol PostCellDelegate: AnyObject {

    func tapped(profile user: User)
    func tapped(toggle: Int)
}

enum Presenter {

    case location
    case user
}

struct PostCellModel {

    let index: Int
    let date: String
    let title: String
    let body: String
    let presenter: Presenter
    let location: Location?
    let user: User?
    var isExpanded: Bool
}

final class PostCell: UITableViewCell, ServiceProvider {

    @IBOutlet private var holder: UIView?
    private let postImageView = UIImageView()
    private let dateLabel = UILabel {
        $0.font = Avenir.medium.of(size: 13)
        $0.textColor = .darkGray
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    private let titleLabel = UILabel {
        $0.font = Avenir.heavy.of(size: 18)
        $0.textColor = .darkGray
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    private let button = UIButton {
        $0.setImage(R.image.buttonAirplane(), for: .normal)
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }
    private var headerStack: UIStackView?
    private let textView = LinkTappableTextView()

    private var model: PostCellModel?
    private weak var delegate: PostCellDelegate?

    private let layout = (
        height: (cell: CGFloat(100),
                 image: CGFloat(40)),
        rounding: (user: CGFloat(20),
                   post: CGFloat(4)),
        padding: CGFloat(6),
        text: (lines: (compressed: 3,
                       expanded: 0),
               body: (font: Avenir.medium.of(size: 14),
                      color: UIColor.darkGray))
    )

    override func awakeFromNib() {
        super.awakeFromNib()

        configure()
    }

    func set(model: PostCellModel,
             delegate: PostCellDelegate) {
        self.model = model
        self.delegate = delegate

        let hasImage: Bool
        let canLink: Bool
        switch (model.presenter, model.user) {
        case (.location, let user?):
            hasImage = true
            canLink = true
            setImage(user: user)
            postImageView.cornerRadius = layout.rounding.user
        case (.location, _):
            hasImage = false
            canLink = false
        case (.user, _):
            hasImage = postImageView.load(image: model.body)
            postImageView.cornerRadius = layout.rounding.post
            canLink = false
        }
        if hasImage {
            headerStack?.insertArrangedSubview(postImageView, at: 0)
        } else {
           postImageView.image = nil
           headerStack?.removeArrangedSubview(postImageView)
           postImageView.removeFromSuperview()
        }

        if canLink {
            headerStack?.addArrangedSubview(button)
        } else {
            headerStack?.removeArrangedSubview(button)
            button.removeFromSuperview()
        }

        dateLabel.text = model.date

        titleLabel.text = model.title

        setText(html: model.body)

        setExpanded()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        model = nil
        delegate = nil
        postImageView.prepareForReuse()
        dateLabel.text = nil
        titleLabel.text = nil
        textView.text = nil
        setExpanded()
    }
}

private extension PostCell {

    func configure() {
        let container = holder.require()

        let contents = configureContents()
        container.addSubview(contents)
        contents.edgeAnchors == container.edgeAnchors + layout.padding

        setExpanded()

        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(toggleTapped))
        addGestureRecognizer(tap)
    }

    func configureContents() -> UIStackView {
        let header = configureHeader()
        headerStack = header
        let contents = UIStackView(arrangedSubviews: [header,
                                                      textView]).with {
            $0.axis = .vertical
            $0.spacing = 0
        }

        return contents
    }

    func configureHeader() -> UIStackView {
        postImageView.sizeAnchors == CGSize(width: layout.height.image,
                                            height: layout.height.image)
        let texts = configureTexts()
        button.addTarget(self,
                         action: #selector(airplaneTapped),
                         for: .touchUpInside)

        let header = UIStackView(arrangedSubviews: [postImageView,
                                                    texts,
                                                    button]).with {
            $0.axis = .horizontal
            $0.alignment = .top
            $0.spacing = layout.padding
            $0.setContentHuggingPriority(.required, for: .vertical)
        }

        return header
    }

    func configureTexts() -> UIStackView {
        let texts = UIStackView(arrangedSubviews: [dateLabel,
                                                   titleLabel]).with {
            $0.axis = .vertical
            $0.spacing = 0
            $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        }
        return texts
    }

    func setImage(user: User) {
        if user.imageUrl != nil {
            postImageView.load(image: user)
        } else {
            postImageView.image = user.placeholder
            net.loadUser(id: user.userId) { [weak self] result in
                if case let .success(update) = result {
                    self?.postImageView.load(image: update)
                }
            }
        }
    }

    func setText(html: String) {
        let text = NSMutableAttributedString()
        if let body = html.html2Attributed(
            font: layout.text.body.font,
            color: layout.text.body.color
            )?.trimmed {
            text.append(body)
        } else {
            text.append(html.attributed(
                    font: layout.text.body.font,
                    color: layout.text.body.color
                )
            )
        }
        textView.attributedText = text
    }

    @objc func airplaneTapped(_ sender: UIButton) {
        if let user = model?.user {
            delegate?.tapped(profile: user)
        }
    }

    @objc func toggleTapped(_ sender: UIGestureRecognizer) {
        model?.isExpanded.toggle()
        guard let model = model else { return }

        delegate?.tapped(toggle: model.index)
    }

    func setExpanded() {
        let expanded = model?.isExpanded ?? false
        set(expanded: expanded)
    }

    func set(expanded: Bool) {
        if expanded {
            textView.textContainer.maximumNumberOfLines = layout.text.lines.expanded
            textView.textContainer.lineBreakMode = .byWordWrapping
        } else {
            textView.textContainer.maximumNumberOfLines = layout.text.lines.compressed
            textView.textContainer.lineBreakMode = .byTruncatingTail
        }
    }
}
