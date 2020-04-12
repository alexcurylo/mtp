// @copyright Trollwerks Inc.

// migrated from https://github.com/AssistoLab/Dropdown

//
//  Dropdown.swift
//  Dropdown
//
//  Created by Kevin Hirsch on 28/07/15.
//  Copyright (c) 2015 Kevin Hirsch. All rights reserved.
//

import UIKit

// swiftlint:disable file_length

/// Index
typealias Index = Int
/// SelectionClosure
typealias SelectionClosure = (Index, String) -> Void
/// MultiSelectionClosure
typealias MultiSelectionClosure = ([Index], [String]) -> Void
/// ConfigurationClosure
typealias ConfigurationClosure = (Index, String) -> String
/// CellConfigurationClosure
typealias CellConfigurationClosure = (Index, String, DropdownCell) -> Void
private typealias ComputeLayoutTuple = (x: CGFloat, y: CGFloat, width: CGFloat, offscreenHeight: CGFloat)

/// Can be `UIView` or `UIBarButtonItem`.
@objc protocol AnchorView: AnyObject {

    /// Plain view
	var plainView: UIView { get }
}

extension UIView: AnchorView {

    /// Plain view
	var plainView: UIView { self }
}

extension UIBarButtonItem: AnchorView {

    /// Plain view
	var plainView: UIView {
        // swiftlint:disable:next force_cast
		return value(forKey: "view") as! UIView
	}
}

/// A Material Design dropdown in replacement for `UIPickerView`.
final class Dropdown: UIView {

	/// The dismiss mode for a dropdown.
	enum DismissMode {

		/// A tap outside the dropdown is required to dismiss.
		case onTap

		/// No tap is required to dismiss, it will dimiss when interacting with anything else.
		case automatic

		/// Not dismissable by the user.
		case manual
	}

	/// The direction where the dropdown will show from the `anchorView`.
	enum Direction {

		/// The dropdown will show below the anchor view when possible, otherwise above if there is more place than below.
		case any

		/// The dropdown will show above the anchor view or will not be showed if not enough space.
		case top

		/// The dropdown will show below or will not be showed if not enough space.
		case bottom
	}

    // MARK: - Properties

	/// The current visible dropdown. There can be only one visible dropdown at a time.
	static weak var VisibleDropdown: Dropdown?

