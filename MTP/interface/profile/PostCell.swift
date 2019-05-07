// @copyright Trollwerks Inc.

import Anchorage

protocol PostCellDelegate: AnyObject {

    func toggle(index: Int)
}

struct PostCellModel {

    let index: Int
    let location: Location?
    let date: String
    let title: String
    let body: String
    var isExpanded: Bool
}

final class PostCell: UICollectionViewCell, ServiceProvider {

    static let reuseIdentifier = NSStringFromClass(PostCell.self)

    private let holder = UIView()
    private var holderHeight: NSLayoutConstraint?
    private var holderWidth: NSLayoutConstraint? {
        didSet {
            holderWidth?.isActive = false
        }
    }
    private var maxWidth: CGFloat? = nil {
        didSet {
            guard let maxWidth = maxWidth else { return }
            holderWidth?.isActive = true
            holderWidth?.constant = maxWidth
        }
    }

    private let imageView = UIImageView()

    private let textView = UITextView {
        $0.isEditable = false
        $0.isSelectable = false
        $0.isScrollEnabled = false
        $0.textContainerInset = .zero
        $0.textContainer.lineFragmentPadding = 0
    }

    private weak var delegate: PostCellDelegate?

    private var model: PostCellModel?

    private let layout = (
        height: (cell: CGFloat(100),
                 image: CGFloat(96)),
        padding: CGFloat(6),
        text: (lines: (compressed: 5,
                       expanded: 0),
               date: (font: Avenir.medium.of(size: 13),
                      color: UIColor.darkGray),
               title: (font: Avenir.heavy.of(size: 18),
                       color: UIColor.darkGray),
               body: (font: Avenir.medium.of(size: 14),
                      color: UIColor.darkGray))
    )

    override init(frame: CGRect) {
        super.init(frame: frame)

        enableSelfSizing()
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(model: PostCellModel,
             delegate: PostCellDelegate,
             width: CGFloat) {
        self.model = model
        self.delegate = delegate
        maxWidth = width

        setImage(html: model.body)
        setText(title: model.title,
                date: model.date,
                html: model.body)
        set(expanded: model.isExpanded)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        delegate = nil
        model = nil
        imageView.prepareForReuse()
        textView.text = nil
        set(expanded: true)
    }
}

private extension PostCell {

    func enableSelfSizing() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.edgeAnchors == edgeAnchors
    }

    func configure() {
        contentView.addSubview(holder)
        holder.edgeAnchors == contentView.edgeAnchors
        holderWidth = holder.widthAnchor == 300
        holderHeight = holder.heightAnchor == layout.height.cell

        holder.addSubview(textView)
        textView.edgeAnchors == holder.edgeAnchors

        holder.addSubview(imageView)
        imageView.topAnchor == holder.topAnchor
        imageView.leftAnchor == holder.leftAnchor
        imageView.sizeAnchors == CGSize(width: layout.height.image,
                                        height: layout.height.image)

        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(tapped))
        addGestureRecognizer(tap)
    }

    func setImage(html: String) {
        if imageView.set(thumbnail: html) {
            imageView.isHidden = false
            let exclude = imageView.frame.insetBy(dx: -layout.padding, dy: 0)
            let imagePath = UIBezierPath(rect: exclude)
            textView.textContainer.exclusionPaths = [imagePath]
        } else {
            imageView.isHidden = true
            textView.textContainer.exclusionPaths = []
        }
    }

    func setText(title: String,
                 date: String,
                 html: String) {
        let text = NSMutableAttributedString()
        text.append("\(date)\n".attributed(
                font: layout.text.date.font,
                color: layout.text.date.color
            )
        )
        text.append("\(title)\n".attributed(
            font: layout.text.title.font,
            color: layout.text.title.color
            )
        )

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

    func set(expanded: Bool) {
        if expanded {
            textView.textContainer.maximumNumberOfLines = layout.text.lines.expanded
            textView.textContainer.lineBreakMode = .byWordWrapping
            holderHeight?.isActive = false
        } else {
            textView.textContainer.maximumNumberOfLines = layout.text.lines.compressed
            textView.textContainer.lineBreakMode = .byTruncatingTail
            holderHeight?.isActive = true
        }
    }

    @objc func tapped(_ sender: UIGestureRecognizer) {
        guard let model = model else { return }

        delegate?.toggle(index: model.index)
    }
}
