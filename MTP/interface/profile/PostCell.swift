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

    @IBOutlet private var holder: UIView?
    @IBOutlet private var holderWidth: NSLayoutConstraint? {
        didSet {
            holderWidth?.isActive = false
        }
    }
    @IBOutlet private var holderHeight: NSLayoutConstraint?

    @IBOutlet private var imageView: UIImageView?
    @IBOutlet private var textView: UITextView?

    private var maxWidth: CGFloat? = nil {
        didSet {
            guard let maxWidth = maxWidth else { return }
            holderWidth?.isActive = true
            holderWidth?.constant = maxWidth
        }
    }

    private weak var delegate: PostCellDelegate?

    private var model: PostCellModel?

    private let layout = (
        compressedHeight: CGFloat(100),
        imageWidth: (displayed: CGFloat(100),
                     empty: CGFloat(0)),
        textLines: (compressed: 5,
                    expanded: 0)
    )

    override func awakeFromNib() {
        super.awakeFromNib()

        enableSelfSizing()
        configure()
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
        imageView?.prepareForReuse()
        textView?.text = nil
        textView?.textContainer.maximumNumberOfLines = layout.textLines.compressed
    }
}

private extension PostCell {

    func enableSelfSizing() {
        translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.edgeAnchors == edgeAnchors
    }

    func configure() {
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(tapped))
        addGestureRecognizer(tap)
    }

    func setImage(html: String) {
        guard let imageView = imageView,
              let textView = textView else { return }

        if imageView.set(thumbnail: html) {
            imageView.isHidden = false
            let imagePath = UIBezierPath(rect: imageView.frame)
            textView.textContainer.exclusionPaths = [imagePath]
        } else {
            imageView.isHidden = true
            textView.textContainer.exclusionPaths = []
        }
    }

    func setText(title: String,
                 date: String,
                 html: String) {
        guard let textView = textView else { return }

        let body = NSMutableAttributedString()
        body.append("\(date)\n".attributed(
                font: Avenir.medium.of(size: 13),
                color: .darkGray
            )
        )
        body.append("\(title)\n".attributed(
                font: Avenir.heavy.of(size: 18),
                color: .darkText
            )
        )

        if let text = html.html2Attributed(
            font: Avenir.medium.of(size: 13),
            color: .darkText
        ) {
            body.append(text)
        } else {
            body.append(html.attributed(
                    font: Avenir.medium.of(size: 13),
                    color: .darkText
                )
            )
        }

        textView.attributedText = body
    }

    func set(expanded: Bool) {
        guard let textView = textView else { return }

        if expanded {
            textView.textContainer.maximumNumberOfLines = layout.textLines.expanded
            textView.textContainer.lineBreakMode = .byWordWrapping
            holderHeight?.constant = 180
            holderHeight?.isActive = false
        } else {
            textView.textContainer.maximumNumberOfLines = layout.textLines.compressed
            textView.textContainer.lineBreakMode = .byTruncatingTail
            holderHeight?.constant = layout.compressedHeight
            holderHeight?.isActive = true
        }
    }

    @objc func tapped(_ sender: UIGestureRecognizer) {
        guard let model = model else { return }

        delegate?.toggle(index: model.index)
    }
}