    // MARK: UI
	fileprivate let dismissableView = UIView()
	fileprivate let tableViewContainer = UIView()
	fileprivate let tableView = UITableView()
    // swiftlint:disable:next implicitly_unwrapped_optional
	fileprivate var templateCell: DropdownCell!
    fileprivate lazy var arrowIndication: UIImageView = {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 20, height: 10), false, 0)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 10))
        path.addLine(to: CGPoint(x: 20, y: 10))
        path.addLine(to: CGPoint(x: 10, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 10))
        UIColor.black.setFill()
        path.fill()
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let tintImg = img?.withRenderingMode(.alwaysTemplate)
        let imgv = UIImageView(image: tintImg)
        imgv.frame = CGRect(x: 0, y: -10, width: 15, height: 10)
        return imgv
    }()

    /// The view to which the dropdown will displayed onto.
    weak var anchorView: AnchorView? {
        didSet { setNeedsUpdateConstraints() }
    }

    /**
    The possible directions where the dropdown will be showed.

    See `Direction` enum for more info.
    */
    var direction = Direction.any

    /**
    The offset point relative to `anchorView` when the dropdown is shown above the anchor view.

    By default, the dropdown is showed onto the `anchorView` with the top
    left corner for its origin, so an offset equal to (0, 0).
    You can change here the default dropdown origin.
    */
    var topOffset: CGPoint = .zero {
        didSet { setNeedsUpdateConstraints() }
    }

    /**
    The offset point relative to `anchorView` when the dropdown is shown below the anchor view.

    By default, the dropdown is showed onto the `anchorView` with the top
    left corner for its origin, so an offset equal to (0, 0).
    You can change here the default dropdown origin.
    */
    var bottomOffset: CGPoint = .zero {
        didSet { setNeedsUpdateConstraints() }
    }

    /**
    The offset from the bottom of the window when the dropdown is shown below the anchor view.
    Dropdown applies this offset only if keyboard is hidden.
    */
    var offsetFromWindowBottom = CGFloat(0) {
        didSet { setNeedsUpdateConstraints() }
    }

    /**
    The width of the dropdown.

    Defaults to `anchorView.bounds.width - offset.x`.
    */
    var width: CGFloat? {
        didSet { setNeedsUpdateConstraints() }
    }

    /**
    arrowIndication.x

    arrowIndication will be add to tableViewContainer when configured
    */
    var arrowIndicationX: CGFloat? {
        didSet {
            if let arrowIndicationX = arrowIndicationX {
                tableViewContainer.addSubview(arrowIndication)
                arrowIndication.tintColor = tableViewBackgroundColor
                arrowIndication.frame.origin.x = arrowIndicationX
            } else {
                arrowIndication.removeFromSuperview()
            }
        }
    }

    // MARK: Constraints

    // swiftlint:disable:next implicitly_unwrapped_optional
    fileprivate var heightConstraint: NSLayoutConstraint!
    // swiftlint:disable:next implicitly_unwrapped_optional
    fileprivate var widthConstraint: NSLayoutConstraint!
    // swiftlint:disable:next implicitly_unwrapped_optional
    fileprivate var xConstraint: NSLayoutConstraint!
    // swiftlint:disable:next implicitly_unwrapped_optional
    fileprivate var yConstraint: NSLayoutConstraint!

    // MARK: Appearance

    /// Cell height
    @objc dynamic var cellHeight = DPDConstant.UI.RowHeight {
        willSet { tableView.rowHeight = newValue }
        didSet { reloadAllComponents() }
    }

    @objc fileprivate dynamic var tableViewBackgroundColor = DPDConstant.UI.BackgroundColor {
        willSet {
            tableView.backgroundColor = newValue
            if arrowIndicationX != nil { arrowIndication.tintColor = newValue }
        }
    }

    /// Background color
    override var backgroundColor: UIColor? {
        get { tableViewBackgroundColor }
        set {
            if let newValue = newValue {
                tableViewBackgroundColor = newValue
            }
        }
    }

    /**
    The color of the dimmed background (behind the dropdown, covering the entire screen).
    */
    var dimmedBackgroundColor = UIColor.clear {
        willSet { super.backgroundColor = newValue }
    }

    /**
    The background color of the selected cell in the dropdown.

    Changing the background color automatically reloads the dropdown.
    */
    @objc dynamic var selectionBackgroundColor = DPDConstant.UI.SelectionBackgroundColor

    /**
    The separator color between cells.

    Changing the separator color automatically reloads the dropdown.
    */
    @objc dynamic var separatorColor = DPDConstant.UI.SeparatorColor {
        willSet { tableView.separatorColor = newValue }
        didSet { reloadAllComponents() }
    }

    /**
    The corner radius of Dropdown.

    Changing the corner radius automatically reloads the dropdown.
    */
    @objc dynamic var ddCornerRadius = DPDConstant.UI.CornerRadius {
        willSet {
            tableViewContainer.layer.cornerRadius = newValue
            tableView.layer.cornerRadius = newValue
        }
        didSet { reloadAllComponents() }
    }

    /**
    Alias method for `ddCornerRadius` variable to avoid ambiguity.
    */
    @objc dynamic func setupCornerRadius(_ radius: CGFloat) {
        tableViewContainer.layer.cornerRadius = radius
        tableView.layer.cornerRadius = radius
        reloadAllComponents()
    }

    /**
    The masked corners of Dropdown.

    Changing the masked corners automatically reloads the dropdown.
    */
    @objc dynamic func setupMaskedCorners(_ cornerMask: CACornerMask) {
        tableViewContainer.layer.maskedCorners = cornerMask
        tableView.layer.maskedCorners = cornerMask
        reloadAllComponents()
    }

    /**
    The color of the shadow.

    Changing the shadow color automatically reloads the dropdown.
    */
    @objc dynamic var shadowColor = DPDConstant.UI.Shadow.Color {
        willSet { tableViewContainer.layer.shadowColor = newValue.cgColor }
        didSet { reloadAllComponents() }
    }

    /**
    The offset of the shadow.

    Changing the shadow color automatically reloads the dropdown.
    */
    @objc dynamic var shadowOffset = DPDConstant.UI.Shadow.Offset {
        willSet { tableViewContainer.layer.shadowOffset = newValue }
        didSet { reloadAllComponents() }
    }

    /**
    The opacity of the shadow.

    Changing the shadow opacity automatically reloads the dropdown.
    */
    @objc dynamic var shadowOpacity = DPDConstant.UI.Shadow.Opacity {
        willSet { tableViewContainer.layer.shadowOpacity = newValue }
        didSet { reloadAllComponents() }
    }

    /**
    The radius of the shadow.

    Changing the shadow radius automatically reloads the dropdown.
    */
    @objc dynamic var shadowRadius = DPDConstant.UI.Shadow.Radius {
        willSet { tableViewContainer.layer.shadowRadius = newValue }
        didSet { reloadAllComponents() }
    }

    /**
    The duration of the show/hide animation.
    */
    @objc dynamic var animationduration = DPDConstant.Animation.Duration

    /**
    The option of the show animation. Global change.
    */
    static var animationEntranceOptions = DPDConstant.Animation.EntranceOptions

    /**
    The option of the hide animation. Global change.
    */
    static var animationExitOptions = DPDConstant.Animation.ExitOptions

    /**
    The option of the show animation. Only change the caller. To change all dropdown's use the static var.
    */
    var animationEntranceOptions: UIView.AnimationOptions = Dropdown.animationEntranceOptions

    /**
    The option of the hide animation. Only change the caller. To change all dropdown's use the static var.
    */
    var animationExitOptions: UIView.AnimationOptions = Dropdown.animationExitOptions

    /**
    The downScale transformation of the tableview when the Dropdown is appearing
    */
    var downScaleTransform = DPDConstant.Animation.DownScaleTransform {
        willSet { tableViewContainer.transform = newValue }
    }

    /**
    The color of the text for each cells of the dropdown.

    Changing the text color automatically reloads the dropdown.
    */
    @objc dynamic var textColor = DPDConstant.UI.TextColor {
        didSet { reloadAllComponents() }
    }

    /**
     The color of the text for selected cells of the dropdown.
     
     Changing the text color automatically reloads the dropdown.
     */
    @objc dynamic var selectedTextColor = DPDConstant.UI.SelectedTextColor {
        didSet { reloadAllComponents() }
    }

    /**
    The font of the text for each cells of the dropdown.

    Changing the text font automatically reloads the dropdown.
    */
    @objc dynamic var textFont = DPDConstant.UI.TextFont {
        didSet { reloadAllComponents() }
    }

    /**
     The NIB to use for DropdownCells
     
     Changing the cell nib automatically reloads the dropdown.
     */
    var cellNib = UINib(nibName: "DropdownCell", bundle: Bundle(for: DropdownCell.self)) {
        didSet {
            tableView.register(cellNib, forCellReuseIdentifier: DPDConstant.ReusableIdentifier.DropdownCell)
            templateCell = nil
            reloadAllComponents()
        }
    }

    // MARK: Content

    /**
    The data source for the dropdown.

    Changing the data source automatically reloads the dropdown.
    */
    var dataSource = [String]() {
        didSet {
            deselectRows(at: selectedRowIndices)
            reloadAllComponents()
        }
    }

    /**
    The localization keys for the data source for the dropdown.

    Changing this value automatically reloads the dropdown.
    This has uses for setting accibility identifiers on the dropdown cells (same ones as the localization keys).
    */
    var localizationKeysDataSource = [String]() {
        didSet {
            // swiftlint:disable:next nslocalizedstring_key nslocalizedstring_require_bundle
            dataSource = localizationKeysDataSource.map { NSLocalizedString($0, comment: "") }
        }
    }

    /// The indicies that have been selected
    fileprivate var selectedRowIndices = Set<Index>()

    /**
    The format for the cells' text.

    By default, the cell's text takes the plain `dataSource` value.
    Changing `cellConfiguration` automatically reloads the dropdown.
    */
    var cellConfiguration: ConfigurationClosure? {
        didSet { reloadAllComponents() }
    }

    /**
     A advanced formatter for the cells. Allows customization when custom cells are used
     
     Changing `customCellConfiguration` automatically reloads the dropdown.
     */
    var customCellConfiguration: CellConfigurationClosure? {
        didSet { reloadAllComponents() }
    }

    /// The action to execute when the user selects a cell.
    var selectionAction: SelectionClosure?

    /**
    The action to execute when the user selects multiple cells.
    
    Providing an action will turn on multiselection mode.
    The single selection action will still be called if provided.
    */
    var multiSelectionAction: MultiSelectionClosure?

    /// The action to execute when the dropdown will show.
    var willShowAction: Closure?

    /// The action to execute when the user cancels/hides the dropdown.
    var cancelAction: Closure?

    /// The dismiss mode of the dropdown. Default is `OnTap`.
    var dismissMode = DismissMode.onTap {
        willSet {
            if newValue == .onTap {
                let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissableViewTapped))
                dismissableView.addGestureRecognizer(gestureRecognizer)
            } else if let gestureRecognizer = dismissableView.gestureRecognizers?.first {
                dismissableView.removeGestureRecognizer(gestureRecognizer)
            }
        }
    }

    fileprivate var minHeight: CGFloat {
        tableView.rowHeight
    }

    fileprivate var didSetupConstraints = false

    // MARK: - Initialization

    /// :nodoc:
    deinit {
        stopListeningToNotifications()
    }

    /**
    Creates a new instance of a dropdown.
    Don't forget to setup the `dataSource`,
    the `anchorView` and the `selectionAction`
    at least before calling `show()`.
    */
    convenience init() {
        self.init(frame: .zero)
    }

    /**
    Creates a new instance of a dropdown.

    - parameter anchorView:        The view to which the dropdown will displayed onto.
    - parameter selectionAction:   The action to execute when the user selects a cell.
    - parameter dataSource:        The data source for the dropdown.
    - parameter topOffset:         The offset relative to `anchorView` used when  displayed on above the anchor view.
    - parameter bottomOffset:      The offset relative to `anchorView` used when  displayed on below the anchor view.
    - parameter cellConfiguration: The format for the cells' text.
    - parameter cancelAction:      The action to execute when the user cancels/hides the dropdown.

    - returns: A new instance of a dropdown customized with the above parameters.
    */
    convenience init(anchorView: AnchorView,
                     selectionAction: SelectionClosure? = nil,
                     dataSource: [String] = [],
                     topOffset: CGPoint? = nil,
                     bottomOffset: CGPoint? = nil,
                     cellConfiguration: ConfigurationClosure? = nil,
                     cancelAction: Closure? = nil) {
        self.init(frame: .zero)

        self.anchorView = anchorView
        self.selectionAction = selectionAction
        self.dataSource = dataSource
        self.topOffset = topOffset ?? .zero
        self.bottomOffset = bottomOffset ?? .zero
        self.cellConfiguration = cellConfiguration
        self.cancelAction = cancelAction
    }

    /// :nodoc:
    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    /// :nodoc:
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    /// :nodoc:
    override func updateConstraints() {
        // swiftlint:disable:previous overridden_super_call
        if !didSetupConstraints {
            setupConstraints()
        }

        didSetupConstraints = true

        let layout = computeLayout()

        if !layout.canBeDisplayed {
            super.updateConstraints()

            return hide()
        }

        xConstraint.constant = layout.x
        yConstraint.constant = layout.y
        widthConstraint.constant = layout.width
        heightConstraint.constant = layout.visibleHeight

        tableView.isScrollEnabled = layout.offscreenHeight > 0

        DispatchQueue.main.async { [weak self] in
            self?.tableView.flashScrollIndicators()
        }

        super.updateConstraints()
    }

    /// :nodoc:
    override func layoutSubviews() {
        super.layoutSubviews()

        // When orientation changes, layoutSubviews is called
        // We update the constraint to update the position
        setNeedsUpdateConstraints()

        let shadowPath = UIBezierPath(roundedRect: tableViewContainer.bounds, cornerRadius: cornerRadius)
        tableViewContainer.layer.shadowPath = shadowPath.cgPath
    }
}

