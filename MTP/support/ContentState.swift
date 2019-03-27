// @copyright Trollwerks Inc.

import Anchorage

enum ContentState {
    case data
    case empty
    case error
    case loading
}

protocol ContentStateMessaging {

    func set(message state: ContentState)
}

protocol ContentStateMessagingView: ContentStateMessaging where Self: UIView {

    var backgroundView: UIView? { get set }
}

extension UITableView: ContentStateMessagingView {}
extension UICollectionView: ContentStateMessagingView {}

extension ContentStateMessagingView {

    var messageView: UIView? {
        return backgroundView?.subviews.first
    }

    func set(message state: ContentState) {
        switch state {
        case .data:
            setMessageNone()
        case .empty:
            set(message: Localized.emptyState())
        case .error:
            set(message: Localized.errorState())
        case .loading:
            set(message: Localized.loading())
        }
    }

    func set(message: String) {
        guard let backgroundView = backgroundView else { return }
        setMessageNone()

        let label = UILabel {
            $0.font = Avenir.mediumOblique.of(size: 14)
            $0.textColor = .white
            $0.text = message
        }

        backgroundView.addSubview(label)
        label.centerAnchors == backgroundView.centerAnchors
    }

    func setMessageNone() {
        messageView?.removeFromSuperview()
    }
}
