// @copyright Trollwerks Inc.

import Anchorage
import UIKit

final class MyPostsVC: UICollectionViewController {

    private enum Layout {
        static let cellHeight = CGFloat(100)
    }

    private var posts: [MyPostCellModel] = []

    private let dateFormatter: DateFormatter = create {
        $0.dateStyle = .long
        $0.timeStyle = .none
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        flow?.itemSize = UICollectionViewFlowLayout.automaticSize
        flow?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refreshPosts()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        log.verbose("prepare for \(segue.name)")
        switch segue.identifier {
        default:
            log.debug("unexpected segue: \(segue.name)")
        }
    }
}

// MARK: UICollectionViewDataSource

extension MyPostsVC {

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MyPostCell.reuseIdentifier,
            for: indexPath)

        if let postCell = cell as? MyPostCell,
           let flow = flow {
            postCell.set(model: posts[indexPath.row],
                         width: collectionView.frame.width - flow.sectionInset.left - flow.sectionInset.right
            )
        }

        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension MyPostsVC: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let insets: CGFloat
        if let flow = collectionViewLayout as? UICollectionViewFlowLayout {
            insets = flow.sectionInset.left + flow.sectionInset.right
        } else {
            insets = 0
        }
        return CGSize(width: collectionView.bounds.width - insets,
                      height: Layout.cellHeight)
    }
}

// MARK: Data management

private extension MyPostsVC {

    var flow: UICollectionViewFlowLayout? {
        return collectionView.collectionViewLayout as? UICollectionViewFlowLayout
    }

    func refreshPosts() {
        log.debug("My Posts should be using posts from site")

        posts = (1...8).map {
            MyPostCellModel(image: nil,
                            date: dateFormatter.string(from: Date()).uppercased(),
                            title: "This is post title \($0) which is long enough to wrap",
                            body: """
                                  This is a body title of a very long body
                                  continued on another line to make it long
                                  enough to wrap on a standard cell
                                  """)
        }

        collectionView.reloadData()
    }
}

struct MyPostCellModel {

    let image: UIImage?
    let date: String
    let title: String
    let body: String
}

final class MyPostCell: UICollectionViewCell {

    fileprivate static let reuseIdentifier: String = "MyPostCell"

    @IBOutlet private var imageView: UIImageView?
    @IBOutlet private var dateLabel: UILabel?
    @IBOutlet private var titleLabel: UILabel?
    @IBOutlet private var bodyLabel: UILabel?
    private var widthConstraint: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.centerAnchors == centerAnchors
        widthConstraint = contentView.widthAnchor == 0
    }

    fileprivate func set(model: MyPostCellModel,
                         width: CGFloat) {
        imageView?.image = model.image
        dateLabel?.text = model.date
        titleLabel?.text = model.title
        bodyLabel?.text = model.body

        widthConstraint?.constant = width
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView?.image = nil
        dateLabel?.text = nil
        titleLabel?.text = nil
        bodyLabel?.text = nil
    }
}