// MARK: - Setup

private extension Dropdown {

    func setup() {
        tableView.register(cellNib, forCellReuseIdentifier: DPDConstant.ReusableIdentifier.DropdownCell)

        DispatchQueue.main.async {
            // HACK: If not done in dispatch_async on main queue `setupUI` will have no effect
            self.updateConstraintsIfNeeded()
            self.setupUI()
        }

        tableView.rowHeight = cellHeight
        setHiddentState()
        isHidden = true

        dismissMode = .onTap

        tableView.delegate = self
        tableView.dataSource = self

        startListeningToKeyboard()

        accessibilityIdentifier = "drop_down"
    }

    func setupUI() {
        super.backgroundColor = dimmedBackgroundColor

        tableViewContainer.layer.masksToBounds = false
        tableViewContainer.layer.cornerRadius = cornerRadius
        tableViewContainer.layer.shadowColor = shadowColor.cgColor
        tableViewContainer.layer.shadowOffset = shadowOffset
        tableViewContainer.layer.shadowOpacity = shadowOpacity
        tableViewContainer.layer.shadowRadius = shadowRadius

        tableView.backgroundColor = tableViewBackgroundColor
        tableView.separatorColor = separatorColor
        tableView.layer.cornerRadius = cornerRadius
        tableView.layer.masksToBounds = true
    }
}

