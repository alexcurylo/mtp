// @copyright Trollwerks Inc.

import Anchorage

/// State of data displaying view content
enum ContentState {

    /// Has populated content
    case data
    /// Has empty content
    case empty
    /// Error finding content
    case error
    /// Content is being loaded
    case loading
    /// Content source is not implemented
    case unimplemented
    /// Mismanaged state
    case unknown
}

/// Protocol for data displaying things to adopt
protocol ContentStateMessaging {

    /// Display an appropriate message if any
    ///
    /// - Parameters:
    ///   - state: ContentState
    ///   - color: Color suggestion
    func set(message state: ContentState,
             color: UIColor)
}

/// UIViews display a text string in their background view
protocol ContentStateMessagingView: ContentStateMessaging where Self: UIView {

    /// Holder of content state message
    var backgroundView: UIView? { get set }
}

extension UITableView: ContentStateMessagingView {}
extension UICollectionView: ContentStateMessagingView {}

extension ContentStateMessagingView {

    /// Currently displayed message view if any
    var messageView: UIView? {
        return backgroundView?.subviews.first
    }

    /// Set a content state message
    ///
    /// - Parameters:
    ///   - state: ContentState
    ///   - color: Color suggestion
    func set(message state: ContentState,
             color: UIColor = .white) {
        switch state {
        case .data, .unknown:
            setMessageNone()
        case .empty:
            set(message: L.emptyState(), color: color)
        case .error:
            set(message: L.errorState(), color: color)
        case .loading:
            set(message: L.loading(), color: color)
        case .unimplemented:
            set(message: L.unimplemented(), color: color)
        }
    }

    private func set(message: String,
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

    private func setMessageNone() {
        messageView?.removeFromSuperview()
    }
}
