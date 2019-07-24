// @copyright Trollwerks Inc.

import XCTest

extension XCUIElement.ElementType {

    var app: XCUIElementQuery {
        return XCUIApplication().query(type: self)
    }
}

extension XCUIElementTypeQueryProvider {

    // swiftlint:disable:next function_body_length
    func query(type: XCUIElement.ElementType) -> XCUIElementQuery {
        switch type {
        case .activityIndicator: return activityIndicators
        case .alert: return alerts
        case .browser: return browsers
        case .button: return buttons
        case .cell: return cells
        case .checkBox: return checkBoxes
        case .collectionView: return collectionViews
        case .colorWell: return colorWells
        case .comboBox: return comboBoxes
        case .datePicker: return datePickers
        case .decrementArrow: return decrementArrows
        case .dialog: return dialogs
        case .disclosureTriangle: return disclosureTriangles
        case .dockItem: return dockItems
        case .drawer: return drawers
        case .grid: return grids
        case .group: return groups
        case .handle: return handles
        case .helpTag: return helpTags
        case .icon: return icons
        case .image: return images
        case .incrementArrow: return incrementArrows
        case .key: return keys
        case .keyboard: return keyboards
        case .layoutArea: return layoutAreas
        case .layoutItem: return layoutItems
        case .levelIndicator: return levelIndicators
        case .link: return links
        case .map: return maps
        case .matte: return mattes
        case .menu: return menus
        case .menuBar: return menuBars
        case .menuBarItem: return menuBarItems
        case .menuButton: return menuButtons
        case .menuItem: return menuItems
        case .navigationBar: return navigationBars
        case .other: return otherElements
        case .outline: return outlines
        case .outlineRow: return outlineRows
        case .pageIndicator: return pageIndicators
        case .picker: return pickers
        case .pickerWheel: return pickerWheels
        case .popUpButton: return popUpButtons
        case .popover: return popovers
        case .progressIndicator: return progressIndicators
        case .radioButton: return radioButtons
        case .radioGroup: return radioGroups
        case .ratingIndicator: return ratingIndicators
        case .relevanceIndicator: return relevanceIndicators
        case .ruler: return rulers
        case .rulerMarker: return rulerMarkers
        case .scrollBar: return scrollBars
        case .scrollView: return scrollViews
        case .searchField: return searchFields
        case .secureTextField: return secureTextFields
        case .segmentedControl: return segmentedControls
        case .sheet: return sheets
        case .slider: return sliders
        case .splitGroup: return splitGroups
        case .splitter: return splitters
        case .staticText: return staticTexts
        case .statusBar: return statusBars
        case .statusItem: return statusItems
        case .stepper: return steppers
        case .switch: return switches
        case .tab: return tabs
        case .tabBar: return tabBars
        case .tabGroup: return tabGroups
        case .table: return tables
        case .tableColumn: return tableColumns
        case .tableRow: return tableRows // disclosedChildRows?
        case .textField: return textFields
        case .textView: return textViews
        case .timeline: return timelines
        case .toggle: return toggles
        case .toolbar: return toolbars
        case .toolbarButton: return toolbarButtons
        case .touchBar: return touchBars
        case .valueIndicator: return valueIndicators
        case .webView: return webViews
        case .window: return windows

        case .any:
            switch self {
            case let app as XCUIApplication:
                return app.descendants(matching: .any)
            case let element as XCUIElement:
                return element.descendants(matching: .any)
            default:
                fatalError("handle unknown XCUIElementTypeQueryProvider")
            }

        case .application:
            fatalError("incorrect ElementType query usage: \(type)")

        @unknown default:
            fatalError("handle new ElementType query: \(type)")
        }
    }
}