// MARK: - UI

private extension Dropdown {

    // swiftlint:disable:next function_body_length
    func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false

        // Dismissable view
        addSubview(dismissableView)
        dismissableView.translatesAutoresizingMaskIntoConstraints = false

        addUniversalConstraints(format: "|[dismissableView]|", views: ["dismissableView": dismissableView])

        // Table view container
        addSubview(tableViewContainer)
        tableViewContainer.translatesAutoresizingMaskIntoConstraints = false

        xConstraint = NSLayoutConstraint(
            item: tableViewContainer,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1,
            constant: 0)
        addConstraint(xConstraint)

        yConstraint = NSLayoutConstraint(
            item: tableViewContainer,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1,
            constant: 0)
        addConstraint(yConstraint)

        widthConstraint = NSLayoutConstraint(
            item: tableViewContainer,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 0)
        tableViewContainer.addConstraint(widthConstraint)

        heightConstraint = NSLayoutConstraint(
            item: tableViewContainer,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 0)
        tableViewContainer.addConstraint(heightConstraint)

        // Table view
        tableViewContainer.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableViewContainer.addUniversalConstraints(format: "|[tableView]|", views: ["tableView": tableView])
    }

    // swiftlint:disable:next large_tuple
    func computeLayout() -> (x: CGFloat,
                                         y: CGFloat,
                                         width: CGFloat,
                                         offscreenHeight: CGFloat,
                                         visibleHeight: CGFloat,
                                         canBeDisplayed: Bool,
                                         Direction: Direction) {
        var layout: ComputeLayoutTuple = (0, 0, 0, 0)
        var direction = self.direction

        guard let window = UIWindow.visibleWindow() else { return (0, 0, 0, 0, 0, false, direction) }

        barButtonItemCondition: if let anchorView = anchorView as? UIBarButtonItem {
            let isRightBarButtonItem = anchorView.plainView.frame.minX > window.frame.midX

            guard isRightBarButtonItem else { break barButtonItemCondition }

            let width = self.width ?? fittingWidth()
            let anchorViewWidth = anchorView.plainView.frame.width
            let x = -(width - anchorViewWidth)

            bottomOffset = CGPoint(x: x, y: 0)
        }

        if anchorView == nil {
            layout = computeLayoutBottomDisplay(window: window)
            direction = .any
        } else {
            switch direction {
            case .any:
                layout = computeLayoutBottomDisplay(window: window)
                direction = .bottom

                if layout.offscreenHeight > 0 {
                    let topLayout = computeLayoutForTopDisplay(window: window)

                    if topLayout.offscreenHeight < layout.offscreenHeight {
                        layout = topLayout
                        direction = .top
                    }
                }
            case .bottom:
                layout = computeLayoutBottomDisplay(window: window)
                direction = .bottom
            case .top:
                layout = computeLayoutForTopDisplay(window: window)
                direction = .top
            }
        }

        constraintWidthToFittingSizeIfNecessary(layout: &layout)
        constraintWidthToBoundsIfNecessary(layout: &layout, in: window)

        let visibleHeight = tableHeight - layout.offscreenHeight
        let canBeDisplayed = visibleHeight >= minHeight

        return (layout.x, layout.y, layout.width, layout.offscreenHeight, visibleHeight, canBeDisplayed, direction)
    }

    func computeLayoutBottomDisplay(window: UIWindow) -> ComputeLayoutTuple {
        var offscreenHeight: CGFloat = 0

        let width = self.width ?? (anchorView?.plainView.bounds.width ?? fittingWidth()) - bottomOffset.x

        let anchorViewX = anchorView?.plainView.windowFrame?.minX ?? window.frame.midX - (width / 2)
        let anchorViewY = anchorView?.plainView.windowFrame?.minY ?? window.frame.midY - (tableHeight / 2)

        let x = anchorViewX + bottomOffset.x
        let y = anchorViewY + bottomOffset.y

        let maxY = y + tableHeight
        let windowMaxY = window.bounds.maxY - DPDConstant.UI.HeightPadding - offsetFromWindowBottom

        let keyboardListener = DPDKeyboardListener.sharedInstance
        let keyboardMinY = keyboardListener.keyboardFrame.minY - DPDConstant.UI.HeightPadding

        if keyboardListener.isVisible && maxY > keyboardMinY {
            offscreenHeight = abs(maxY - keyboardMinY)
        } else if maxY > windowMaxY {
            offscreenHeight = abs(maxY - windowMaxY)
        }

        return (x, y, width, offscreenHeight)
    }

    func computeLayoutForTopDisplay(window: UIWindow) -> ComputeLayoutTuple {
        var offscreenHeight: CGFloat = 0

        let anchorViewX = anchorView?.plainView.windowFrame?.minX ?? 0
        let anchorViewMaxY = anchorView?.plainView.windowFrame?.maxY ?? 0

        let x = anchorViewX + topOffset.x
        var y = (anchorViewMaxY + topOffset.y) - tableHeight

        let windowY = window.bounds.minY + DPDConstant.UI.HeightPadding

        if y < windowY {
            offscreenHeight = abs(y - windowY)
            y = windowY
        }

        let width = self.width ?? (anchorView?.plainView.bounds.width ?? fittingWidth()) - topOffset.x

        return (x, y, width, offscreenHeight)
    }

    func fittingWidth() -> CGFloat {
        if templateCell == nil {
            // swiftlint:disable:next force_cast
            templateCell = (cellNib.instantiate(withOwner: nil, options: nil)[0] as! DropdownCell)
        }

        var maxWidth: CGFloat = 0

        for index in 0..<dataSource.count {
            configureCell(templateCell, at: index)
            templateCell.bounds.size.height = cellHeight
            let width = templateCell.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).width

            if width > maxWidth {
                maxWidth = width
            }
        }

        return maxWidth
    }

    func constraintWidthToBoundsIfNecessary(layout: inout ComputeLayoutTuple, in window: UIWindow) {
        let windowMaxX = window.bounds.maxX
        let maxX = layout.x + layout.width

        if maxX > windowMaxX {
            let delta = maxX - windowMaxX
            let newOrigin = layout.x - delta

            if newOrigin > 0 {
                layout.x = newOrigin
            } else {
                layout.x = 0
                layout.width += newOrigin // newOrigin is negative, so this operation is a substraction
            }
        }
    }

    func constraintWidthToFittingSizeIfNecessary(layout: inout ComputeLayoutTuple) {
        guard width == nil else { return }

        if layout.width < fittingWidth() {
            layout.width = fittingWidth()
        }
    }
}

