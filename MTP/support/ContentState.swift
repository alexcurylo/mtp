// @copyright Trollwerks Inc.

import Anchorage

enum ContentState {
    case data
    case empty
    case error
    case loading
}

protocol ContentStateMessaging {

    func set(message state: ContentState,
             color: UIColor)
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

    func set(message state: ContentState,
             color: UIColor = .white) {
        switch state {
        case .data:
            setMessageNone()
        case .empty:
            set(message: Localized.emptyState(), color: color)
        case .error:
            set(message: Localized.errorState(), color: color)
        case .loading:
            set(message: Localized.loading(), color: color)
        }
    }

    func set(message: String,
             color: UIColor) {
        guard let backgroundView = backgroundView else { return }
        setMessageNone()

        let label = UILabel {
            $0.font = Avenir.mediumOblique.of(size: 14)
            $0.textColor = color
            $0.text = message
        }

        backgroundView.addSubview(label)
        label.centerAnchors == backgroundView.centerAnchors
    }

    func setMessageNone() {
        messageView?.removeFromSuperview()
    }
}
