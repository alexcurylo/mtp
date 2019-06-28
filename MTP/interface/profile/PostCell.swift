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

final class PostCell: UITableViewCell, ServiceProvider {

    @IBOutlet private var holder: UIView?

    private let postImageView = UIImageView {
        $0.cornerRadius = 5
    }

    private let textView = LinkTappableTextView()

    private var model: PostCellModel?
    private weak var delegate: PostCellDelegate?

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

    override func awakeFromNib() {
        super.awakeFromNib()

        configure()
    }

    func set(model: PostCellModel,
             delegate: PostCellDelegate) {
        self.model = model
        self.delegate = delegate

        setImage(html: model.body)
        setText(title: model.title,
                date: model.date,
                html: model.body)
        setExpanded()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        model = nil
        delegate = nil
        postImageView.prepareForReuse()
        textView.text = nil
        setExpanded()
    }
}

private extension PostCell {

    func configure() {
        let container = holder.require()
        container.addSubview(textView)
        textView.edgeAnchors == container.edgeAnchors + layout.padding

        container.addSubview(postImageView)
        postImageView.topAnchor == container.topAnchor + layout.padding
        postImageView.leftAnchor == container.leftAnchor + layout.padding
        postImageView.sizeAnchors == CGSize(width: layout.height.image,
                                            height: layout.height.image)

        setExpanded()

        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(tapped))
        addGestureRecognizer(tap)
    }

    func setImage(html: String) {
        if postImageView.load(image: html) {
            postImageView.isHidden = false
            let exclude = postImageView.frame.insetBy(dx: -layout.padding, dy: 0)
            let imagePath = UIBezierPath(rect: exclude)
            textView.textContainer.exclusionPaths = [imagePath]
        } else {
            postImageView.isHidden = true
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

    @objc func tapped(_ sender: UIGestureRecognizer) {
        model?.isExpanded.toggle()
        guard let model = model else { return }

        setExpanded()
        delegate?.toggle(index: model.index)
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
        //textView.sizeToFit()
    }
}