// MARK: - Actions

extension Dropdown {

    /**
     An Objective-C alias for the show() method which converts the returned tuple into an NSDictionary.
     
     - returns: NSDictionary with  "canBeDisplayed" Bool, and possibly for the "offScreenHeight" Optional(CGFloat).
     */
    @objc(show) func objc_show() -> NSDictionary {
        let (canBeDisplayed, offScreenHeight) = show()

        var info = [AnyHashable: Any]()
        info["canBeDisplayed"] = canBeDisplayed
        if let offScreenHeight = offScreenHeight {
            info["offScreenHeight"] = offScreenHeight
        }

        return NSDictionary(dictionary: info)
    }

    /**
    Shows the dropdown if enough height.

    - returns: Wether it succeed and how much height is needed to display all cells at once.
    */
    @discardableResult func show(
        onTopOf window: UIWindow? = nil,
        beforeTransform transform: CGAffineTransform? = nil,
        anchorPoint: CGPoint? = nil
    ) -> (canBeDisplayed: Bool, offscreenHeight: CGFloat?) {
        if self == Dropdown.VisibleDropdown && Dropdown.VisibleDropdown?.isHidden == false {
            return (true, 0)
        }

        if let visibleDropdown = Dropdown.VisibleDropdown {
            visibleDropdown.cancel()
        }

        willShowAction?()

        Dropdown.VisibleDropdown = self

        setNeedsUpdateConstraints()

        let visibleWindow = window != nil ? window : UIWindow.visibleWindow()
        visibleWindow?.addSubview(self)
        visibleWindow?.bringSubviewToFront(self)

        self.translatesAutoresizingMaskIntoConstraints = false
        visibleWindow?.addUniversalConstraints(format: "|[dropDown]|", views: ["dropDown": self])

        let layout = computeLayout()

        if !layout.canBeDisplayed {
            hide()
            return (layout.canBeDisplayed, layout.offscreenHeight)
        }

        isHidden = false

        if let anchorPoint = anchorPoint {
            tableViewContainer.layer.anchorPoint = anchorPoint
        }

        if let transform = transform {
            tableViewContainer.transform = transform
        } else {
            tableViewContainer.transform = downScaleTransform
        }

        layoutIfNeeded()

        UIView.animate(
            withDuration: animationduration,
            delay: 0,
            options: animationEntranceOptions,
            animations: { [weak self] in
                self?.setShowedState()
            },
            completion: nil)

        accessibilityViewIsModal = true
        UIAccessibility.post(notification: .screenChanged, argument: self)

        // deselectRows(at: selectedRowIndices)
        selectRows(at: selectedRowIndices)

        return (layout.canBeDisplayed, layout.offscreenHeight)
    }

