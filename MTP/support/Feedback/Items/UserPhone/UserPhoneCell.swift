// @copyright Trollwerks Inc.

import UIKit

/// UserPhoneCellEventProtocol
protocol UserPhoneCellEventProtocol {

    /// Phone change notification
    /// - Parameter text: New phone
    func userPhoneTextDidChange(_ text: String?)
}

/// UserPhoneCell
final class UserPhoneCell: UITableViewCell {

    private enum Const {

        static let FontSize: CGFloat = 14.0
        static let Margin: CGFloat = 15.0
        static let Height: CGFloat = 44.0
    }

    private var eventHandler: UserPhoneCellEventProtocol?

    /// textField
    let textField = UITextField()

    /// :nodoc:
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: .value1,
                   reuseIdentifier: reuseIdentifier)

        textField.backgroundColor = .clear
        textField.delegate = self
        textField.placeholder = L.feedbackPhone()
        textField.keyboardType = .phonePad
        contentView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                           constant: Const.Margin).isActive = true
        textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                            constant: Const.Margin).isActive = true
        textField.heightAnchor.constraint(equalToConstant: Const.Height).isActive = true
    }

    /// :nodoc:
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
}

extension UserPhoneCell: UITextFieldDelegate {

    /// :nodoc:
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        eventHandler?.userPhoneTextDidChange(textField.text)
        return true
    }
}

extension UserPhoneCell: CellFactoryProtocol {

    /// :nodoc:
    class func configure(_ cell: UserPhoneCell,
                         with item: UserPhoneItem,
                         for indexPath: IndexPath,
                         eventHandler: UserPhoneCellEventProtocol) {
        cell.eventHandler = eventHandler
    }
}
