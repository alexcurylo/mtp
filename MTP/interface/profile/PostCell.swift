// @copyright Trollwerks Inc.

import Anchorage

protocol PostCellDelegate: AnyObject {

    func toggle(index: Int)
}

struct PostCellModel {

    let index: Int
    let photo: Photo?
    let location: Location?
    let date: String
    let title: String
    let body: String
    var isExpanded: Bool
}

final class PostCell: UICollectionViewCell {

    @IBOutlet private var imageView: UIImageView?
    @IBOutlet private var imageViewWidthConstraint: NSLayoutConstraint?

    @IBOutlet private var dateLabel: UILabel?
    @IBOutlet private var titleLabel: UILabel?
    @IBOutlet private var bodyLabel: UILabel?

    weak var delegate: PostCellDelegate?

    private var model: PostCellModel?

    private var widthConstraint: NSLayoutConstraint?

    private let layout = (
        imageWidth: (displayed: CGFloat(100),
                     empty: CGFloat(0)),
        textLines: (compressed: 3,
                    expanded: 0)
    )

    override func awakeFromNib() {
        super.awakeFromNib()

        configure()
    }

    func set(model: PostCellModel,
             delegate: PostCellDelegate,
             width: CGFloat) {
        self.model = model
        self.delegate = delegate

        if let photo = model.photo {
            imageView?.set(thumbnail: photo)
            imageViewWidthConstraint?.constant = layout.imageWidth.displayed
        } else {
            imageView?.image = nil
            imageViewWidthConstraint?.constant = layout.imageWidth.empty
        }
        dateLabel?.text = model.date
        titleLabel?.text = model.title

        if let attributed = model.body.html2Attributed {
            let attributes = NSAttributedString.attributes(
                color: bodyLabel?.textColor ?? .darkText,
                font: bodyLabel?.font ?? Avenir.medium.of(size: 13)
            )
            attributed.addAttributes(attributes, range: attributed.fullRange)
            bodyLabel?.attributedText = attributed
        } else {
            bodyLabel?.text = model.body
        }
        configureLabel()

        widthConstraint?.constant = width
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        delegate = nil
        model = nil
        imageView?.prepareForReuse()
        dateLabel?.text = nil
        titleLabel?.text = nil
        bodyLabel?.text = nil
        bodyLabel?.numberOfLines = layout.textLines.compressed
    }
}

private extension PostCell {

    func configure() {
        contentView.centerAnchors == centerAnchors
        widthConstraint = contentView.widthAnchor == 0

        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(tapped))
        addGestureRecognizer(tap)
    }

    func configureLabel() {
        guard let model = model,
            let label = bodyLabel else { return }
        if model.isExpanded {
            label.numberOfLines = layout.textLines.expanded
            label.lineBreakMode = .byWordWrapping
        } else {
            label.numberOfLines = layout.textLines.compressed
            label.lineBreakMode = .byTruncatingTail
        }
    }

    @objc func tapped(_ sender: UIGestureRecognizer) {
        guard let index = model?.index else { return }

        model?.isExpanded.toggle()
        configureLabel()
        delegate?.toggle(index: index)
    }
}