    /// :nodoc:
    override func accessibilityPerformEscape() -> Bool {
        switch dismissMode {
        case .automatic, .onTap:
            cancel()
            return true
        case .manual:
            return false
        }
    }

    /// Hides the dropdown.
    func hide() {
        if self == Dropdown.VisibleDropdown {
            /*
            If one dropdown is showed and another one is not
            but we call `hide()` on the hidden one:
            we don't want it to set the `VisibleDropdown` to nil.
            */
            Dropdown.VisibleDropdown = nil
        }

        if isHidden {
            return
        }

        UIView.animate(
            withDuration: animationduration,
            delay: 0,
            options: animationExitOptions,
            animations: { [weak self] in
                self?.setHiddentState()
            },
            completion: { [weak self] _ in
                guard let `self` = self else { return }

                self.isHidden = true
                self.removeFromSuperview()
                UIAccessibility.post(notification: .screenChanged, argument: nil)
            }
        )
    }

    func cancel() {
        hide()
        cancelAction?()
    }

    func setHiddentState() {
        alpha = 0
    }

    func setShowedState() {
        alpha = 1
        tableViewContainer.transform = CGAffineTransform.identity
    }
}

// MARK: - UITableView

extension Dropdown {

    /**
    Reloads all the cells.

    It should not be necessary in most cases because each change to
    `dataSource`, `textColor`, `textFont`, `selectionBackgroundColor`
    and `cellConfiguration` implicitly calls `reloadAllComponents()`.
    */
    func reloadAllComponents() {
        DispatchQueue.toMain {
            self.tableView.reloadData()
            self.setNeedsUpdateConstraints()
        }
    }

    /// (Pre)selects a row at a certain index.
    func selectRow(at index: Index?, scrollPosition: UITableView.ScrollPosition = .none) {
        if let index = index {
            tableView.selectRow(
                at: IndexPath(row: index, section: 0), animated: true, scrollPosition: scrollPosition
            )
            selectedRowIndices.insert(index)
        } else {
            deselectRows(at: selectedRowIndices)
            selectedRowIndices.removeAll()
        }
    }

    /// Select rows
    /// - Parameter indices: Selection
    func selectRows(at indices: Set<Index>?) {
        // swiftlint:disable:previous discouraged_optional_collection
        indices?.forEach {
            selectRow(at: $0)
        }

        // if we are in multi selection mode then reload data so that all selections are shown
        if multiSelectionAction != nil {
            tableView.reloadData()
        }
    }

    /// Deselect row
    /// - Parameter index: Index
    func deselectRow(at index: Index?) {
        guard let index = index, index >= 0
            else { return }

        // remove from indices
        if let selectedRowIndex = selectedRowIndices.firstIndex(where: { $0 == index }) {
            selectedRowIndices.remove(at: selectedRowIndex)
        }

        tableView.deselectRow(at: IndexPath(row: index, section: 0), animated: true)
    }

    /// Deselect rows
    /// - Parameter indices: Indices
    func deselectRows(at indices: Set<Index>?) {
        // swiftlint:disable:previous discouraged_optional_collection
        indices?.forEach {
            deselectRow(at: $0)
        }
    }

    /// Returns the index of the selected row.
    var indexForSelectedRow: Index? {
        (tableView.indexPathForSelectedRow as NSIndexPath?)?.row
    }

    /// Returns the selected item.
    var selectedItem: String? {
        guard let row = (tableView.indexPathForSelectedRow as NSIndexPath?)?.row else { return nil }

        return dataSource[row]
    }

    /// Returns the height needed to display all cells.
    var tableHeight: CGFloat {
        tableView.rowHeight * CGFloat(dataSource.count)
    }

    // MARK: Objective-C methods for converting the Swift type Index

    /// (Pre)selects a row at a certain index.
    @objc func selectRow(_ index: Int, scrollPosition: UITableView.ScrollPosition = .none) {
        self.selectRow(at: Index(index), scrollPosition: scrollPosition)
    }

    /// Clear selection
    @objc func clearSelection() {
        self.selectRow(at: nil)
    }

    /// Deselect row
    /// - Parameter index: Index
    @objc func deselectRow(_ index: Int) {
        tableView.deselectRow(at: IndexPath(row: Index(index), section: 0), animated: true)
    }

    /// Selected index path
    @objc var indexPathForSelectedRow: NSIndexPath? {
        tableView.indexPathForSelectedRow as NSIndexPath?
    }
}

// MARK: - UITableViewDataSource - UITableViewDelegate

extension Dropdown: UITableViewDataSource, UITableViewDelegate {

    /// :nodoc:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }

    /// :nodoc:
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DPDConstant.ReusableIdentifier.DropdownCell,
                                                 // swiftlint:disable:next force_cast
                                                 for: indexPath) as! DropdownCell
        let index = (indexPath as NSIndexPath).row

        configureCell(cell, at: index)

        return cell
    }

    func configureCell(_ cell: DropdownCell, at index: Int) {
        if index >= 0 && index < localizationKeysDataSource.count {
            cell.accessibilityIdentifier = localizationKeysDataSource[index]
        }

        cell.optionLabel.textColor = textColor
        cell.optionLabel.font = textFont
        cell.selectedBackgroundColor = selectionBackgroundColor
        cell.highlightTextColor = selectedTextColor
        cell.normalTextColor = textColor

        if let cellConfiguration = cellConfiguration {
            cell.optionLabel.text = cellConfiguration(index, dataSource[index])
        } else {
            cell.optionLabel.text = dataSource[index]
        }

        customCellConfiguration?(index, dataSource[index], cell)
    }

    /// :nodoc:
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        cell.isSelected = selectedRowIndices.contains { $0 == (indexPath as NSIndexPath).row }
    }

    /// :nodoc:
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let selectedRowIndex = (indexPath as NSIndexPath).row

        // are we in multi-selection mode?
        if let multiSelectionCallback = multiSelectionAction {
            // if already selected then deselect
            if (selectedRowIndices.contains { $0 == selectedRowIndex }) {
                deselectRow(at: selectedRowIndex)

                let selectedRowIndicesArray = Array(selectedRowIndices)
                let selectedRows = selectedRowIndicesArray.map { dataSource[$0] }
                multiSelectionCallback(selectedRowIndicesArray, selectedRows)
                return
            } else {
                selectedRowIndices.insert(selectedRowIndex)

                let selectedRowIndicesArray = Array(selectedRowIndices)
                let selectedRows = selectedRowIndicesArray.map { dataSource[$0] }

                selectionAction?(selectedRowIndex, dataSource[selectedRowIndex])
                multiSelectionCallback(selectedRowIndicesArray, selectedRows)
                tableView.reloadData()
                return
            }
        }

        // Perform single selection logic
        selectedRowIndices.removeAll()
        selectedRowIndices.insert(selectedRowIndex)
        selectionAction?(selectedRowIndex, dataSource[selectedRowIndex])

        if anchorView is UIBarButtonItem {
            // Dropdown's from UIBarButtonItem are menus so we deselect the selected menu right after selection
            deselectRow(at: selectedRowIndex)
        }

        hide()
    }
}

// MARK: - Auto dismiss

extension Dropdown {

    /// :nodoc:
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)

        if dismissMode == .automatic && view === dismissableView {
            cancel()
            return nil
        } else {
            return view
        }
    }

    @objc func dismissableViewTapped() {
        cancel()
	}
}

// MARK: - Keyboard events

extension Dropdown {

    /**
    Starts listening to keyboard events.
    Allows the dropdown to display correctly when keyboard is showed.
    */
    @objc static func startListeningToKeyboard() {
        DPDKeyboardListener.sharedInstance.startListeningToKeyboard()
    }

    func startListeningToKeyboard() {
        DPDKeyboardListener.sharedInstance.startListeningToKeyboard()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardUpdate),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardUpdate),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    func stopListeningToNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardUpdate() {
        self.setNeedsUpdateConstraints()
	}
}
